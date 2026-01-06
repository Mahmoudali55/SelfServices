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
import 'package:my_template/core/utils/file_viewer_utils.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/transfer/add_new_transfer_request_model.dart';
import 'package:my_template/features/services/data/model/transfer/branch_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/department_data_model.dart';
import 'package:my_template/features/services/data/model/transfer/update_transfer_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_branch_picker_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_department_picker_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_project_picker_widget.dart';

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
        cubit.getEmployees(empcode: widget.empCode ?? 0, privid: 1); // Use privid: 1 as in Home
      }

      if (widget.transferModel != null) {
        _initExistingRequest();
      } else {
        final employees = cubit.state.employeesStatus.data;
        if (employees != null && employees.isNotEmpty) {
          try {
            final currentEmp = employees.firstWhere((e) => e.empCode == widget.empCode);
            _autoFillEmployeeData(currentEmp);
          } catch (_) {
            if (widget.pagePrivID != 1 && widget.pagePrivID != 2 && employees.length == 1) {
              _autoFillEmployeeData(employees.first);
            }
          }
        }
      }
    }
  }

  void _initExistingRequest() {
    final model = widget.transferModel!;
    requestIdController.text = model.requestId.toString();
    _dateController.text = model.requestDate ?? '';
    ownerEmpIdController.text = model.empCode.toString();
    ownerEmpNameController.text = context.locale.languageCode == 'en'
        ? model.empNameE ?? ''
        : model.empName ?? '';
    depFromNameController.text = context.locale.languageCode == 'en'
        ? model.dNameE ?? ''
        : model.dName ?? '';
    depFromIdController.text = model.tDep.toString();
    branchIdformController.text = model.tBra.toString();
    branchNameformController.text = context.locale.languageCode == 'en'
        ? model.bNameE ?? ''
        : model.bName ?? '';
    projectIdFromController.text = model.tProj.toString();
    projectNameFromController.text = context.locale.languageCode == 'en'
        ? model.projEName.toString()
        : model.projName.toString();
    reasonController.text = model.causes1 ?? '';
    depToIdController.text = model.tDep.toString();
    depToNameController.text = context.locale.languageCode == 'en'
        ? model.toDNameE ?? ''
        : model.toDName ?? '';
    projectIdController.text = model.tProj.toString();
    projectNameController.text = context.locale.languageCode == 'en'
        ? model.toProjNameE ?? ''
        : model.toProjName ?? '';
    branchIdController.text = model.tBra.toString();
    branchNameController.text = context.locale.languageCode == 'en'
        ? model.toBNameE ?? ''
        : model.toBName ?? '';
  }

  void _autoFillEmployeeData(EmployeeModel emp) {
    if (widget.transferModel != null) return;
    ownerEmpIdController.text = emp.empCode.toString();
    ownerEmpNameController.text = context.locale.languageCode == 'en'
        ? emp.empNameE?.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? ''
        : emp.empName?.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? '';

    depFromIdController.text = emp.dCode.toString();
    depFromNameController.text = context.locale.languageCode == 'en'
        ? emp.dNameE ?? ''
        : emp.dName ?? '';

    branchIdformController.text = emp.empBranch.toString();
    branchNameformController.text = context.locale.languageCode == 'en'
        ? emp.bNameEn ?? ''
        : emp.bNameAr ?? '';

    projectIdFromController.text = emp.naGroup.toString();
    projectNameFromController.text = context.locale.languageCode == 'en'
        ? emp.projectNameEn ?? ''
        : emp.projectName ?? '';

    context.read<ServicesCubit>().selectedEmployee = emp;
    _updateVacationData();
    setState(() {});
  }

  void _updateVacationData() {
    final empId = (widget.pagePrivID == 1 || widget.pagePrivID == 2)
        ? int.tryParse(ownerEmpIdController.text) ?? 0
        : widget.empCode ?? 0;
  }

  @override
  final attachmentController = TextEditingController();
  List<Map<String, String>> selectedFilesMap = [];
  Widget build(BuildContext context) {
    final List<AttachmentModel> attachmentList = selectedFilesMap.map((file) {
      return AttachmentModel(
        attachmentName: file['AttatchmentName'] ?? '',
        attachmentFileName: file['AttchmentFileName'] ?? '',
      );
    }).toList();
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      bottomNavigationBar: BlocListener<ServicesCubit, ServicesState>(
        listener: (context, state) {
          if (state.employeesStatus.isSuccess && widget.transferModel == null) {
            final employees = state.employeesStatus.data;
            if (employees != null && employees.isNotEmpty) {
              try {
                final currentEmp = employees.firstWhere((e) => e.empCode == widget.empCode);
                _autoFillEmployeeData(currentEmp);
              } catch (_) {
                if (widget.pagePrivID != 1 && widget.pagePrivID != 2 && employees.length == 1) {
                  _autoFillEmployeeData(employees.first);
                }
              }
            }
          }
          if (widget.transferModel != null) {
            if (state.updataTransferStatus.isSuccess) {
              CommonMethods.showToast(
                message: AppLocalKay.transfer_update_success.tr(),
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
                message: AppLocalKay.transfer_submit_success.tr(),
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
                    attachment: attachmentList,
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
                    attachment: attachmentList,
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

                // EmployeePickerTransferField(
                //   currentEmpCode: widget.empCode ?? 0,
                //   validator: (p0) {
                //     if (p0 == null || p0.isEmpty) {
                //       return AppLocalKay.requestOwner.tr();
                //     }
                //     return null;
                //   },
                //   title: AppLocalKay.employee.tr(),
                //   idController: ownerEmpIdController,
                //   nameController: ownerEmpNameController,
                //   onEmployeeSelected: (emp) {
                //     ownerEmpIdController.text = emp.empCode.toString();
                //     ownerEmpNameController.text = context.locale.languageCode == 'ar'
                //         ? emp.empName?.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? ''
                //         : emp.empNameE?.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ?? '';

                //     context.read<ServicesCubit>().selectedEmployee = emp;

                //     depFromIdController.text = emp.dCode.toString();
                //     depFromNameController.text = context.locale.languageCode == 'ar'
                //         ? emp.dName ?? ''
                //         : emp.dNameE ?? '';

                //     branchIdformController.text = emp.empBranch.toString();
                //     branchNameformController.text = context.locale.languageCode == 'ar'
                //         ? emp.bNameAr ?? ''
                //         : emp.bNameEn ?? '';

                //     projectIdFromController.text = emp.naGroup.toString();
                //     projectNameFromController.text = context.locale.languageCode == 'ar'
                //         ? emp.projectName ?? ''
                //         : emp.projectNameEn ?? '';

                //     _updateVacationData();
                //   },
                // ),
                CustomFormField(
                  title: AppLocalKay.employee.tr(),

                  controller: ownerEmpNameController,
                  fillColor: Colors.grey.withAlpha(50),
                ),
                Text(
                  AppLocalKay.managerfrom.tr(),
                  style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

                  controller: depFromNameController,
                  fillColor: Colors.grey.withAlpha(50),
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

                  title: AppLocalKay.departmentfrom.tr(),
                  controller: branchNameformController,
                  fillColor: Colors.grey.withAlpha(50),
                ),

                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

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
                        validator: (value) => value!.isEmpty ? 'id' : null,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
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
                        controller: depToNameController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.managerTo.tr() : null,
                        suffixIcon: Icon(Icons.arrow_drop_down),
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
                        validator: (value) => value!.isEmpty ? 'id' : null,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
                        onTap: () async {
                          if (depToIdController.text.isEmpty) {
                            CommonMethods.showToast(
                              message: context.locale.languageCode == 'ar'
                                  ? 'لابد من اختيار الإدارة أولاً'
                                  : 'Please select department first',
                              type: ToastType.error,
                            );
                            return;
                          }
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
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        controller: branchNameController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.departmentTo.tr() : null,
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
                        validator: (value) => value!.isEmpty ? 'id' : null,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        readOnly: true,
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
                        controller: projectNameController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.projectTo.tr() : null,
                        suffixIcon: Icon(Icons.arrow_drop_down),
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
                Row(
                  children: [
                    Expanded(
                      child: CustomFileFormFieldChips(
                        controller: attachmentController,
                        onFilesChanged: (files) {
                          setState(() {
                            selectedFilesMap = files;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    widget.transferModel == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: GestureDetector(
                              onTap: () async {
                                final cubit = context.read<ServicesCubit>();

                                await cubit.getAttachments(
                                  requestId: widget.transferModel!.requestId,
                                  attchmentType: 810,
                                );

                                final state = cubit.state;
                                if (state.vacationAttachmentsStatus != null &&
                                    state.vacationAttachmentsStatus!.isSuccess) {
                                  List<VacationAttachmentItem> attachments =
                                      List<VacationAttachmentItem>.from(
                                        state.vacationAttachmentsStatus!.data ?? [],
                                      );

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (bottomSheetContext) {
                                      return StatefulBuilder(
                                        builder: (ctx, setStateSheet) {
                                          Future<void> refreshAttachments() async {
                                            await cubit.getAttachments(
                                              requestId: widget.transferModel!.requestId,
                                              attchmentType: 810,
                                            );
                                            final newState = cubit.state;
                                            if (newState.vacationAttachmentsStatus != null &&
                                                newState.vacationAttachmentsStatus!.isSuccess) {
                                              setStateSheet(() {
                                                attachments = List<VacationAttachmentItem>.from(
                                                  newState.vacationAttachmentsStatus!.data ?? [],
                                                );
                                              });
                                            } else {}
                                          }

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context).viewInsets.bottom,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(height: 12),
                                                Text(
                                                  context.locale.languageCode == 'ar'
                                                      ? 'المرفقات'
                                                      : 'Attachments',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (attachments.isEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Text(
                                                      context.locale.languageCode == 'ar'
                                                          ? 'لا توجد مرفقات'
                                                          : 'No attachments',
                                                    ),
                                                  )
                                                else
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: attachments.length,
                                                    itemBuilder: (context, index) {
                                                      final item = attachments[index];
                                                      return ListTile(
                                                        leading: IconButton(
                                                          icon: const Icon(Icons.remove_red_eye),
                                                          onPressed: () async {
                                                            final cubit = context
                                                                .read<ServicesCubit>();

                                                            await cubit.imageFileName(
                                                              item.attchmentFileName,
                                                              context,
                                                            );
                                                            final stateStatus =
                                                                cubit.state.imageFileNameStatus;

                                                            if (stateStatus?.isSuccess == true) {
                                                              final base64File =
                                                                  stateStatus?.data ?? '';

                                                              await FileViewerUtils.displayFile(
                                                                context,
                                                                base64File,
                                                                item.attchmentFileName,
                                                              );
                                                            } else if (stateStatus?.isFailure ==
                                                                true) {
                                                              showDialog(
                                                                context: context,
                                                                builder: (_) => AlertDialog(
                                                                  content: Text(
                                                                    stateStatus?.error ?? '',
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              showDialog(
                                                                context: context,
                                                                builder: (_) => const AlertDialog(
                                                                  content:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        title: Text(item.attatchmentName),
                                                        trailing: IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () async {
                                                            await cubit.deleteAttachment(
                                                              requestId:
                                                                  widget.transferModel!.requestId,
                                                              attachId: item.ser,
                                                              context: context,
                                                              attchmentType: 810,
                                                            );

                                                            await refreshAttachments();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                const SizedBox(height: 12),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  CommonMethods.showToast(
                                    message: context.locale.languageCode == 'ar'
                                        ? 'حدث خطأ أثناء تحميل الملفات'
                                        : 'Failed to load attachments',
                                    type: ToastType.error,
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 30),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor(context),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.search, color: AppColor.whiteColor(context)),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
