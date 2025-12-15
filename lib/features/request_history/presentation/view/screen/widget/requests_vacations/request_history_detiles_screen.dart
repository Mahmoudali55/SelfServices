import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';

class RequestHistoryDetilesScreen extends StatelessWidget {
  const RequestHistoryDetilesScreen({super.key, required this.request});
  final VacationRequestOrdersModel request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(
          AppLocalKay.vacation_request_details.tr(),
          style: AppTextStyle.text18MSecond(context),
        ),
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
            title: AppLocalKay.employee_data.tr(),
            items: {
              AppLocalKay.employee_name.tr(): request.empName,
              AppLocalKay.employee_name_en.tr(): request.empNameE,
              AppLocalKay.employee_code.tr(): request.empCode?.toString(),
              AppLocalKay.department_name.tr(): request.dName,
              AppLocalKay.department_name_en.tr(): request.dNameE,
            },
          ),
          _section(
            title: AppLocalKay.vacation_data.tr(),
            items: {
              AppLocalKay.request_number.tr(): request.vacRequestId?.toString(),
              AppLocalKay.vacation_type.tr(): request.vacTypeName,
              AppLocalKay.request_date.tr(): request.vacRequestDate,
              AppLocalKay.from_date.tr(): request.vacRequestDateFrom,
              AppLocalKay.to_date.tr(): request.vacRequestDateTo,
              AppLocalKay.days_count.tr(): request.vacDayCount?.toString(),
              AppLocalKay.notes.tr(): request.strNotes,
            },
          ),
          _section(
            title: AppLocalKay.request_status.tr(),
            items: {AppLocalKay.status.tr(): request.requestDesc},
          ),
          _section(
            title: AppLocalKay.alternative_employee.tr(),
            items: {
              AppLocalKay.alternative_name.tr(): request.alternativeEmpName,
              AppLocalKay.alternative_name_en.tr(): request.alternativeEmpNameE,
              AppLocalKay.alternative_code.tr(): request.alternativeEmpCode?.toString(),
            },
          ),
          _section(
            title: AppLocalKay.attachments.tr(),
            items: {
              AppLocalKay.attachments.tr(): (request.attachFileName?.isEmpty ?? true)
                  ? AppLocalKay.no_attachment.tr()
                  : request.attachFileName,
            },
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Map<String, String?> items}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.entries.map((e) => _row(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(flex: 5, child: Text(value ?? "-")),
        ],
      ),
    );
  }
}
