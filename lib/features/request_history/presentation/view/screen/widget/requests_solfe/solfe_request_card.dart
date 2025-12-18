import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_solfa_model.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';

class RequestCard extends StatelessWidget {
  final SolfaItem request;
  final int empcoded;
  const RequestCard({super.key, required this.request, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    final StatusInfo statusInfo = _getStatusInfo(request.reqDecideState ?? 0);

    final langCode = context.locale.languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColor.greyColor(context).withAlpha(10),
        border: Border.all(color: AppColor.greyColor(context), width: .5),
      ),
      child: Card(
        color: AppColor.whiteColor(context),
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.money, size: 16, color: AppColor.blackColor(context)),
                  const SizedBox(width: 8),
                  Text(
                    langCode == 'en' ? request.solfaTypeNameE ?? '' : request.solfaTypeName ?? '',
                    style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              CustomTitelCardWidget(
                icon: Icons.person,
                request: request,
                title: AppLocalKay.employee.tr(),
                description: langCode == 'en' ? request.empNameE ?? '' : request.empName ?? '',
              ),
              CustomTitelCardWidget(
                icon: Icons.calendar_month,
                request: request,
                title: AppLocalKay.discountstartdate.tr(),
                description: request.startDicountDate ?? '',
              ),
              CustomTitelCardWidget(
                icon: Icons.monetization_on,
                request: request,
                title: AppLocalKay.loanamount.tr(),
                description: request.solfaAmount.toString(),
              ),
              CustomTitelCardWidget(
                icon: Icons.list_alt,
                request: request,
                title: AppLocalKay.loaninstallments.tr(),
                description: request.dofaaCount.toString(),
              ),
              CustomTitelCardWidget(
                icon: Icons.attach_money,
                request: request,
                title: AppLocalKay.installmentamount.tr(),
                description: request.dofaaAmount.toString(),
              ),

              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          if (request.reqDicidState == 4) ...[
                            TextSpan(
                              text: AppLocalKay.followedActions.tr() + ': ',
                              style: AppTextStyle.text16SDark(
                                context,
                                color: AppColor.darkTextColor(context).withAlpha(140),
                              ),
                            ),
                            TextSpan(
                              text: request.actionNotes ?? '',
                              style: AppTextStyle.text16SDark(context, color: statusInfo.color),
                            ),
                          ] else ...[
                            TextSpan(
                              text: request.requestDesc ?? '',
                              style: AppTextStyle.text14RGrey(
                                context,
                                color: statusInfo.color,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (request.reqDecideState == 3) ActionButtons(request: request, empcoded: empcoded),
            ],
          ),
        ),
      ),
    );
  }

  StatusInfo _getStatusInfo(int statusCode) {
    switch (statusCode) {
      case 3:
        return StatusInfo(const Color.fromARGB(255, 200, 194, 26));
      case 1:
        return StatusInfo(const Color.fromARGB(255, 2, 217, 9));
      case 2:
        return StatusInfo(Colors.red);
      default:
        return StatusInfo(Colors.grey.shade300);
    }
  }
}

class StatusInfo {
  final Color color;
  StatusInfo(this.color);
}

class ActionButtons extends StatelessWidget {
  final SolfaItem request;
  final int empcoded;
  const ActionButtons({super.key, required this.request, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: AppLocalKay.edit.tr(),
            color: AppColor.primaryColor(context),
            onTap: () {
              Navigator.pushNamed(
                context,
                RoutesName.solfaRequestScreen,
                arguments: {'empId': request.empCode, 'solfaItem': request},
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: AppLocalKay.delete.tr(),
            color: Colors.red,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => _ConfirmDialog(),
              );
              if (confirm == true) {
                context.read<VacationRequestsCubit>().deleteRequestSolfa(
                  requestId: request.requestId,
                  empcode: request.empCode ?? 0,
                  empcodeadmin: empcoded,
                  context: context,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyle.text14RGrey(
            context,
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(AppLocalKay.confirm.tr()),
      content: Text(AppLocalKay.deleteConfirmation.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalKay.cancel.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(AppLocalKay.confirm.tr()),
        ),
      ],
    );
  }
}
