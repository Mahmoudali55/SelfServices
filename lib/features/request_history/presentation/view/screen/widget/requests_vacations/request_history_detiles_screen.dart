import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/section_widget.dart';
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
          SectionWidget(
            title: AppLocalKay.employee_data.tr(),
            items: {
              AppLocalKay.employee_name.tr(): request.empName,
              AppLocalKay.employee_name_en.tr(): request.empNameE ?? '',
              AppLocalKay.employee_code.tr(): request.empCode?.toString() ?? '',
              AppLocalKay.department_name.tr(): request.dName,
              AppLocalKay.department_name_en.tr(): request.dNameE ?? '',
            },
          ),
          SectionWidget(
            title: AppLocalKay.vacation_data.tr(),
            items: {
              AppLocalKay.request_number.tr(): request.vacRequestId?.toString() ?? '',
              AppLocalKay.vacation_type.tr(): request.vacTypeName,
              AppLocalKay.request_date.tr(): request.vacRequestDate,
              AppLocalKay.from_date.tr(): request.vacRequestDateFrom,
              AppLocalKay.to_date.tr(): request.vacRequestDateTo,
              AppLocalKay.days_count.tr(): request.vacDayCount?.toString() ?? '',
              AppLocalKay.notes.tr(): request.strNotes,
            },
          ),
          SectionWidget(
            title: AppLocalKay.request_status.tr(),
            color: request.reqDecideState == 2
                ? Colors.red
                : request.reqDecideState == 1
                ? Color.fromARGB(255, 2, 217, 9)
                : const Color.fromARGB(255, 200, 194, 26),
            items: {AppLocalKay.status.tr(): request.requestDesc},
          ),
          SectionWidget(
            title: AppLocalKay.alternative_employee.tr(),
            items: {
              AppLocalKay.alternative_name.tr(): request.alternativeEmpName,
              AppLocalKay.alternative_name_en.tr(): request.alternativeEmpNameE ?? '',
              AppLocalKay.alternative_code.tr(): request.alternativeEmpCode?.toString() ?? '',
            },
          ),
          SectionWidget(
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
}
