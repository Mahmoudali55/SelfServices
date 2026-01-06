import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/services/data/model/Cars/add_new_car_request_model.dart';
import 'package:my_template/features/services/data/model/cars/update_car_request_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class CarRequestControllers {
  CarRequestControllers({
    required this.dateController,
    required this.carTypeController,
    required this.reasonController,
    required this.noteController,
    required this.requestIdController,
  });

  final TextEditingController dateController;
  final TextEditingController carTypeController;
  final TextEditingController reasonController;
  final TextEditingController noteController;
  final TextEditingController requestIdController;
}

class CarRequestSaveButton extends StatelessWidget {
  const CarRequestSaveButton({
    super.key,
    required this.formKey,
    required this.empCode,
    required this.isEdit,
    required this.carRequestControllers,
    this.newrequest,
    required this.attachmentList,
  });

  final GlobalKey<FormState> formKey;
  final int? empCode;
  final bool isEdit;
  final CarRequestControllers carRequestControllers;
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
        title: isEdit ? AppLocalKay.edit.tr() : AppLocalKay.save.tr(),
        color: isEdit ? Colors.orange : AppColor.primaryColor(context),
        isLoading: isEdit
            ? context.watch<ServicesCubit>().state.updataCarStatus.isLoading
            : context.watch<ServicesCubit>().state.addnewCarStatus.isLoading,
        save: () => _onSave(context),
      ),
    );
  }

  void _handleState(BuildContext context, ServicesState state) {
    if (isEdit && state.updataCarStatus.isSuccess) {
      _showToastSuccess(context, AppLocalKay.car_request_update_success.tr());
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'siraRequest'},
      );
    } else if (!isEdit && state.addnewCarStatus.isSuccess) {
      _showToastSuccess(context, AppLocalKay.car_request_submit_success.tr());
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'siraRequest'},
      );
    }

    if (state.addnewCarStatus.isFailure) {
      _showToast(context, state.addnewCarStatus.error ?? 'Error');
    }
    if (state.updataCarStatus.isFailure) {
      _showToast(context, state.updataCarStatus.error ?? 'Error');
    }
  }

  void _onSave(BuildContext context) async {
    await context.read<ServicesCubit>().checkEmpCarsHaveRequests(empCode: empCode ?? 0);
    final checkState = context.read<ServicesCubit>().state.checkEmpHaveCarRequestsStatus;

    if (!isEdit && checkState.isSuccess) {
      final checkResult = checkState.data;
      if (checkResult != null && !_canSubmitRequest(context, checkResult.column1)) return;
    }

    if (formKey.currentState!.validate()) {
      if (isEdit) {
        context.read<ServicesCubit>().updateCars(
          UpdateCarRequestModel(
            requestId: int.tryParse(carRequestControllers.requestIdController.text) ?? 0,
            empCode: empCode ?? 0,
            requestDate: carRequestControllers.dateController.text,
            carTypeID: int.parse(carRequestControllers.carTypeController.text),
            purpose: carRequestControllers.reasonController.text,
            strNotes: carRequestControllers.noteController.text,
            attachment: attachmentList,
          ),
        );
      } else {
        context.read<ServicesCubit>().addnewCarRequest(
          request: AddNewCarRequestModel(
            empCode: empCode ?? 0,
            requestDate: carRequestControllers.dateController.text,
            carTypeID: int.parse(carRequestControllers.carTypeController.text),
            purpose: carRequestControllers.reasonController.text,
            strNotes: carRequestControllers.noteController.text,
            attachment: attachmentList,
          ),
        );
      }
    }
  }

  bool _canSubmitRequest(BuildContext context, double column) {
    switch (column) {
      case 131:
        _showToast(context, AppLocalKay.car_already_assigned.tr());
        return false;
      case 132:
        _showToast(context, AppLocalKay.car_request_pending.tr());
        return false;
      case 133:
        _showToast(context, AppLocalKay.car_request_approved_waiting.tr());
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
