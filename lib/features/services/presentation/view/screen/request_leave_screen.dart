import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_updata.dart'
    hide AttachmentModel;
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/employee_picker_field.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/leave_selector_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/services_Input_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/vacation_balance_field.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RequestLeaveScreen extends StatefulWidget {
  const RequestLeaveScreen({
    super.key,
    this.pagePrivID,
    this.empCode,
    this.vacationRequestOrdersModel,
    this.username,
  });
  final int? pagePrivID;
  final int? empCode;
  final String? username;
  final VacationRequestOrdersModel? vacationRequestOrdersModel;

  @override
  State<RequestLeaveScreen> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends State<RequestLeaveScreen> {
  final _dateController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _daysController = TextEditingController();
  final _balanceController = TextEditingController();
  final _ballController = TextEditingController();
  final ownerEmpIdController = TextEditingController();
  final ownerEmpNameController = TextEditingController();
  final transferEmpIdController = TextEditingController();
  final transferEmpNameController = TextEditingController();
  final _servicesController = TextEditingController();
  final leaveIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final attachmentController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, String>> _services = [];
  List<Map<String, String>> selectedFilesMap = [];

  final _requestNumber = TextEditingController();
  void _loadAttachmentsToField() async {
    if (widget.vacationRequestOrdersModel != null) {
      final cubit = context.read<ServicesCubit>();
      await cubit.getAttachments(
        requestId: widget.vacationRequestOrdersModel!.vacRequestId,
        attchmentType: 14,
      );

      final state = cubit.state;
      if (state.vacationAttachmentsStatus != null && state.vacationAttachmentsStatus!.isSuccess) {
        final attachments = state.vacationAttachmentsStatus!.data ?? [];

        setState(() {
          attachmentController.text = attachments.map((e) => e.attatchmentName).join(', ');
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ServicesCubit>();
    cubit.getLeaves();

    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
    if (widget.vacationRequestOrdersModel != null) {
      _initExistingRequest();
      _loadAttachmentsToField();
    } else {
      cubit.getallServices();
    }
  }

  void _initExistingRequest() {
    context.read<ServicesCubit>().getServices(
      requestId: widget.vacationRequestOrdersModel?.vacRequestId,
    );
    context
        .read<ServicesCubit>()
        .getServices(requestId: widget.vacationRequestOrdersModel?.vacRequestId)
        .then((_) {
          final servicesList = context.read<ServicesCubit>().state.servicesStatus.data ?? [];

          setState(() {
            _services.clear();
            _services.addAll(
              servicesList.map(
                (e) => {
                  'id': e.id.toString(),
                  'servcdesc': context.locale.languageCode == 'ar'
                      ? e.serviceDesc ?? ''
                      : e.serviceDescEn ?? '',
                },
              ),
            );

            _servicesController.text = _services
                .map((e) => e['servcdesc'])
                .where((element) => element != null && element.isNotEmpty)
                .join(', ');
          });
        });
    final model = widget.vacationRequestOrdersModel!;
    _requestNumber.text = model.vacRequestId.toString();
    _startDateController.text = model.strVacRequestDateFrom;
    _endDateController.text = model.strVacRequestDateTo;
    _daysController.text = model.vacDayCount.toString();
    _notesController.text = model.strNotes;
    leaveIdController.text = model.vacTypeId.toString();

    ownerEmpIdController.text = model.empCode.toString();
    ownerEmpNameController.text = model.empName;
    transferEmpIdController.text = model.alternativeEmpCode.toString();
    transferEmpNameController.text = model.alternativeEmpName;
    _startDate = DateTime.tryParse(model.vacRequestDateFrom);
    _endDate = DateTime.tryParse(model.vacRequestDateTo);
    if (_startDate != null && _endDate != null) {
      _updateVacationData();
    }
  }

  void _calculateDays() {
    try {
      DateTime? start =
          _startDate ??
          (_startDateController.text.isNotEmpty
              ? DateFormat('yyyy-MM-dd', 'en').parse(_startDateController.text)
              : null);

      DateTime? end =
          _endDate ??
          (_endDateController.text.isNotEmpty
              ? DateFormat('yyyy-MM-dd', 'en').parse(_endDateController.text)
              : null);

      if (start != null && end != null) {
        final days = end.difference(start).inDays + 1;
        _daysController.text = days.toString();
      }
    } catch (e) {
      _daysController.text = '0';
    }
  }

  void _updateVacationData() {
    final cubit = context.read<ServicesCubit>();

    int empId;
    if (widget.pagePrivID == 1 || widget.pagePrivID == 2) {
      empId = int.tryParse(ownerEmpIdController.text) ?? 0;
    } else {
      empId = widget.empCode ?? 0;
    }

    if (empId == 0 || _startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      return;
    }

    try {
      final start = _startDate ?? DateFormat('yyyy-MM-dd', 'en').parse(_startDateController.text);
      final end = _endDate ?? DateFormat('yyyy-MM-dd', 'en').parse(_endDateController.text);

      cubit.getEmployeeVacations(empCode: empId, bnDate: start, edDate: end);
      cubit.getEmployeeBal(empCode: empId, bnDate: start, edDate: end);
    } catch (e) {}
  }

  Future<void> _showDatePickerDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400.h,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: _startDate != null && _endDate != null
                  ? PickerDateRange(_startDate, _endDate)
                  : null,

              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final PickerDateRange range = args.value;

                  if (range.endDate != null) {
                    setState(() {
                      _startDate = range.startDate;
                      _endDate = range.endDate;
                      _startDateController.text = DateFormat(
                        'yyyy-MM-dd',
                        'en',
                      ).format(_startDate!);
                      _endDateController.text = DateFormat('yyyy-MM-dd', 'en').format(_endDate!);
                      _calculateDays();
                    });

                    _updateVacationData();
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _daysController.dispose();
    _balanceController.dispose();
    _ballController.dispose();
    ownerEmpIdController.dispose();
    ownerEmpNameController.dispose();
    transferEmpIdController.dispose();
    transferEmpNameController.dispose();
    _servicesController.dispose();
    leaveIdController.dispose();
    _notesController.dispose();
    _requestNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesCubit, ServicesState>(
      listener: (context, state) {
        if (state.submitVacationStatus.isSuccess) {
          final response = state.submitVacationStatus.data;
          if (response != null) {
            _requestNumber.text = response.reqNo.toString();
          }

          CommonMethods.showToast(
            message: context.locale.languageCode == 'ar'
                ? 'تم تسجيل طلب الإجازة بنجاح'
                : 'Submit vacation request successfully',
            type: ToastType.success,
          );
        }
        if (state.submitVacationStatus.isFailure) {
          final error = state.submitVacationStatus.error ?? 'حص';
          CommonMethods.showToast(message: error, type: ToastType.error);
        }
      },
      builder: (context, state) {
        final formattedServices = _services
            .map(
              (e) => {
                'id': int.tryParse(e['id']?.toString() ?? '') ?? 0,
                'servcdesc': e['servcdesc']?.toString() ?? '',
              },
            )
            .toList();
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
                if (widget.vacationRequestOrdersModel != null) {
                  if (state.updataVacationStatus.isSuccess) {
                    final response = state.updataVacationStatus.data;
                    if (response != null) {
                      _requestNumber.text = response.reqNo.toString();
                    }
                    CommonMethods.showToast(
                      message: context.locale.languageCode == 'ar'
                          ? 'تم تعديل طلب الإجازة بنجاح'
                          : 'Submit vacation request successfully',
                      type: ToastType.success,
                    );
                    NavigatorMethods.pushNamedAndRemoveUntil(
                      context,
                      RoutesName.layoutScreen,
                      arguments: {'restoreIndex': 1, 'initialType': 'leavesRequest'},
                    );
                  }
                  if (state.submitVacationStatus.isFailure) {
                    final error = state.submitVacationStatus.error ?? 'حص';
                    CommonMethods.showToast(message: error, type: ToastType.error);
                  }
                } else {
                  if (state.submitVacationStatus.isSuccess) {
                    final response = state.submitVacationStatus.data;
                    if (response != null) {
                      _requestNumber.text = response.reqNo.toString();
                    }
                    CommonMethods.showToast(
                      message: context.locale.languageCode == 'ar'
                          ? 'تم تسجيل طلب الإجازة بنجاح'
                          : 'Submit vacation request successfully',
                      type: ToastType.success,
                    );
                    NavigatorMethods.pushNamedAndRemoveUntil(
                      context,
                      RoutesName.layoutScreen,
                      arguments: {'restoreIndex': 1, 'initialType': 'leavesRequest'},
                    );
                  }
                  if (state.submitVacationStatus.isFailure) {
                    final error = state.submitVacationStatus.error ?? 'حص';
                    CommonMethods.showToast(message: error, type: ToastType.error);
                  }
                }
              },
              child: CustomBottomNavButtonWidget(
                title: widget.vacationRequestOrdersModel != null
                    ? AppLocalKay.edit.tr()
                    : AppLocalKay.save.tr(),
                color: widget.vacationRequestOrdersModel != null
                    ? Colors.orange
                    : AppColor.primaryColor(context),
                isLoading: widget.vacationRequestOrdersModel != null
                    ? context.watch<ServicesCubit>().state.updataVacationStatus.isLoading
                    : context.watch<ServicesCubit>().state.submitVacationStatus.isLoading,
                save: () async {
                  if (_formKey.currentState!.validate()) {
                    await context.read<ServicesCubit>().checkEmpHaveRequests(
                      empCode: widget.pagePrivID == 1 || widget.pagePrivID == 2
                          ? int.tryParse(ownerEmpIdController.text) ?? 0
                          : widget.empCode ?? 0,
                    );

                    final checkState = context
                        .read<ServicesCubit>()
                        .state
                        .checkEmpHaveRequestsStatus;

                    if (widget.vacationRequestOrdersModel == null && checkState.isSuccess) {
                      final checkResult = checkState.data;

                      if (checkResult != null && checkResult.column1 == 136) {
                        CommonMethods.showToast(
                          message: context.locale.languageCode == 'ar'
                              ? 'عفوا ... هناك طلب مقدم سابقا تحت الاجراء'
                              : 'Employee already has a pending leave request',
                          type: ToastType.error,
                        );
                        return;
                      } else if (checkResult != null && checkResult.column1 == 148) {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            content: Text(
                              context.locale.languageCode == 'ar'
                                  ? 'هل تريد الاستمرار في عمل طلب الاجازة؟'
                                  : 'Do you want to continue with the leave request?',
                              style: AppTextStyle.text14RGrey(context),
                            ),
                            title: Text(
                              context.locale.languageCode == 'ar'
                                  ? 'عفوا ... لا يمكن عمل طلب الاجازة ... الموظف بديل لموظف اخر لم يعد من اجازته بعد'
                                  : 'Employee already has a pending leave request',
                              style: AppTextStyle.text16MSecond(context),
                            ),
                            actions: [
                              CustomButton(
                                color: Colors.red,
                                onPressed: () => Navigator.pop(context, false),
                                text: context.locale.languageCode == 'ar' ? 'لا' : 'No',
                                radius: 12.r,
                              ),
                              SizedBox(height: 10.w),
                              CustomButton(
                                onPressed: () async {
                                  if (widget.vacationRequestOrdersModel != null) {
                                    await context.read<ServicesCubit>().updataVacationRequest(
                                      VacationRequestUpdateModel(
                                        requestId: int.tryParse(_requestNumber.text) ?? 0,
                                        empCode: widget.pagePrivID != 1
                                            ? widget.empCode ?? 0
                                            : int.tryParse(ownerEmpIdController.text) ?? 0,
                                        vacRequestDate: _dateController.text,
                                        vacRequestDateH: '',
                                        vacTypeId: int.tryParse(leaveIdController.text) ?? 0,
                                        vacRequestDateFrom: _startDateController.text,
                                        vacRequestDateFromH: '',
                                        vacRequestDateTo: _endDateController.text,
                                        vacRequestDateToH: '',
                                        vacDayCount: int.tryParse(_daysController.text) ?? 0,
                                        strNotes: _notesController.text,
                                        serviceTypeDesc: _servicesController.text,
                                        adminEmpCode: widget.empCode ?? 0,
                                        alternativeEmpCode:
                                            int.tryParse(transferEmpIdController.text) ?? 0,
                                        service: formattedServices,
                                        attachment: attachmentList,
                                      ),
                                    );
                                  } else {
                                    await context.read<ServicesCubit>().submitVacationRequest(
                                      VacationRequestModel(
                                        empCode: widget.pagePrivID != 1
                                            ? widget.empCode ?? 0
                                            : int.tryParse(ownerEmpIdController.text) ?? 0,
                                        vacRequestDate: _dateController.text,
                                        vacRequestDateH: '',
                                        vacTypeId: int.tryParse(leaveIdController.text) ?? 0,
                                        vacRequestDateFrom: _startDateController.text,
                                        vacRequestDateFromH: '',
                                        vacRequestDateTo: _endDateController.text,
                                        vacRequestDateToH: '',
                                        vacDayCount: int.tryParse(_daysController.text) ?? 0,
                                        strNotes: _notesController.text,
                                        serviceTypeDesc: _servicesController.text,
                                        adminEmpCode: widget.empCode ?? 0,
                                        alternativeEmpCode:
                                            int.tryParse(transferEmpIdController.text) ?? 0,
                                        service: formattedServices,
                                        attachment: attachmentList,
                                      ),
                                    );
                                  }
                                },
                                text: context.locale.languageCode == 'ar' ? 'نعم' : 'Yes',
                                radius: 12.r,
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;
                      } else if (checkResult != null && checkResult.column1 == 149) {
                        CommonMethods.showToast(
                          message: context.locale.languageCode == 'ar'
                              ? 'عفوا ... لا يمكن عمل طلب الاجازة ... الموظف بديل لموظف اخر له طلب اجازه مقدم'
                              : 'Employee already has a pending leave request',
                          type: ToastType.error,
                        );
                        return;
                      }
                    }

                    // تحويل قائمة الملفات إلى List<Map<String, String>>

                    if (widget.vacationRequestOrdersModel != null) {
                      await context.read<ServicesCubit>().updataVacationRequest(
                        VacationRequestUpdateModel(
                          requestId: int.tryParse(_requestNumber.text) ?? 0,
                          empCode: widget.pagePrivID != 1
                              ? widget.empCode ?? 0
                              : int.tryParse(ownerEmpIdController.text) ?? 0,
                          vacRequestDate: _dateController.text,
                          vacRequestDateH: '',
                          vacTypeId: int.tryParse(leaveIdController.text) ?? 0,
                          vacRequestDateFrom: _startDateController.text,
                          vacRequestDateFromH: '',
                          vacRequestDateTo: _endDateController.text,
                          vacRequestDateToH: '',
                          vacDayCount: int.tryParse(_daysController.text) ?? 0,
                          strNotes: _notesController.text,
                          serviceTypeDesc: _servicesController.text,
                          adminEmpCode: widget.empCode ?? 0,
                          alternativeEmpCode: int.tryParse(transferEmpIdController.text) ?? 0,
                          service: formattedServices,
                          attachment: attachmentList,
                        ),
                      );
                    } else {
                      await context.read<ServicesCubit>().submitVacationRequest(
                        VacationRequestModel(
                          empCode: widget.pagePrivID != 1
                              ? widget.empCode ?? 0
                              : int.tryParse(ownerEmpIdController.text) ?? 0,
                          vacRequestDate: _dateController.text,
                          vacRequestDateH: '',
                          vacTypeId: int.tryParse(leaveIdController.text) ?? 0,
                          vacRequestDateFrom: _startDateController.text,
                          vacRequestDateFromH: '',
                          vacRequestDateTo: _endDateController.text,
                          vacRequestDateToH: '',
                          vacDayCount: int.tryParse(_daysController.text) ?? 0,
                          strNotes: _notesController.text,
                          serviceTypeDesc: _servicesController.text,
                          adminEmpCode: widget.empCode ?? 0,
                          alternativeEmpCode: int.tryParse(transferEmpIdController.text) ?? 0,
                          service: formattedServices,
                          attachment: attachmentList,
                        ),
                      );
                    }
                  }
                },
                newrequest: () {
                  if (!mounted) return;
                  _formKey.currentState?.reset();
                  _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
                  _startDateController.clear();
                  _endDateController.clear();
                  _daysController.clear();
                  _balanceController.clear();
                  _ballController.clear();
                  ownerEmpIdController.clear();
                  ownerEmpNameController.clear();
                  transferEmpIdController.clear();
                  transferEmpNameController.clear();
                  _servicesController.clear();
                  leaveIdController.clear();
                  _notesController.clear();
                  _services.clear();
                  _requestNumber.clear();
                },
              ),
            ),
            appBar: CustomAppBarServicesWidget(
              context,
              title: AppLocalKay.leave.tr(),
              helpText: AppLocalKay.request_leave_screen.tr(),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: BlocListener<ServicesCubit, ServicesState>(
                  listenWhen: (previous, current) {
                    return previous.employeeBalStatus != current.employeeBalStatus ||
                        previous.employeeVacationsStatus != current.employeeVacationsStatus;
                  },
                  listener: (context, state) {
                    if (state.employeeBalStatus.isSuccess && state.employeeBalStatus.data != null) {
                      final balData = state.employeeBalStatus.data!;
                      if (balData.isNotEmpty) {
                        _ballController.text = balData
                            .fold<double>(0, (sum, e) => sum + (e.column1 ?? 0))
                            .toString();
                      }
                    }

                    if (state.employeeVacationsStatus.isSuccess &&
                        state.employeeVacationsStatus.data != null) {
                      final vacData = state.employeeVacationsStatus.data!;
                      if (vacData.isNotEmpty) {
                        _balanceController.text = vacData
                            .fold<double>(0, (sum, e) => sum + (e.empVacBal ?? 0))
                            .toString();
                      }
                    }
                  },
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
                              controller: _requestNumber,
                              hintText: context.locale.languageCode == 'ar' ? 'تلقائي' : 'Auto',
                            ),
                          ),
                          Expanded(
                            child: CustomFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: () async {
                                final today = DateTime.now();
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

                      widget.pagePrivID != 1
                          ? const SizedBox()
                          : EmployeePickerField(
                              empCode: widget.empCode ?? 0,
                              pagePrivID: widget.pagePrivID ?? 0,
                              validator: (p0) {
                                if (p0 == null || p0.isEmpty) {
                                  return AppLocalKay.requestOwner.tr();
                                }
                                return null;
                              },
                              title: AppLocalKay.requestOwner.tr(),
                              idController: ownerEmpIdController,
                              nameController: ownerEmpNameController,

                              onEmployeeSelected: (emp) {
                                ownerEmpIdController.text = emp.empCode.toString();
                                ownerEmpNameController.text = context.locale.languageCode == 'ar'
                                    ? emp.empName.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ??
                                          '' ??
                                          ''
                                    : emp.empNameE.replaceFirst(RegExp(r'^[0-9]+\s*'), '') ??
                                          '' ??
                                          '';
                                context.read<ServicesCubit>().selectedEmployee = emp;
                                _startDateController.clear();
                                _endDateController.clear();
                                _daysController.clear();
                                _updateVacationData();
                              },
                            ),

                      EmployeePickerField(
                        empCode: widget.empCode ?? 0,
                        pagePrivID: 1,
                        validator: (p0) {
                          final selectedLeave = context.read<ServicesCubit>().selectedLeave;

                          if (selectedLeave?.codeGpf == 2) {
                            return null;
                          }

                          if (p0 == null || p0.isEmpty) {
                            return AppLocalKay.employeetransfername.tr();
                          }

                          return null;
                        },

                        title: AppLocalKay.employeetransfername.tr(),
                        idController: transferEmpIdController,
                        nameController: transferEmpNameController,
                        onEmployeeSelected: (emp) {
                          transferEmpIdController.text = emp.empCode.toString();
                          transferEmpNameController.text = context.locale.languageCode == 'ar'
                              ? emp.empName.replaceFirst(RegExp(r'^[0-9]+\s*'), '')
                              : emp.empNameE.replaceFirst(RegExp(r'^[0-9]+\s*'), '');
                          context.read<ServicesCubit>().selectedEmployee = emp;
                        },
                      ),

                      Text(
                        AppLocalKay.leaveType.tr(),
                        style: AppTextStyle.formTitleStyle(
                          context,
                          color: AppColor.blackColor(context),
                        ),
                      ),
                      LeaveSelectorDropdown(controller: leaveIdController),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              controller: _startDateController,
                              readOnly: true,
                              title: AppLocalKay.leaveStartDate.tr(),
                              suffixIcon: Icon(
                                Icons.calendar_month,
                                color: AppColor.primaryColor(context),
                              ),
                              onTap: _showDatePickerDialog,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomFormField(
                              controller: _endDateController,
                              readOnly: true,
                              title: AppLocalKay.leaveEndDate.tr(),
                              suffixIcon: Icon(
                                Icons.calendar_month,
                                color: AppColor.primaryColor(context),
                              ),
                              onTap: _showDatePickerDialog,
                            ),
                          ),
                        ],
                      ),

                      CustomFormField(
                        controller: _daysController,
                        readOnly: true,
                        title: AppLocalKay.numberOfDays.tr(),
                      ),

                      VacationBalanceField(controller: _balanceController, isBall: false),
                      VacationBalanceField(controller: _ballController, isBall: true),

                      CustomFormField(title: AppLocalKay.notes.tr(), controller: _notesController),
                      Text(
                        AppLocalKay.serviceName.tr(),
                        style: AppTextStyle.formTitleStyle(
                          context,
                          color: AppColor.blackColor(context),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              controller: _servicesController,
                              readOnly: true,
                              validator: (p0) {
                                if (p0 == null || p0.isEmpty) {
                                  return AppLocalKay.serviceName.tr();
                                }
                                return null;
                              },
                              onTap: () async {
                                final leavesCubit = context.read<ServicesCubit>();

                                widget.vacationRequestOrdersModel != null
                                    ? await leavesCubit.getServices(
                                        requestId: widget.vacationRequestOrdersModel?.vacRequestId,
                                      )
                                    : await leavesCubit.getallServices();

                                final servicesList = widget.vacationRequestOrdersModel != null
                                    ? leavesCubit.state.servicesStatus.data ?? []
                                    : leavesCubit.state.allservicesStatus?.data ?? [];

                                await showServicesBottomSheet(
                                  requestId: widget.vacationRequestOrdersModel?.vacRequestId ?? 0,
                                  context: context,
                                  controller: _servicesController,
                                  selectedServices: _services,
                                  apiServices: servicesList,
                                  onServicesUpdated: (updatedServices) {
                                    setState(() {
                                      _services.clear();
                                      _services.addAll(updatedServices);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final leavesCubit = context.read<ServicesCubit>();
                              widget.vacationRequestOrdersModel != null
                                  ? await leavesCubit.getServices(
                                      requestId: widget.vacationRequestOrdersModel?.vacRequestId,
                                    )
                                  : await leavesCubit.getallServices();

                              final servicesList = widget.vacationRequestOrdersModel != null
                                  ? leavesCubit.state.servicesStatus.data ?? []
                                  : leavesCubit.state.allservicesStatus?.data ?? [];

                              await showServicesBottomSheet(
                                requestId: widget.vacationRequestOrdersModel?.vacRequestId ?? 0,
                                context: context,
                                controller: _servicesController,
                                selectedServices: _services,
                                apiServices: servicesList,
                                onServicesUpdated: (updatedServices) {
                                  setState(() {
                                    _services.clear();
                                    _services.addAll(updatedServices);
                                  });
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
                          widget.vacationRequestOrdersModel == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 55),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final cubit = context.read<ServicesCubit>();

                                      await cubit.getAttachments(
                                        requestId: widget.vacationRequestOrdersModel!.vacRequestId,
                                        attchmentType: 14,
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
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (bottomSheetContext) {
                                            return StatefulBuilder(
                                              builder: (ctx, setStateSheet) {
                                                Future<void> refreshAttachments() async {
                                                  await cubit.getAttachments(
                                                    requestId: widget
                                                        .vacationRequestOrdersModel!
                                                        .vacRequestId,
                                                    attchmentType: 14,
                                                  );
                                                  final newState = cubit.state;
                                                  if (newState.vacationAttachmentsStatus != null &&
                                                      newState
                                                          .vacationAttachmentsStatus!
                                                          .isSuccess) {
                                                    setStateSheet(() {
                                                      attachments =
                                                          List<VacationAttachmentItem>.from(
                                                            newState
                                                                    .vacationAttachmentsStatus!
                                                                    .data ??
                                                                [],
                                                          );
                                                    });
                                                  } else {}
                                                }

                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: MediaQuery.of(
                                                      context,
                                                    ).viewInsets.bottom,
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
                                                                icon: const Icon(
                                                                  Icons.remove_red_eye,
                                                                ),
                                                                onPressed: () async {
                                                                  final cubit = context
                                                                      .read<ServicesCubit>();

                                                                  await cubit.imageFileName(
                                                                    item.attchmentFileName,
                                                                    context,
                                                                  );
                                                                  final stateStatus = cubit
                                                                      .state
                                                                      .imageFileNameStatus;

                                                                  if (stateStatus?.isSuccess ==
                                                                      true) {
                                                                    final base64File =
                                                                        stateStatus?.data ?? '';

                                                                    await openBase64File(
                                                                      base64File,
                                                                      item.attchmentFileName,
                                                                    );
                                                                  } else if (stateStatus
                                                                          ?.isFailure ==
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
                                                                    requestId: widget
                                                                        .vacationRequestOrdersModel!
                                                                        .vacRequestId,
                                                                    attachId: item.ser,
                                                                    context: context,
                                                                    attchmentType: 14,
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
                                      child: Icon(
                                        Icons.search,
                                        color: AppColor.whiteColor(context),
                                      ),
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
          ),
        );
      },
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
