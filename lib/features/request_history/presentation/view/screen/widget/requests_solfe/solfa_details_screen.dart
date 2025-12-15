import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_solfa_model.dart';

class SolfaDetailsScreen extends StatelessWidget {
  final SolfaItem request;

  const SolfaDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';

    return Scaffold(
      appBar: CustomAppBar(
        context,
        title: Text(AppLocalKay.loanDetails.tr(), style: AppTextStyle.text18MSecond(context)),
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
            title: AppLocalKay.solfa.tr(),
            items: {
              AppLocalKay.solfaType.tr(): isEn
                  ? (request.solfaTypeNameE ?? '-')
                  : (request.solfaTypeName ?? '-'),
              AppLocalKay.discountstartdate.tr(): request.startDicountDate ?? '-',
              AppLocalKay.loanamount.tr(): request.solfaAmount.toString(),
              AppLocalKay.loaninstallmentscount.tr(): request.dofaaCount.toString(),
              AppLocalKay.installmentamounttitle.tr(): request.dofaaAmount.toString(),
              AppLocalKay.status.tr(): request.requestDesc ?? '-',
              AppLocalKay.statusNumber.tr(): request.reqDecideState?.toString() ?? '-',
              AppLocalKay.notes.tr(): request.strNotes,
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
