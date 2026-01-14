import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/pdf_print_utils.dart';
import 'package:my_template/features/request_history/data/model/get_dynamic_order_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/section_widget.dart';

class GeneralRequestDetailsScreen extends StatelessWidget {
  final DynamicOrderModel request;

  const GeneralRequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;

    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(
          request.strField2.isEmpty
              ? AppLocalKay.requestgeneral.tr()
              : AppLocalKay.requestchangePhone.tr(),
          style: AppTextStyle.text18MSecond(context),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PdfPrintUtils.printDetails(
              context,
              request.strField2.isEmpty
                  ? AppLocalKay.requestgeneral.tr()
                  : AppLocalKay.requestchangePhone.tr(),
              [
                PrintSection(
                  title: AppLocalKay.employee.tr(),
                  items: {
                    AppLocalKay.employeeName.tr(): langCode == 'en'
                        ? (request.empNameE)
                        : (request.empName),
                    AppLocalKay.employeeCode.tr(): request.empCode.toString(),
                  },
                ),
                PrintSection(
                  title: AppLocalKay.requestgeneral.tr(),
                  items: {
                    AppLocalKay.requestDate.tr(): request.requestDate,
                    AppLocalKay.reason.tr(): request.strField1,
                    request.strField2.isEmpty ? AppLocalKay.notes.tr() : AppLocalKay.newDevice.tr():
                        request.strField2.isEmpty ? request.strNotes : request.strField2,
                  },
                ),
                PrintSection(
                  title: AppLocalKay.status.tr(),

                  items: {
                    AppLocalKay.status.tr(): request.requestDesc,
                    AppLocalKay.followedActions.tr(): request.actionNotes,
                  },
                ),
              ],
            ),
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
                  ? (request.empNameE)
                  : (request.empName),
              AppLocalKay.employeeCode.tr(): request.empCode.toString(),
            },
          ),
          SectionWidget(
            title: AppLocalKay.requestgeneral.tr(),
            items: {
              AppLocalKay.requestDate.tr(): request.requestDate,
              AppLocalKay.reason.tr(): request.strField1,
              request.strField2.isEmpty ? AppLocalKay.notes.tr() : AppLocalKay.newDevice.tr():
                  request.strField2.isEmpty ? request.strNotes : request.strField2,
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
              AppLocalKay.followedActions.tr(): request.actionNotes,
            },
          ),
        ],
      ),
    );
  }
}
