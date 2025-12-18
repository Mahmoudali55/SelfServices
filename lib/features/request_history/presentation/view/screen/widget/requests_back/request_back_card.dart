import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/request_history/data/model/get_requests_vacation_back.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';

class RequestBackCard extends StatelessWidget {
  final GetRequestVacationBackModel request;
  final int empcoded;

  const RequestBackCard({super.key, required this.request, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    final int status = request.reqDecideState as int? ?? 0;
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
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
              _buildHeader(context),
              const Divider(height: 20, thickness: 1),
              CustomTitelCardWidget(
                icon: Icons.person,
                request: request,
                title: AppLocalKay.employee.tr(),
                description: context.locale.languageCode == 'en'
                    ? request.empNameE ?? ''
                    : request.empName ?? '',
              ),
              CustomTitelCardWidget(
                icon: Icons.calendar_month,
                request: request,
                title: AppLocalKay.start_date.tr(),
                description: request.strVacRequestDateFrom ?? '',
              ),
              CustomTitelCardWidget(
                icon: Icons.calendar_month,
                request: request,
                title: AppLocalKay.end_date.tr(),
                description: request.strVacRequestDateTo ?? '',
              ),
              const SizedBox(height: 8),
              Text(
                request.requestDesc ?? '',
                style: AppTextStyle.text14RGrey(
                  context,
                  color: statusColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              if (request.reqDecideState == 3) ...[
                const SizedBox(height: 10),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.request_quote, size: 16, color: AppColor.blackColor(context)),
            const SizedBox(width: 8),
            Text(
              AppLocalKay.backleave.tr(),
              style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColor.blackColor(context)),
            const SizedBox(width: 4),
            Text(
              '${request.vacDayCount} ${AppLocalKay.days.tr()}',
              style: AppTextStyle.text16MSecond(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: AppLocalKay.edit.tr(),
            color: AppColor.primaryColor(context),
            onTap: () {
              final pageItem = context.read<HomeCubit>().state.vacationStatus.data;
              Navigator.pushNamed(
                context,
                RoutesName.backFromVacationScreen,
                arguments: {
                  'PagePrivID': pageItem?.pagePrivID ?? 0,
                  'empcode': request.empCode,
                  'vacationRequestOrdersModelBack': request,
                },
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: AppLocalKay.delete.tr(),
            color: Colors.red,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
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
                ),
              );
              if (confirm == true) {
                context.read<VacationRequestsCubit>().deleteRequestBack(
                  requestId: request.vacRequestId,
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

  Color _statusColor(int status) {
    if (status == 3) return const Color.fromARGB(255, 200, 194, 26);
    if (status == 1) return const Color.fromARGB(255, 2, 217, 9);
    if (status == 2) return Colors.red;
    return Colors.grey.shade300;
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
