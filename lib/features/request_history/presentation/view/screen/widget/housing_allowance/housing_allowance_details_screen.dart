import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/pdf_print_utils.dart';
import 'package:my_template/features/request_history/data/model/get_all_housing_allowance_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/section_widget.dart';

class HousingAllowanceDetailsScreen extends StatelessWidget {
  final GetAllHousingAllowanceModel request;

  const HousingAllowanceDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;

    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.vacation.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PdfPrintUtils.printDetails(context, AppLocalKay.vacation.tr(), [
              PrintSection(
                title: AppLocalKay.employee.tr(),
                items: {
                  AppLocalKay.employeeName.tr(): langCode == 'en'
                      ? (request.empNameE ?? '-')
                      : (request.empName ?? '-'),
                  AppLocalKay.employeeCode.tr(): request.empCode?.toString() ?? '-',
                },
              ),
              PrintSection(
                title: AppLocalKay.vacation.tr(),
                items: {
                  AppLocalKay.requestDate.tr(): request.requestDate ?? '-',
                  AppLocalKay.vacationAmount.tr(): request.sakanAmount?.toString() ?? '-',
                  AppLocalKay.vacationPeriod.tr(): request.strAmountType ?? '-',
                  AppLocalKay.reason.tr(): request.strNotes ?? '-',
                },
              ),
              PrintSection(
                title: AppLocalKay.status.tr(),

                items: {
                  AppLocalKay.status.tr(): request.requestDesc ?? '-',
                  AppLocalKay.followedActions.tr(): request.actionNotes ?? '-',
                },
              ),
            ]),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionWidget(
            title: AppLocalKay.employee.tr(),
            items: {
              AppLocalKay.employeeName.tr(): langCode == 'en'
                  ? (request.empNameE ?? '-')
                  : (request.empName ?? '-'),
              AppLocalKay.employeeCode.tr(): request.empCode?.toString() ?? '-',
            },
          ),
          SectionWidget(
            title: AppLocalKay.vacation.tr(),
            items: {
              AppLocalKay.requestDate.tr(): request.requestDate ?? '-',
              AppLocalKay.vacationAmount.tr(): request.sakanAmount?.toString() ?? '-',
              AppLocalKay.vacationPeriod.tr(): request.strAmountType ?? '-',
              AppLocalKay.reason.tr(): request.strNotes ?? '-',
            },
          ),
          SectionWidget(
            title: AppLocalKay.status.tr(),
            color: request.reqDecideState == 2
                ? Colors.red
                : request.reqDecideState == 1
                ? Color.fromARGB(255, 2, 217, 9)
                : const Color.fromARGB(255, 200, 194, 26),
            items: {
              AppLocalKay.status.tr(): request.requestDesc ?? '-',
              AppLocalKay.followedActions.tr(): request.actionNotes ?? '-',
            },
          ),
        ],
      ),
    );
  }
}
