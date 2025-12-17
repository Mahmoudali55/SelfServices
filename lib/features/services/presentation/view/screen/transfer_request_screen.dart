import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/services/data/model/transfer/add_new_transfer_request_model.dart';
import 'package:my_template/features/services/data/model/transfer/branch_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/department_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/update_transfer_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_branch_picker_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_department_picker_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_project_picker_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/employee_picker_field.dart';

class TransferRequestScreen extends StatefulWidget {
  const TransferRequestScreen({super.key, this.empCode, this.pagePrivID, this.transferModel});
  final int? empCode;
  final int? pagePrivID;
  final GetAllTransferModel? transferModel;
  @override
  State<TransferRequestScreen> createState() => _TransferRequestScreenState();
}

class _TransferRequestScreenState extends State<TransferRequestScreen> {
  @override
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController requestIdController = TextEditingController();
  final TextEditingController depToIdController = TextEditingController();
  final TextEditingController depToNameController = TextEditingController();
  final TextEditingController depFromIdController = TextEditingController();
  final TextEditingController depFromNameController = TextEditingController();
  final TextEditingController ownerEmpIdController = TextEditingController();
  final TextEditingController ownerEmpNameController = TextEditingController();
  final TextEditingController projectIdController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectIdFromController = TextEditingController();
  final TextEditingController projectNameFromController = TextEditingController();

  final TextEditingController branchIdformController = TextEditingController();
  final TextEditingController branchNameformController = TextEditingController();

  final TextEditingController branchIdController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();

  final TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      final cubit = context.read<ServicesCubit>();
      // تحميل البيانات فقط إذا كانت القائمة فارغة
      if (cubit.state.employeesStatus.data?.isEmpty ?? true) {
        cubit.getEmployees(empcode: widget.empCode ?? 0, privid: widget.pagePrivID ?? 0);
      }

