import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/section_widget.dart';

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
          SectionWidget(
            title: AppLocalKay.employee.tr(),
            items: {
              AppLocalKay.employeeName.tr(): isEn
                  ? (request.empNameE ?? '-')
                  : (request.empName ?? '-'),
              AppLocalKay.empCode.tr(): request.empCode?.toString() ?? '-',
            },
          ),
          SectionWidget(
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

              AppLocalKay.statusNumber.tr(): request.reqDecideState?.toString() ?? '-',
              AppLocalKay.reason.tr(): request.causes ?? '-',
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
