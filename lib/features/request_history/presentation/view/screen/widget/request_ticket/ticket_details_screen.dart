import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_ticket_model.dart';

class TicketDetailsScreen extends StatelessWidget {
  final AllTicketModel request;

  const TicketDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final statusText = request.requestDesc ?? '';
    final statusColor = _getStatusColor(statusText);

    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.tickets.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            context,
            title: AppLocalKay.employee.tr(),
            items: {
              AppLocalKay.employeeName.tr(): langCode == 'en'
                  ? (request.empNameE ?? '-')
                  : (request.empName ?? '-'),
              AppLocalKay.employeeCode.tr(): request.empCode?.toString() ?? '-',
            },
          ),
          _section(
            context,
            title: AppLocalKay.tickets.tr(),
            items: {
              AppLocalKay.requestDate.tr(): request.requestDate ?? '-',
              AppLocalKay.travel_place.tr(): request.ticketPath ?? '-',
              AppLocalKay.ticketType.tr(): request.strGoback ?? '-',
              AppLocalKay.reason.tr(): request.strNotes ?? '-',
            },
          ),
          _section(
            context,
            title: AppLocalKay.status.tr(),
            items: {AppLocalKay.status.tr(): statusText},
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required Map<String, String> items,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.text18MSecond(context).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.entries.map((e) => _detailsRow(context, e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _detailsRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTextStyle.text14RGrey(context).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value, style: AppTextStyle.text14RGrey(context))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('تحت الاجراء')) return const Color.fromARGB(255, 200, 194, 26);
    if (status.contains('تمت الموافقة علي الطلب')) return const Color.fromARGB(255, 2, 217, 9);
    if (status.contains('تم رفض الطلب') || status.contains('تم الرفض')) return Colors.red;
    return Colors.grey.shade300;
  }
}
