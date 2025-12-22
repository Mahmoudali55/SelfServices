import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/action_notes_marquee.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/resignation/action_buttons_widget.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/resignation/details_widget.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/resignation/header_row_widget.dart';

class ResignationRequestItem extends StatelessWidget {
  final GetAllResignationModel request;
  final int empcoded;

  const ResignationRequestItem({super.key, required this.request, required this.empcoded});

  Color _getStatusColor(int status) {
    if (status == 3) return const Color.fromARGB(255, 200, 194, 26);
    if (status == 1) return const Color.fromARGB(255, 2, 217, 9);
    if (status == 2) return Colors.red;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final int statusText = request.reqDecideState ?? 0;
    final statusColor = _getStatusColor(statusText);
    final isEditable = request.reqDecideState == 3;
    final isEn = context.locale.languageCode == 'en';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColor.greyColor(context).withAlpha(10),
        border: Border.all(color: AppColor.greyColor(context), width: 0.5),
      ),
      child: Card(
        color: AppColor.whiteColor(context),
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.reqDicidState == 4 && (request.actionNotes?.isNotEmpty ?? false))
              AnimatedActionNote(text: request.actionNotes!),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  HeaderRowWidget(),
                  const Divider(height: 20, thickness: 1),
                  Details(request: request, isEn: isEn),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: request.requestDesc ?? '',
                                style: AppTextStyle.text14RGrey(
                                  context,
                                  color: statusColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditable) ActionButtons(request: request, empcoded: empcoded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
