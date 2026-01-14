import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/pdf_print_utils.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/section_widget.dart';

class ResignationDetailsScreen extends StatelessWidget {
  final GetAllResignationModel request;

  const ResignationDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.resignation.tr(), style: AppTextStyle.text18MSecond(context)),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PdfPrintUtils.printDetails(context, AppLocalKay.resignation.tr(), [
              PrintSection(
                title: AppLocalKay.employee.tr(),
                items: {
                  AppLocalKay.employeeName.tr(): request.empName ?? '-',
                  AppLocalKay.employeeNameEn.tr(): request.empNameE ?? '-',
                  AppLocalKay.empCode.tr(): request.empCode.toString() ?? '-',
                },
              ),
              PrintSection(
                title: AppLocalKay.resignation.tr(),
                items: {
                  AppLocalKay.requestDate.tr(): request.requestDate ?? '-',
                  AppLocalKay.trainingDay.tr(): request.lastWorkDate.toString() ?? '-',
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
              AppLocalKay.employeeName.tr(): request.empName ?? '-',
              AppLocalKay.employeeNameEn.tr(): request.empNameE ?? '-',
              AppLocalKay.empCode.tr(): request.empCode.toString() ?? '-',
            },
          ),

          SectionWidget(
            title: AppLocalKay.resignation.tr(),
            items: {
              AppLocalKay.requestDate.tr(): request.requestDate ?? '-',
              AppLocalKay.trainingDay.tr(): request.lastWorkDate.toString() ?? '-',
              AppLocalKay.reason.tr(): request.strNotes ?? '-',
            },
          ),

          SectionWidget(
            title: AppLocalKay.status.tr(),
            color: request.reqDecideState == 2
                ? Colors.red
                : request.reqDecideState == 1
                ? const Color.fromARGB(255, 2, 217, 9)
                : const Color.fromARGB(255, 200, 194, 26),
            items: {
              AppLocalKay.status.tr(): request.requestDesc,
              AppLocalKay.followedActions.tr(): request.actionNotes ?? '-',
            },
          ),
        ],
      ),
    );
  }
}
