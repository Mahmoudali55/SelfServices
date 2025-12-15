import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';

class TransferDetailsScreen extends StatelessWidget {
  final GetAllTransferModel request;

  const TransferDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';

    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.transfer.tr(), style: AppTextStyle.text18MSecond(context)),
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
              AppLocalKay.employeeName.tr(): isEn
                  ? (request.empNameE ?? '-')
                  : (request.empName ?? '-'),
              AppLocalKay.empCode.tr(): request.empCode?.toString() ?? '-',
            },
          ),
          _section(
            context,
            title: AppLocalKay.transfer.tr(),
            items: {
              AppLocalKay.requestDate.tr(): request.requestDate ?? '-',
              AppLocalKay.managerTo.tr(): isEn
                  ? (request.toDNameE ?? '-')
                  : (request.toDName ?? '-'),
              AppLocalKay.departmentTo.tr(): isEn
                  ? (request.toBNameE ?? '-')
                  : (request.toBName ?? '-'),
              AppLocalKay.projectTo.tr(): isEn
                  ? (request.toProjNameE ?? '-')
                  : (request.toProjName ?? '-'),
              AppLocalKay.status.tr(): request.requestDesc ?? '-',
              AppLocalKay.statusNumber.tr(): request.reqDecideState?.toString() ?? '-',
              AppLocalKay.reason.tr(): request.causes ?? '-',
            },
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
}