      if (widget.transferModel != null) {
        _initExistingRequest();
      }
    }
  }

  void _initExistingRequest() {
    final model = widget.transferModel!;
    requestIdController.text = model.requestId.toString();
    _dateController.text = model.requestDate ?? '';
    ownerEmpIdController.text = model.empCode.toString();
    ownerEmpNameController.text = context.locale.languageCode == 'ar'
        ? model.empName ?? ''
        : model.empNameE ?? '';
    depFromNameController.text = context.locale.languageCode == 'ar'
        ? model.dName ?? ''
        : model.dNameE ?? '';
    depFromIdController.text = model.tDep.toString();
    branchIdformController.text = model.tBra.toString();
    branchNameformController.text = context.locale.languageCode == 'ar'
        ? model.bName ?? ''
        : model.bNameE ?? '';
    projectIdFromController.text = model.tProj.toString();
    projectNameFromController.text = context.locale.languageCode == 'ar'
        ? model.projName.toString()
        : model.projEName.toString();
    reasonController.text = model.causes1 ?? '';
    depToIdController.text = model.tDep.toString();
    depToNameController.text = context.locale.languageCode == 'ar'
        ? model.toDName ?? ''
        : model.toDNameE ?? '';
    projectIdController.text = model.tProj.toString();
    projectNameController.text = context.locale.languageCode == 'ar'
        ? model.toProjName ?? ''
        : model.toProjNameE ?? '';
    branchIdController.text = model.tBra.toString();
    branchNameController.text = context.locale.languageCode == 'ar'
        ? model.toBName ?? ''
        : model.toBNameE ?? '';
  }

  void _updateVacationData() {
    final empId = (widget.pagePrivID == 1 || widget.pagePrivID == 2)
        ? int.tryParse(ownerEmpIdController.text) ?? 0
        : widget.empCode ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      bottomNavigationBar: BlocListener<ServicesCubit, ServicesState>(
        listener: (context, state) {
          if (widget.transferModel != null) {
            if (state.updataTransferStatus.isSuccess) {
              CommonMethods.showToast(
                message: context.locale.languageCode == 'ar'
                    ? 'تم تعديل طلب نقل بنجاح'
                    : 'Update transfer request successfully',
                type: ToastType.success,
              );
              NavigatorMethods.pushNamedAndRemoveUntil(
                context,
                RoutesName.layoutScreen,
                arguments: {'restoreIndex': 1, 'initialType': 'nqalRequest'},
              );
            } else if (state.updataTransferStatus.isFailure) {
              CommonMethods.showToast(
                message: state.updataTransferStatus.error ?? 'حص',
                type: ToastType.error,
              );
            }
          } else {
            if (state.addnewTransferStatus.isSuccess) {
              CommonMethods.showToast(
                message: context.locale.languageCode == 'ar'
                    ? 'تم تسجيل طلب نقل بنجاح'
                    : 'Submit transfer request successfully',
                type: ToastType.success,
              );
              NavigatorMethods.pushNamedAndRemoveUntil(
                context,
                RoutesName.layoutScreen,
                arguments: {'restoreIndex': 1, 'initialType': 'nqalRequest'},
              );
            }
            if (state.addnewTransferStatus.isFailure) {
              CommonMethods.showToast(
                message: state.addnewTransferStatus.error ?? '',
                type: ToastType.error,
              );
            }
          }
        },
        child: CustomBottomNavButtonWidget(
          newrequest: () {
            _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());

            ownerEmpIdController.clear();
            ownerEmpNameController.clear();
            depFromNameController.clear();
            depFromIdController.clear();
            branchIdformController.clear();
            branchNameformController.clear();
            projectIdFromController.clear();
            projectNameFromController.clear();
            depToIdController.clear();
            depToNameController.clear();
            projectIdController.clear();
            projectNameController.clear();
            branchIdController.clear();
            branchNameController.clear();
            reasonController.clear();
          },
          isLoading:
              context.watch<ServicesCubit>().state.addnewTransferStatus.isLoading ||
              context.watch<ServicesCubit>().state.checkEmpHaveTransferRequestsStatus.isLoading,
          title: widget.transferModel != null ? AppLocalKay.edit.tr() : AppLocalKay.save.tr(),
          color: widget.transferModel != null ? Colors.orange : AppColor.primaryColor(context),
          save: () async {
            await context.read<ServicesCubit>().checkEmpTransferHaveRequests(
              empCode: widget.empCode ?? 0,
            );
            final checkState = context
                .read<ServicesCubit>()
                .state
                .checkEmpHaveTransferRequestsStatus;

            if (widget.transferModel != null && checkState.isSuccess) {
              final checkResult = checkState.data;
              if (checkResult != null) {
                if (checkResult.column1 == 136) {
                  CommonMethods.showToast(
                    message: context.locale.languageCode == 'ar'
                        ? 'عفوا ... هناك طلب مقدم سابقا تحت الاجراء'
                        : 'Employee already has a pending leave request',
                    type: ToastType.error,
                  );
                  return;
                } else if (checkResult.column1 == 148) {
                  CommonMethods.showToast(
                    message: context.locale.languageCode == 'ar'
                        ? 'عفوا ... لا يمكن عمل طلب النقل ... الموظف بديل لموظف اخر لم يعد من نقله بعد'
                        : 'Employee already has a pending leave request',
                    type: ToastType.error,
                  );
                  return;
                } else if (checkResult.column1 == 149) {
                  CommonMethods.showToast(
                    message: context.locale.languageCode == 'ar'
                        ? 'عفوا ... لا يمكن عمل طلب النقل ... الموظف بديل لموظف اخر له طلب نقل مقدم'
                        : 'Employee already has a pending leave request',
                    type: ToastType.error,
                  );
                  return;
                }
              }
            }

            if (_formKey.currentState!.validate()) {
              _updateVacationData();
              if (widget.transferModel != null) {
                context.read<ServicesCubit>().updateTransfer(
                  UpdateTransferRequestModel(
                    requestId: widget.transferModel?.requestId ?? 0,
                    empCode: (widget.pagePrivID == 1 || widget.pagePrivID == 2)
                        ? int.tryParse(ownerEmpIdController.text) ?? 0
                        : widget.empCode ?? 0,
                    tDep: int.tryParse(depToIdController.text) ?? 0,
                    tBra: int.tryParse(branchIdController.text) ?? 0,
                    tProj: int.tryParse(projectIdController.text) ?? 0,
                    requestDate: _dateController.text,
                    causes: reasonController.text,
                    adminEmp: widget.empCode ?? 0,
                  ),
                );
              } else {
                context.read<ServicesCubit>().addnewTransfer(
                  request: AddNewTransferRequestModel(
                    empCode: (widget.pagePrivID == 1 || widget.pagePrivID == 2)
                        ? int.tryParse(ownerEmpIdController.text) ?? 0
                        : widget.empCode ?? 0,
                    tDep: int.tryParse(depToIdController.text) ?? 0,
                    tBra: int.tryParse(branchIdController.text) ?? 0,
                    tProj: int.tryParse(projectIdController.text) ?? 0,
                    requsetDate: _dateController.text,
                    causes: reasonController.text,
                    adminEmp: widget.empCode ?? 0,
                  ),
                );
              }
            }
          },
        ),
      ),
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.transfer.tr(),
        helpText: AppLocalKay.transfer_request_help.tr(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CustomFormField(
                        title: AppLocalKay.requestNumber.tr(),
                        readOnly: true,
                        controller: requestIdController,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                    Expanded(
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        controller: _dateController,
                        readOnly: true,
                        onTap: () async {
                          final DateTime today = DateTime.now();
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(today.year, today.month, today.day),
                            lastDate: DateTime(2100),
                          );

                          final DateTime dateToSet = selectedDate ?? DateTime.now();
                          setState(() {
                            _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(dateToSet);
                          });
                        },

                        title: AppLocalKay.requestDate.tr(),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColor.primaryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),

                EmployeePickerTransferField(
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return AppLocalKay.requestOwner.tr();
                    }
                    return null;
                  },
                  title: AppLocalKay.employee.tr(),
                  idController: ownerEmpIdController,
                  nameController: ownerEmpNameController,
                  onEmployeeSelected: (emp) {
                    ownerEmpIdController.text = emp.empCode.toString();
                    ownerEmpNameController.text = context.locale.languageCode == 'ar'
                        ? emp.empName.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? '' ?? ''
                        : emp.empNameE.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? '' ?? '';
                    ;
                    context.read<ServicesCubit>().selectedEmployee = emp;

                    depFromIdController.text = emp.dCode.toString();
                    depFromNameController.text = context.locale.languageCode == 'ar'
                        ? emp.dName ?? ''
                        : emp.dName ?? '';

                    branchNameformController.text = context.locale.languageCode == 'ar'
                        ? emp.bNameAr ?? ''
                        : emp.bNameEn ?? '';

                    projectNameFromController.text = context.locale.languageCode == 'ar'
                        ? emp.projectName ?? ''
                        : emp.projectNameEn ?? '';

                    _updateVacationData();
                  },
                ),

                Text(
                  AppLocalKay.managerfrom.tr(),
                  style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  readOnly: true,
                  controller: depFromNameController,
                  fillColor: Colors.grey.withAlpha(50),
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  readOnly: true,
                  title: AppLocalKay.departmentfrom.tr(),
                  controller: branchNameformController,
                  fillColor: Colors.grey.withAlpha(50),
                ),

                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  readOnly: true,
                  title: AppLocalKay.projectfrom.tr(),
                  controller: projectNameFromController,
                  fillColor: Colors.grey.withAlpha(50),
                ),
                Text(
                  AppLocalKay.managerTo.tr(),
                  style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        controller: depToIdController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.managerTo.tr() : null,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        controller: depToNameController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.managerTo.tr() : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        branchIdController.clear();
                        branchNameController.clear();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => CustomDepartmentPickerWidget(
                            context: context,
                            departmentIdController: depToIdController,
                            departmentNameController: depToNameController,
                            onDepartmentSelected: (DepartmentModel selectedDept) {
                              depToIdController.text = selectedDept.dCode.toString();
                              depToNameController.text = selectedDept.dName;

                              context.read<ServicesCubit>().getBranchData(
                                deptCode: selectedDept.dCode,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.search, color: AppColor.whiteColor(context)),
                      ),
                    ),
                  ],
                ),
                Text(
                  AppLocalKay.departmentTo.tr(),
                  style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        controller: branchIdController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.departmentTo.tr() : null,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        controller: branchNameController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.departmentTo.tr() : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context.read<ServicesCubit>().getBranchData(
                          deptCode: int.tryParse(depToIdController.text) ?? 0,
                        );
                        final branches =
                            context.read<ServicesCubit>().state.branchStatus.data ?? [];

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (ctx) {
                            return CustomBranchPickerWidget(
                              context: context,
                              branchIdController: branchIdController,
                              branchNameController: branchNameController,
                              onBranchSelected: (BranchDataModel selectedDept) {
                                branchIdController.text = selectedDept.bCode.toString();
                                branchNameController.text = selectedDept.bName;
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.search, color: AppColor.whiteColor(context)),
                      ),
                    ),
                  ],
                ),
                Text(
                  AppLocalKay.projectTo.tr(),
                  style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        controller: projectIdController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.projectTo.tr() : null,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        controller: projectNameController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.projectTo.tr() : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => CustomProjectPickerWidget(
                            context: context,
                            projectIdController: projectIdController,
                            projectNameController: projectNameController,
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.search, color: AppColor.whiteColor(context)),
                      ),
                    ),
                  ],
                ),
                CustomFormField(
                  title: AppLocalKay.transferReason.tr(),
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: reasonController,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
