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
import 'package:my_template/features/request_history/data/model/get_all_ticket_model.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/action_notes_marquee.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';

class RequestsListViewTicket extends StatelessWidget {
  final List<AllTicketModel> requests;
  final int empcoded;

  const RequestsListViewTicket({super.key, required this.requests, required this.empcoded});

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
          Navigator.pushNamed(context, RoutesName.ticketDetailsScreen, arguments: requests[index]);
        },
        child: HousingAllowanceRequestItem(request: requests[index], empcoded: empcoded),
      ),
    );
  }
}

class HousingAllowanceRequestItem extends StatelessWidget {
  final AllTicketModel request;
  final int empcoded;

  const HousingAllowanceRequestItem({super.key, required this.request, required this.empcoded});

  Color _getStatusColor(int status) {
    if (status == 3) return const Color.fromARGB(255, 200, 194, 26);
    if (status == 1) return const Color.fromARGB(255, 2, 217, 9);
    if (status == 2) return Colors.red;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final int status = request.reqDecideState as int? ?? 0;
    final statusColor = _getStatusColor(status);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(context),
                  const Divider(height: 20, thickness: 1),
                  _Details(request: request, isEn: isEn),
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
                  if (isEditable) _ActionButtons(request: request, empcoded: empcoded),
                ],
              ),
            ),
          ],
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
            Icon(Icons.travel_explore, size: 16, color: AppColor.blackColor(context)),
            const SizedBox(width: 8),
            Text(
              AppLocalKay.ticket.tr(),
              style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  final AllTicketModel request;
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
          icon: Icons.public,
          request: request,
          title: AppLocalKay.travel_place.tr(),
          description: request.ticketPath.toString(),
        ),

        CustomTitelCardWidget(
          icon: Icons.airplane_ticket,
          request: request,
          title: context.locale.languageCode == 'en' ? 'Ticket Type' : 'نوع التذاكر',
          description: request.strGoback,
        ),
        CustomTitelCardWidget(
          icon: Icons.notes,
          request: request,
          title: AppLocalKay.reason.tr(),
          description: request.strNotes.toString(),
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
  final AllTicketModel request;
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
                RoutesName.requestToIssueTicketsScreen,
                arguments: {'empId': request.empCode, 'allTicketModel': request},
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
                context.read<VacationRequestsCubit>().deleteTicket(
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
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
