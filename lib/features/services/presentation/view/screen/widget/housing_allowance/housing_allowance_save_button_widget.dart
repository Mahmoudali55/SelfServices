import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/services/data/model/housing_allowance/housing_allowance_request_model.dart';
import 'package:my_template/features/services/data/model/housing_allowance/update_housing_allowance_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class HousingAllowanceControllers {
  HousingAllowanceControllers({
    required this.dateController,
    required this.noteController,
    required this.amountController,
    required this.requestIdController,
    required this.selectedPlaceNotifier,
    required this.travelPlaceValues,
  });

  final TextEditingController dateController;
  final TextEditingController noteController;
  final TextEditingController amountController;
  final TextEditingController requestIdController;
  final ValueNotifier<String?> selectedPlaceNotifier;
  final Map<String, int> travelPlaceValues;
}

class HousingAllowanceSaveButton extends StatelessWidget {
  const HousingAllowanceSaveButton({
    super.key,
    required this.formKey,
    required this.empCode,
    required this.isEdit,
    required this.controllers,
    this.newrequest,
    required this.attachmentList,
  });

  final GlobalKey<FormState> formKey;
  final int? empCode;
  final bool isEdit;
  final HousingAllowanceControllers controllers;
  final void Function()? newrequest;
  final List<AttachmentModel> attachmentList;
  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) => _handleState(context, state),
      child: ValueListenableBuilder<String?>(
        valueListenable: controllers.selectedPlaceNotifier,
        builder: (_, selectedPlace, __) {
          return CustomBottomNavButtonWidget(
            newrequest: newrequest,
            title: isEdit ? AppLocalKay.edit.tr() : AppLocalKay.save.tr(),
            color: isEdit ? Colors.orange : AppColor.primaryColor(context),
            save: () => _onSave(context),
            isLoading: isEdit
                ? context.watch<ServicesCubit>().state.updataHousingAllowanceStatus.isLoading
                : context.watch<ServicesCubit>().state.housingAllowanceStatus.isLoading,
          );
        },
      ),
    );
  }

  void _handleState(BuildContext context, ServicesState state) {
    if (isEdit && state.updataHousingAllowanceStatus.isSuccess) {
      _showToastSuccess(
        context,
        'تم تعديل طلب صرف بدل سكن بنجاح',
        'Update housing allowance request successfully',
      );
      _navigateToLayout(context);
    } else if (!isEdit && state.housingAllowanceStatus.isSuccess) {
      _showToastSuccess(
        context,
        'تم حفظ طلب صرف بدل سكن بنجاح',
        'Submit housing allowance request successfully',
      );
      _navigateToLayout(context);
    }

    if (state.housingAllowanceStatus.isFailure) {
      _showToast(context, state.housingAllowanceStatus.error ?? 'Error');
    }
  }

  void _navigateToLayout(BuildContext context) {
    NavigatorMethods.pushNamedAndRemoveUntil(
      context,
      RoutesName.layoutScreen,
      arguments: {'restoreIndex': 1, 'initialType': 'deductionRequest'},
    );
  }

  Future<void> _onSave(BuildContext context) async {
    // تأكد من اختيار نوع البدل
    final selectedPlace = controllers.selectedPlaceNotifier.value;
    if (selectedPlace == null) {
      _showToast(context, 'الرجاء اختيار نوع البدل', 'Please select allowance type');
      return;
    }

    // تحقق من صحة الفورم
    if (!formKey.currentState!.validate()) return;

    // استدعاء API للتحقق من الطلبات السابقة
    await context.read<ServicesCubit>().checkEmpBackHaveRequestsBadalsakan(empCode: empCode ?? 0);
    final checkState = context.read<ServicesCubit>().state.checkEmpHaveBadalSakanRequestsStatus;

    if (!isEdit && checkState.isSuccess) {
      final checkResult = checkState.data;
      if (checkResult != null && !_canSubmitRequest(context, checkResult.column1)) return;
    }

    // تحويل التاريخ
    String formattedDate = controllers.dateController.text;
    try {
      formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parse(controllers.dateController.text));
    } catch (_) {}

    final int amountType = controllers.travelPlaceValues[selectedPlace]!;

    // إرسال البيانات
    if (isEdit) {
      context.read<ServicesCubit>().updateHousingAllowance(
        UpdateHousingAllowanceRequestModel(
          empCode: empCode ?? 0,
          requestDate: formattedDate,
          sakanAmount: double.tryParse(controllers.amountController.text) ?? 0,
          strNotes: controllers.noteController.text,
          amountType: amountType,
          requestId: int.tryParse(controllers.requestIdController.text) ?? 0,
          attachment: attachmentList,
        ),
      );
    } else {
      context.read<ServicesCubit>().addnewHousingallowanceRequest(
        request: HousingAllowanceRequestModel(
          empCode: empCode ?? 0,
          requestDate: formattedDate,
          sakanAmount: double.tryParse(controllers.amountController.text) ?? 0,
          strNotes: controllers.noteController.text,
          amountType: amountType,
          attachment: attachmentList,
        ),
      );
    }
  }

  bool _canSubmitRequest(BuildContext context, double column) {
    switch (column) {
      case 136:
        _showToast(
          context,
          'عفوا ... هناك طلب مقدم سابقا تحت الاجراء',
          'Employee already has a pending leave request',
        );
        return false;
      case 148:
        _showToast(
          context,
          'عفوا ... الموظف بديل لموظف اخر لم يعد من اجازته بعد',
          'Employee already has a pending leave request',
        );
        return false;
      case 149:
        _showToast(
          context,
          'عفوا ... الموظف بديل لموظف اخر له طلب اجازه مقدم',
          'Employee already has a pending leave request',
        );
        return false;
      default:
        return true;
    }
  }

  void _showToast(BuildContext context, String ar, [String? en]) {
    CommonMethods.showToast(
      message: context.locale.languageCode == 'ar' ? ar : (en ?? ar),
      type: ToastType.error,
    );
  }

  void _showToastSuccess(BuildContext context, String ar, [String? en]) {
    CommonMethods.showToast(
      message: context.locale.languageCode == 'ar' ? ar : (en ?? ar),
      type: ToastType.success,
    );
  }
}
