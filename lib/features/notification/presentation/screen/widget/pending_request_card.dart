import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/notification/data/model/deciding_In_request_model.dart';
import 'package:my_template/features/notification/data/model/req_count_response.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:my_template/features/notification/presentation/screen/widget/action_button.dart';
import 'package:my_template/features/notification/presentation/screen/widget/custom_titel_card_widget.dart';
import 'package:my_template/features/notification/presentation/screen/widget/show_notes_bottom_sheet.dart';

class PendingRequestCard extends StatelessWidget {
  final dynamic request;
  final RequestType type;

  const PendingRequestCard({super.key, required this.request, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Row(
                children: [
                  Icon(Icons.list, color: AppColor.blackColor(context)),
                  const SizedBox(width: 8),
                  Text(
                    request.strRequestType ?? '',
                    style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: request.attatchmentName == null
                          ? Colors.orange
                          : AppColor.primaryColor(context),
                    ),
                    child: Text(
                      request.attatchmentName == null
                          ? AppLocalKay.pending.tr()
                          : AppLocalKay.attachmentsAttached.tr(),
                      style: AppTextStyle.text14RGrey(context, color: AppColor.whiteColor(context)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              CustomTitelCardPendingWidget(
                icon: Icons.person,
                title: AppLocalKay.employee.tr(),
                description: context.locale.languageCode == 'en'
                    ? (request.empEngName ?? '')
                    : request.empArName ?? '',
              ),
              CustomTitelCardPendingWidget(
                icon: Icons.calendar_month,
                title: AppLocalKay.requestDate.tr(),
                description: request.insrtDate ?? '',
              ),
              (request.cAUSES == null || request.cAUSES!.trim().isEmpty)
                  ? const SizedBox()
                  : CustomTitelCardPendingWidget(
                      icon: Icons.calendar_month,
                      title: AppLocalKay.reason.tr(),
                      description: request.cAUSES!,
                    ),

              CustomTitelCardPendingWidget(
                icon: Icons.apartment,
                title: AppLocalKay.management.tr(),
                description: context.locale.languageCode == 'en'
                    ? request.empDeptEngName ?? ''
                    : request.empDeptArName ?? '',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ActionButton(
                    label: AppLocalKay.view.tr(),
                    color: AppColor.primaryColor(context),
                    onTap: () => NavigatorMethods.pushNamed(
                      context,
                      RoutesName.pendingRequestDetailScreen,
                      arguments: {'request': request},
                    ),
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    label: AppLocalKay.accept.tr(),
                    color: AppColor.greenColor(context),
                    onTap: () => _handleAction(context, 1),
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    label: AppLocalKay.reject.tr(),
                    color: Colors.red,
                    onTap: () => _handleAction(context, 2),
                  ),
                  const SizedBox(width: 8),
                  ActionButton(
                    label: AppLocalKay.action.tr(),
                    color: AppColor.primaryColor(context),
                    onTap: () => _handleAction(context, 3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, int actionType) async {
    final notes = await showNotesBottomSheet(context);
    if (notes == null) return;

    context.read<NotifictionCubit>().decidingIn(
      request: DecidingInRequestModel(
        requestType: request.requestType ?? 0,
        requestId: request.requestId ?? 0,
        actionType: actionType,
        actionMakerEmpID: int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0,
        strNotes: notes,
        isLastDecidingEmp: request.isLastDecidingEmp,
        haveSpecialDecide: 0,
        specialDecideEmpId: null,
      ),
      message: _successMessage(context, actionType),
      requestType: type,
    );
  }

  String _successMessage(BuildContext context, int actionType) {
    if (context.locale.languageCode == 'ar') {
      switch (actionType) {
        case 1:
          return 'تم قبول الطلب بنجاح';
        case 2:
          return 'تم رفض الطلب بنجاح';
        default:
          return 'تم وضع الطلب تحت الإجراء بنجاح';
      }
    } else {
      switch (actionType) {
        case 1:
          return 'Request accepted successfully';
        case 2:
          return 'Request rejected successfully';
        default:
          return 'Request under process successfully';
      }
    }
  }
}
