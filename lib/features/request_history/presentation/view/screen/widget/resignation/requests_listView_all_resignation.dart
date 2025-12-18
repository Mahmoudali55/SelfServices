import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';

class RequestsListViewAllResignation extends StatelessWidget {
  final List<GetAllResignationModel> requests;
  final int empcoded;

  const RequestsListViewAllResignation({super.key, required this.requests, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.assetsGlobalIconEmptyFolderIcon),
            const Gap(10),
            Text(AppLocalKay.no_requests.tr()),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutesName.resignationDetailsScreen,
            arguments: requests[index],
          );
        },
        child: ResignationRequestItem(request: requests[index], empcoded: empcoded),
      ),
    );
  }
}

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(context),
              const Divider(height: 20, thickness: 1),
              _Details(request: request, isEn: isEn),
              _StatusLabel(status: request.requestDesc ?? '', color: statusColor),
              if (isEditable) _ActionButtons(request: request, empcoded: empcoded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _HeaderRow(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leave_bags_at_home_rounded, size: 16, color: AppColor.blackColor(context)),
            const SizedBox(width: 8),
            Text(
              AppLocalKay.resignation.tr(),
              style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  final GetAllResignationModel request;
  final bool isEn;

  const _Details({required this.request, required this.isEn});

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

class _StatusLabel extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusLabel({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        status,
        style: AppTextStyle.text14RGrey(
          context,
          color: color,
        ).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final GetAllResignationModel request;
  final int empcoded;

  const _ActionButtons({required this.request, required this.empcoded});

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
                RoutesName.resignationRequestScreen,
                arguments: {'empId': request.empCode, 'resignationRequestmodel': request},
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
                builder: (context) => AlertDialog(
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
                context.read<VacationRequestsCubit>().deleteResignation(
                  requestId: request.requestID ?? 0,
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
            color: AppColor.whiteColor(context),
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
