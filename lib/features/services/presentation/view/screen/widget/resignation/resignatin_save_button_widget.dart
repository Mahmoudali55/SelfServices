import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/resignation/resignation_request_model.dart';
import 'package:my_template/features/services/data/model/resignation/update_resignation_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class ResignationSaveButton extends StatelessWidget {
  const ResignationSaveButton({
    super.key,
    required this.formKey,
    required this.empCode,
    required this.resignationModel,
    required this.dateController,
    required this.lastWorkController,
    required this.notesController,
    required this.requestIdController,
    this.newrequest,
    required this.attachmentList,
  });

  final GlobalKey<FormState> formKey;
  final int? empCode;
  final GetAllResignationModel? resignationModel;
  final TextEditingController dateController;
  final TextEditingController lastWorkController;
  final TextEditingController notesController;
  final TextEditingController requestIdController;
  final void Function()? newrequest;
  final List<AttachmentModel> attachmentList;
  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) {
        _handleState(context, state);
      },
      child: CustomBottomNavButtonWidget(
        newrequest: newrequest,
        title: resignationModel != null ? AppLocalKay.edit.tr() : AppLocalKay.save.tr(),
        color: resignationModel != null ? Colors.orange : AppColor.primaryColor(context),
        save: () => _onSave(context),
        isLoading: resignationModel != null
            ? context.watch<ServicesCubit>().state.updataResignationStatus.isLoading
            : context.watch<ServicesCubit>().state.resignationStatus.isLoading,
      ),
    );
  }

  void _handleState(BuildContext context, ServicesState state) {
    if (resignationModel != null && state.updataResignationStatus.isSuccess) {
      _showToastSuccess(context, AppLocalKay.update_resignation_success.tr());
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'sakalRequest'},
      );
    } else if (state.resignationStatus.isSuccess) {
      _showToastSuccess(context, AppLocalKay.submit_resignation_success.tr());
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'sakalRequest'},
      );
    }

    if (state.resignationStatus.isFailure) {
      _showToast(context, state.resignationStatus.error ?? 'Error');
    }
  }

  void _onSave(BuildContext context) async {
    await context.read<ServicesCubit>().checkEmpBackHaveRequestsResignation(empCode: empCode ?? 0);
    final checkState = context.read<ServicesCubit>().state.checkEmpHaveResignationRequestsStatus;

    if (resignationModel == null && checkState.isSuccess) {
      final checkResult = checkState.data;
      if (checkResult != null && !_canSubmitRequest(context, checkResult.column1)) return;
    }

    if (formKey.currentState!.validate()) {
      if (resignationModel != null) {
        context.read<ServicesCubit>().updateResignation(
          UpdateResignationModel(
            requestId: int.tryParse(requestIdController.text) ?? 0,
            empCode: empCode ?? 0,
            requestDate: dateController.text,
            lastWorkDate: lastWorkController.text,
            strNotes: notesController.text,
            attachment: attachmentList,
          ),
        );
      } else {
        context.read<ServicesCubit>().addnewResignationRequest(
          request: ResignationRequestModel(
            empCode: empCode ?? 0,
            requestDate: dateController.text,
            lastWorkDate: lastWorkController.text,
            strNotes: notesController.text,
            attachment: attachmentList,
          ),
        );
      }
    }
  }

  bool _canSubmitRequest(BuildContext context, double column) {
    switch (column) {
      case 136:
        _showToast(context, AppLocalKay.pending_request_error.tr());
        return false;
      case 148:
        _showToast(context, AppLocalKay.substitute_employee_error_1.tr());
        return false;
      case 149:
        _showToast(context, AppLocalKay.substitute_employee_error_2.tr());
        return false;
      default:
        return true;
    }
  }

  void _showToast(BuildContext context, String message) {
    CommonMethods.showToast(message: message, type: ToastType.error);
  }

  void _showToastSuccess(BuildContext context, String message) {
    CommonMethods.showToast(message: message, type: ToastType.success);
  }
}
