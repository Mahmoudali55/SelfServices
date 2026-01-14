import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';

class Details extends StatelessWidget {
  final GetAllResignationModel request;
  final bool isEn;

  const Details({super.key, required this.request, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitelCardWidget(
          icon: Icons.person,
          request: request,
          title: AppLocalKay.employee.tr(),
          description: isEn ? (request.empNameE ?? '') : request.empName ?? '',
        ),
        CustomTitelCardWidget(
          icon: Icons.calendar_month,
          request: request,
          title: AppLocalKay.requestDate.tr(),
          description: request.requestDate ?? '',
        ),
        CustomTitelCardWidget(
          icon: Icons.calendar_month,
          request: request,
          title: AppLocalKay.trainingDay.tr(),
          description: request.lastWorkDate.toString(),
        ),
      ],
    );
  }
}
