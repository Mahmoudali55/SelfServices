import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/custom_titel_card_widget.dart';

class RequestItemCard extends StatelessWidget {
  final GetAllTransferModel request;
  final int empcoded;

  const RequestItemCard({super.key, required this.request, required this.empcoded});

  Color _getStatusColor(String statusText) {
    if (statusText.contains('تحت الاجراء')) {
      return const Color.fromARGB(255, 200, 194, 26);
    } else if (statusText.contains('تمت الموافقة علي الطلب')) {
      return const Color.fromARGB(255, 2, 217, 9);
    } else if (statusText.contains('تم رفض الطلب') || statusText.contains('تم الرفض')) {
      return Colors.red;
    }
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = request.requestDesc ?? '';
    final Color statusColor = _getStatusColor(statusText);
    final bool canEdit = request.reqDecideState == 3;

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
              const _HeaderRow(),
              const Divider(height: 20, thickness: 1),
              _RequestDetails(request: request),
              _StatusLabel(statusText: statusText, statusColor: statusColor),
              if (canEdit) _ActionButtons(request: request, empcoded: empcoded),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(Icons.transform, size: 16, color: AppColor.blackColor(context)),
        ),
        Text(
          AppLocalKay.transfer.tr(),
          style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
        ),
      ],
    );
  }
}

class _RequestDetails extends StatelessWidget {
  final GetAllTransferModel request;
  const _RequestDetails({required this.request});

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitelCardWidget(
          icon: Icons.person,
          request: request,
          title: AppLocalKay.employee.tr(),
          description: isEn ? (request.empNameE ?? '') : (request.empName ?? ''),
        ),
        CustomTitelCardWidget(
          icon: Icons.calendar_month,
          request: request,
          title: AppLocalKay.requestDate.tr(),
          description: request.requestDate ?? '',
        ),
        CustomTitelCardWidget(
          icon: Icons.list_alt,
          request: request,
          title: AppLocalKay.managerTo.tr(),
          description: isEn ? request.toDNameE.toString() : request.toDName.toString(),
        ),
        CustomTitelCardWidget(
          icon: Icons.list_alt,
          request: request,
          title: AppLocalKay.departmentTo.tr(),
          description: isEn ? request.toBNameE.toString() : request.toBName.toString(),
        ),
        CustomTitelCardWidget(
          icon: Icons.list_alt,
          request: request,
          title: AppLocalKay.projectTo.tr(),
          description: isEn ? request.toProjName.toString() : request.toProjName.toString(),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String statusText;
  final Color statusColor;
  const _StatusLabel({required this.statusText, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        statusText,
        style: AppTextStyle.text14RGrey(
          context,
          color: statusColor,
        ).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final GetAllTransferModel request;
  final int empcoded;
  const _ActionButtons({required this.request, required this.empcoded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _EditButton(request: request)),
        const SizedBox(width: 10),
        Expanded(
          child: _DeleteButton(request: request, empcoded: empcoded),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  final GetAllTransferModel request;
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
          RoutesName.transferrequest,
          arguments: {
            'PagePrivID': pageItem?.pagePrivID ?? 0,
            'empId': request.empCode,
            'getAllTransferModel': request,
          },
        );
      },
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final GetAllTransferModel request;
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
          context.read<VacationRequestsCubit>().deleteTransfer(
            requestId: request.requestId ?? 0,
            empcode: request.adminEmpCode ?? 0,
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
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
