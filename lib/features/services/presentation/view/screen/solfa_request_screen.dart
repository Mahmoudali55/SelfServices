import 'dart:convert';
import 'dart:io';

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
import 'package:my_template/features/request_history/data/model/get_solfa_model.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/add_new_solf_request_model.dart';
import 'package:my_template/features/services/data/model/solfa_request/update_solfa_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/solfe/custom_Lone_all_employee_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/solfe/solfa_selector_drop_dowen_widget.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class solfaRequestScreen extends StatefulWidget {
  const solfaRequestScreen({super.key, required this.empId, this.solfaItem});
  final int empId;
  final SolfaItem? solfaItem;
  @override
  State<solfaRequestScreen> createState() => _solfaRequestScreenState();
}

class _solfaRequestScreenState extends State<solfaRequestScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController solfaTypeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController installmentsController = TextEditingController();
  final TextEditingController installmentAmountController = TextEditingController();
  final TextEditingController _discountDateController = TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController requestIdController = TextEditingController();

  EmployeeModel? selectedEmployee;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);
    context.read<ServicesCubit>().getSofaType();

    amountController.addListener(_updateInstallmentAmount);
    installmentsController.addListener(_updateInstallmentAmount);
    context.read<ServicesCubit>().checkEmpSolfaHaveRequests(empCode: widget.empId);
    _initExistingRequest();
  }

  void _updateInstallmentAmount() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final installments = int.tryParse(installmentsController.text) ?? 0;

    if (installments > 0) {
      final installmentAmount = amount / installments;
      installmentAmountController.text = installmentAmount.toStringAsFixed(2);
    } else {
      installmentAmountController.text = '';
    }
  }

  void _initExistingRequest() {
    if (widget.solfaItem == null) return;
    final model = widget.solfaItem!;
    requestIdController.text = model.requestId.toString();
    if (model.requestDate.isNotEmpty) {
      try {
        final parsedDate = DateFormat('dd/MM/yyyy', 'en').parse(model.requestDate);
        _dateController.text = DateFormat('yyyy-M-d', 'en').format(parsedDate);
      } catch (_) {
        _dateController.text = model.requestDate;
      }
    }
    solfaTypeController.text = model.solfaTypeName;
    amountController.text = model.solfaAmount.toString();
    installmentsController.text = model.dofaaCount.toString();
    installmentAmountController.text = model.dofaaAmount.toString();
    if (model.startDicountDate != null && model.startDicountDate!.isNotEmpty) {
      try {
        final parsedDiscountDate = DateFormat('dd/MM/yyyy', 'en').parse(model.startDicountDate!);
        _discountDateController.text = DateFormat('yyyy-M-d', 'en').format(parsedDiscountDate);
      } catch (_) {
        _discountDateController.text = model.startDicountDate!;
      }
    } else {
      _discountDateController.text = '';
    }
    empIdController.text = model.frstEmpCode.toString();
    empNameController.text = model.frstEmpName ?? '';
    emp2IdController.text = model.scndEmpCode.toString();
    emp2NameController.text = model.scndEmpName ?? '';
    noteController.text = model.strNotes;
  }

  @override
  void dispose() {
    _dateController.dispose();
    solfaTypeController.dispose();
    amountController.dispose();
    installmentsController.dispose();
    installmentAmountController.dispose();
    _discountDateController.dispose();
    empIdController.dispose();
    empNameController.dispose();
    super.dispose();
  }

  void _openEmployeeSearch() {
    final cubit = context.read<ServicesCubit>();
    // تحميل البيانات فقط إذا كانت القائمة فارغة
    if (cubit.state.employeeListStatus.data?.isEmpty ?? true) {
      cubit.getEmployeeList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CustomSolfeAllEmployeeWidgetLight(
          context: context,
          empIdController: empIdController,
          empNameController: empNameController,
        );
      },
    );
  }

  final TextEditingController emp2IdController = TextEditingController();
  final TextEditingController emp2NameController = TextEditingController();

  void _openEmployee2Search() {
    final cubit = context.read<ServicesCubit>();
    // تحميل البيانات فقط إذا كانت القائمة فارغة
    if (cubit.state.employeeListStatus.data?.isEmpty ?? true) {
      cubit.getEmployeeList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CustomSolfeAllEmployeeWidgetLight(
          context: context,
          empIdController: emp2IdController,
          empNameController: emp2NameController,
        );
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final attachmentController = TextEditingController();
  List<Map<String, String>> selectedFilesMap = [];
  @override
  Widget build(BuildContext context) {
    final List<AttachmentModel> attachmentList = selectedFilesMap.map((file) {
      return AttachmentModel(
        attachmentName: file['AttatchmentName'] ?? '',
        attachmentFileName: file['AttchmentFileName'] ?? '',
      );
    }).toList();
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: AppColor.whiteColor(context),
        bottomNavigationBar: BlocListener<ServicesCubit, ServicesState>(
          listener: (context, state) {
            if (widget.solfaItem != null) {
              if (state.updataSolfaStatus.isSuccess) {
                CommonMethods.showToast(
                  message: context.locale.languageCode == 'ar'
                      ? 'تم تعديل طلب السلفة بنجاح'
                      : 'Update loan request successfully',
                  type: ToastType.success,
                );
                NavigatorMethods.pushNamedAndRemoveUntil(
                  context,
                  RoutesName.layoutScreen,
                  arguments: {'restoreIndex': 1, 'initialType': 'solfaRequest'},
                );
              } else if (state.updataSolfaStatus.isFailure) {
                CommonMethods.showToast(
                  message: state.updataSolfaStatus.error ?? 'حص',
                  type: ToastType.error,
                );
              }
            } else {
              if (state.loanRequestStatus.isSuccess) {
                CommonMethods.showToast(
                  message: context.locale.languageCode == 'ar'
                      ? 'تم تسجيل طلب السلفة بنجاح'
                      : 'Submit vacation request successfully',
                  type: ToastType.success,
                );
                NavigatorMethods.pushNamedAndRemoveUntil(
                  context,
                  RoutesName.layoutScreen,
                  arguments: {'restoreIndex': 1, 'initialType': 'solfaRequest'},
                );
              }
              if (state.loanRequestStatus.isFailure) {
                CommonMethods.showToast(
                  message: state.loanRequestStatus.error ?? '',
                  type: ToastType.error,
                );
              }
            }
          },
          child: CustomBottomNavButtonWidget(
            title: widget.solfaItem != null ? AppLocalKay.edit.tr() : AppLocalKay.save.tr(),
            color: widget.solfaItem != null ? Colors.orange : AppColor.primaryColor(context),
            save: () async {
              if (!_formKey.currentState!.validate()) return;

              final cubit = context.read<ServicesCubit>();

              if (widget.solfaItem == null) {
                await cubit.checkEmpSolfaHaveRequests(empCode: widget.empId);

                final checkState = cubit.state.checkEmpHaveSolfaRequestsStatus;

                if (checkState.isSuccess) {
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
                            ? 'عفوا ... لا يمكن عمل طلب الاجازة ... الموظف بديل لموظف اخر لم يعد من اجازته بعد'
                            : 'Employee already has a pending leave request',
                        type: ToastType.error,
                      );
                      return;
                    } else if (checkResult.column1 == 149) {
                      CommonMethods.showToast(
                        message: context.locale.languageCode == 'ar'
                            ? 'عفوا ... لا يمكن عمل طلب الاجازة ... الموظف بديل لموظف اخر له طلب اجازه مقدم'
                            : 'Employee already has a pending leave request',
                        type: ToastType.error,
                      );
                      return;
                    }
                  }
                } else if (checkState.isFailure) {
                  CommonMethods.showToast(message: checkState.error ?? '', type: ToastType.error);
                  return;
                }
              }

              if (widget.solfaItem != null) {
                cubit.updataSolfaRequest(
                  UpdateSolfaModel(
                    empCode: widget.empId,
                    requestDate: _dateController.text,
                    solfaAmount: double.tryParse(amountController.text) ?? 0,
                    dofaaCount: int.tryParse(installmentsController.text) ?? 0,
                    dofaaAmount: double.tryParse(installmentAmountController.text) ?? 0,
                    startDicountDate: _discountDateController.text,
                    frstEmpCode: int.tryParse(empIdController.text) ?? 0,
                    scndEmpCode: int.tryParse(emp2IdController.text) ?? 0,
                    strNotes: noteController.text,
                    solfaTypeId: int.tryParse(solfaTypeController.text) ?? 0,
                    requestAuditorId: widget.empId,
                    requestId: widget.solfaItem!.requestId,
                    attachment: attachmentList,
                  ),
                );
              } else {
                cubit.addNewSolfaRequest(
                  request: AddNewSolfaRquestModel(
                    empCode: widget.empId,
                    requestDate: _dateController.text,
                    solfaAmount: double.tryParse(amountController.text) ?? 0,
                    dofaaCount: int.tryParse(installmentsController.text) ?? 0,
                    dofaaAmount: double.tryParse(installmentAmountController.text) ?? 0,
                    startDicountDate: _discountDateController.text,
                    frstEmpCode: int.tryParse(empIdController.text) ?? 0,
                    scndEmpCode: int.tryParse(emp2IdController.text) ?? 0,
                    strNotes: noteController.text,
                    solfaTypeid: int.tryParse(solfaTypeController.text) ?? 0,
                    requestAuditorID: widget.empId,
                    attachment: attachmentList,
                  ),
                );
              }
            },
            isLoading: widget.solfaItem != null
                ? context.watch<ServicesCubit>().state.updataSolfaStatus.isLoading
                : context.watch<ServicesCubit>().state.loanRequestStatus.isLoading,
            newrequest: () {
              _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
              amountController.clear();
              installmentsController.clear();
              installmentAmountController.clear();
              _discountDateController.clear();
              empIdController.clear();
              empNameController.clear();
              emp2IdController.clear();
              emp2NameController.clear();
              noteController.clear();
              solfaTypeController.clear();
            },
          ),
        ),
        appBar: CustomAppBarServicesWidget(
          context,
          title: AppLocalKay.loanrequest.tr(),
          helpText: AppLocalKay.solfa_request_help.tr(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: CustomFormField(
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        title: AppLocalKay.requestNumber.tr(),
                        readOnly: true,
                        hintText: context.locale.languageCode == 'ar' ? 'تلقائي' : 'Auto',
                        controller: requestIdController,
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
                          if (selectedDate != null) {
                            setState(() {
                              _dateController.text = DateFormat(
                                'yyyy-MM-dd',
                                'en',
                              ).format(selectedDate);
                            });
                          }
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
                Text(
                  AppLocalKay.loantype.tr(),
                  style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
                ),
                SolfaSelectorDropdown(controller: solfaTypeController),

                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: amountController,
                  title: AppLocalKay.loanamount.tr(),
                  keyboardType: TextInputType.number,
                  validator: (p0) => p0!.isEmpty ? AppLocalKay.loanamount.tr() : null,
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: installmentsController,
                  title: AppLocalKay.loaninstallments.tr(),
                  keyboardType: TextInputType.number,
                  validator: (p0) => p0!.isEmpty ? AppLocalKay.loaninstallments.tr() : null,
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: installmentAmountController,
                  title: AppLocalKay.installmentamount.tr(),
                  readOnly: true,
                  validator: (p0) => p0!.isEmpty ? AppLocalKay.installmentamount.tr() : null,
                ),
                CustomFormField(
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: _discountDateController,
                  readOnly: true,
                  validator: (p0) => p0!.isEmpty ? AppLocalKay.discountdate.tr() : null,
                  title: AppLocalKay.discountdate.tr(),
                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
                  onTap: () async {
                    final DateTime today = DateTime.now();
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(today.year, today.month, today.day),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _discountDateController.text = DateFormat(
                          'yyyy-MM-dd',
                          'en',
                        ).format(selectedDate);
                      });
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      AppLocalKay.collateral.tr(),
                      style: AppTextStyle.formTitleStyle(
                        context,
                        color: AppColor.blackColor(context),
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomFormField(
                            controller: empIdController,
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                            readOnly: true,
                            hintText: 'ID',
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: CustomFormField(
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                            controller: empNameController,
                            readOnly: true,
                            hintText: AppLocalKay.collateralname.tr(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalKay.collateralname.tr();
                              }

                              if (empIdController.text == widget.empId.toString()) {
                                return context.locale.languageCode == 'ar'
                                    ? 'لا يمكن لصاحب الطلب أن يكون ضامنًا لنفسه'
                                    : 'The applicant cannot be a guarantor for himself';
                              }

                              return null;
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: _openEmployeeSearch,
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
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      AppLocalKay.collateral2.tr(),
                      style: AppTextStyle.formTitleStyle(
                        context,
                        color: AppColor.blackColor(context),
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomFormField(
                            controller: emp2IdController,
                            readOnly: true,
                            hintText: 'ID',
                            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Expanded(
                            flex: 4,
                            child: CustomFormField(
                              controller: emp2NameController,
                              readOnly: true,
                              hintText: AppLocalKay.collateralname2.tr(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalKay.collateral2.tr();
                                }

                                if (empIdController.text.isNotEmpty &&
                                    empIdController.text == emp2IdController.text) {
                                  return context.locale.languageCode == 'ar'
                                      ? 'لا يمكن اختيار نفس الضامن مرتين'
                                      : 'First and second guarantor cannot be the same';
                                }

                                return null;
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openEmployee2Search,
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
                  ],
                ),
                CustomFormField(
                  title: AppLocalKay.notes.tr(),
                  controller: noteController,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                    widget.solfaItem == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 55),
                            child: GestureDetector(
                              onTap: () async {
                                final cubit = context.read<ServicesCubit>();

                                await cubit.getAttachments(
                                  requestId: widget.solfaItem!.requestId,
                                  attchmentType: 17,
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
                                              requestId: widget.solfaItem!.requestId,
                                              attchmentType: 17,
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

                                                              await openBase64File(
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
                                                                  widget.solfaItem!.requestId,
                                                              attachId: item.ser,
                                                              context: context,
                                                              attchmentType: 17,
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

  Future<void> openBase64File(String base64String, String fileName) async {
    try {
      final bytes = base64Decode(base64String);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      await OpenFilex.open(file.path);
    } catch (e) {}
  }
}
