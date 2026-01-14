import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/action_notes_marquee.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';

class RequestsListViewAllVacations extends StatelessWidget {
  final List<VacationRequestOrdersModel> requests;
  final int empcoded;

  const RequestsListViewAllVacations({super.key, required this.requests, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120),
      itemCount: requests.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RoutesName.requestHistoryDetilesScreen,
            arguments: requests[index],
          );
        },
        child: VacationRequestItem(request: requests[index], empcoded: empcoded),
      ),
    );
  }
}

/*────────────────── ITEM ──────────────────*/

class VacationRequestItem extends StatelessWidget {
  final VacationRequestOrdersModel request;
  final int empcoded;

  const VacationRequestItem({super.key, required this.request, required this.empcoded});

  (Color, IconData) _getTypeStyle() {
    switch (request.vacTypeName) {
      case 'اجازة سنوية':
        return (const Color(0xFFC8E6C9), Icons.beach_access);
      case 'مرضية':
        return (const Color(0xFFFFCDD2), Icons.sick);
      case 'بدون مرتب':
        return (const Color(0xFFFFF9C4), Icons.money_off);
      case 'إجازة خاصة':
        return (const Color(0xFFBBDEFB), Icons.event_note);
      default:
        return (Colors.grey.shade200, Icons.event);
    }
  }

  StatusInfo _getStatusInfo(int statusCode, String desc) {
    switch (statusCode) {
      case 3: // تحت الإجراء
        return StatusInfo(color: const Color.fromARGB(255, 200, 194, 26), text: desc);
      case 1: // موافق
        return StatusInfo(color: const Color.fromARGB(255, 2, 217, 9), text: desc);
      case 2: // مرفوض
        return StatusInfo(color: Colors.red, text: desc);
      default:
        return StatusInfo(color: Colors.grey.shade300, text: desc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (cardColor, iconData) = _getTypeStyle();
    final statusInfo = _getStatusInfo(request.reqDecideState, request.requestDesc);

    final isEditable = request.reqDecideState == 3;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.reqDicidState == 4 && (request.actionNotes?.isNotEmpty ?? false))
              AnimatedActionNote(text: request.actionNotes!),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(
                    iconData: iconData,
                    vacTypeName: request.vacTypeName,
                    vacDayCount: request.vacDayCount,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _VacationDetails(request: request),
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
                                  color: statusInfo.color,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditable) _ActionButtons(request: request, empcoded: empcoded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*────────────────── MODELS ──────────────────*/

class StatusInfo {
  final Color color;
  final String text;

  const StatusInfo({required this.color, required this.text});
}

/*────────────────── UI PARTS ──────────────────*/

class _HeaderRow extends StatelessWidget {
  final IconData iconData;
  final String vacTypeName;
  final int vacDayCount;

  const _HeaderRow({required this.iconData, required this.vacTypeName, required this.vacDayCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Icon(iconData, color: AppColor.blackColor(context)),
            const Gap(8),
            Text(
              vacTypeName,
              style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const Gap(4),
            Text(
              '$vacDayCount ${AppLocalKay.days.tr()}',
              style: AppTextStyle.text16MSecond(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _VacationDetails extends StatelessWidget {
  final VacationRequestOrdersModel request;

  const _VacationDetails({required this.request});

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';

    return Column(
      children: [
        CustomTitelCardWidget(
          icon: Icons.person,
          request: request,
          title: AppLocalKay.employee.tr(),
          description: isEn ? (request.empNameE ?? '') : request.empName,
        ),
        CustomTitelCardWidget(
          icon: Icons.calendar_month,
          request: request,
          title: AppLocalKay.start_date.tr(),
          description: request.strVacRequestDateFrom,
        ),
        CustomTitelCardWidget(
          icon: Icons.calendar_month,
          request: request,
          title: AppLocalKay.end_date.tr(),
          description: request.strVacRequestDateTo,
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

/*────────────────── ACTIONS ──────────────────*/

class _ActionButtons extends StatelessWidget {
  final VacationRequestOrdersModel request;
  final int empcoded;

  const _ActionButtons({required this.request, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _EditButton(request: request)),
        const Gap(10),
        Expanded(
          child: _DeleteButton(request: request, empcoded: empcoded),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  final VacationRequestOrdersModel request;

  const _EditButton({required this.request});

  @override
  Widget build(BuildContext context) {
    return _ActionContainer(
      color: AppColor.primaryColor(context),
      label: AppLocalKay.edit.tr(),
      onTap: () {
        final pageItem = context.read<HomeCubit>().state.vacationStatus.data;

        Navigator.pushNamed(
          context,
          RoutesName.requestLeaveScreen,
          arguments: {
            'PagePrivID': pageItem?.pagePrivID ?? 0,
            'empcode': request.empCode,
            'vacationRequestOrdersModel': request,
          },
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VacationRequestOrdersModel request;
  final int empcoded;

  const _DeleteButton({required this.request, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return _ActionContainer(
      color: Colors.red,
      label: AppLocalKay.delete.tr(),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
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
          context.read<VacationRequestsCubit>().deleteRequest(
            requestId: request.vacRequestId,
            empcode: request.empCode,
            empcodeadmin: empcoded,
            context: context,
          );
        }
      },
    );
  }
}

class _ActionContainer extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionContainer({required this.color, required this.label, required this.onTap});

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
