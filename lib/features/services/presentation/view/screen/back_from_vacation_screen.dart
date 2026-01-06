import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/request_history/data/model/get_requests_vacation_back.dart';
import 'package:my_template/features/services/data/model/vacation_back/add_new_vacation_back_model.dart';
import 'package:my_template/features/services/data/model/vacation_back/update_vacation_request_back_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/back_form_vaction/vacation_requests_bottom_Sheet_light_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';

class BackFromVacationScreen extends StatefulWidget {
  const BackFromVacationScreen({
    super.key,
    required this.empcode,
    this.pagePrivID,
    this.vacationBackRequestModel,
  });
  final int? empcode;
  final int? pagePrivID;
  final GetRequestVacationBackModel? vacationBackRequestModel;
  @override
  State<BackFromVacationScreen> createState() => _BackFromVacationScreenState();
}

class _BackFromVacationScreenState extends State<BackFromVacationScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _requestOwnerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _requestnumberController = TextEditingController();
  final TextEditingController _backDaysController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _returnDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-M-d', 'en').format(now);
    context.read<ServicesCubit>().getVacationBack(empcode: widget.empcode ?? 0);
    context.read<ServicesCubit>().checkEmpBackHaveRequests(empCode: widget.empcode ?? 0);
    _initExistingRequest();
  }

  void _calculateDays() {
    if (_startDate != null && _endDate != null) {
      _daysController.text = (_endDate!.difference(_startDate!).inDays + 1).toString();
    } else {
      _daysController.text = '';
    }
  }

  void _calculateBackDays() {
    if (_endDate != null && _returnDate != null) {
      final difference = _returnDate!.difference(_endDate!).inDays;
      _backDaysController.text = (difference >= 0 ? difference : 0).toString();
    } else {
      _backDaysController.text = '';
    }
  }

  void _initExistingRequest() {
    if (widget.vacationBackRequestModel == null) return;
    final model = widget.vacationBackRequestModel!;

    _requestnumberController.text = model.vacRequestId.toString();
    _startDateController.text = model.strVacRequestDateFrom ?? '';
    _endDateController.text = model.strVacRequestDateTo ?? '';
    _requestOwnerController.text = model.empName ?? '';
    _returnDateController.text = model.strActualHolEndDate ?? '';
    _backDaysController.text = model.lateDays.toString();
    _daysController.text = model.vacDayCount.toString();
    _notesController.text = model.strNotes ?? '';
    idController.text = model.empCode.toString();

    try {
      if (model.strVacRequestDateFrom?.isNotEmpty ?? false) {
        _startDate = DateFormat('yyyy-M-d', 'en').parse(model.strVacRequestDateFrom!);
      }
      if (model.strVacRequestDateTo?.isNotEmpty ?? false) {
        _endDate = DateFormat('yyyy-M-d', 'en').parse(model.strVacRequestDateTo!);
      }
      if (model.strActualHolEndDate?.isNotEmpty ?? false) {
        _returnDate = DateFormat('yyyy-M-d', 'en').parse(model.strActualHolEndDate!);
      }
    } catch (e) {}
  }

  final int empcode = int.tryParse(HiveMethods.getEmpCode()?.toString() ?? '') ?? 0;
  void _submit() {
    context.read<ServicesCubit>().checkEmpBackHaveRequests(
      empCode: int.tryParse(idController.text) ?? 0,
    );
    final checkState = context.read<ServicesCubit>().state.checkEmpHaveBackRequestsStatus;
    if (checkState.isSuccess) {
      final checkResult = checkState.data;
      if (checkResult != null && checkResult.column1 == 136) {
        CommonMethods.showToast(
          message: AppLocalKay.request_pending_error.tr(),
          type: ToastType.error,
        );
        return;
      } else if (checkResult != null && checkResult.column1 == 148) {
        CommonMethods.showToast(
          message: AppLocalKay.employee_alternative_error_1.tr(),
          type: ToastType.error,
        );
        return;
      } else if (checkResult != null && checkResult.column1 == 149) {
        CommonMethods.showToast(
          message: AppLocalKay.employee_alternative_error_2.tr(),
          type: ToastType.error,
        );
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;
    try {
      final requestupdate = UpdateVacationRequestBackModel(
        requestId: int.tryParse(_requestnumberController.text) ?? 0,
        empCode: int.tryParse(idController.text) ?? 0,
        vacRequestDate: _formatForApi(_dateController.text),
        vacRequestDateFrom: _formatForApi(_startDateController.text),
        vacRequestDateTo: _formatForApi(_endDateController.text),
        vacDayCount: int.tryParse(_daysController.text) ?? 0,
        actualHolEndDate: _formatForApi(_returnDateController.text),
        lateDays: int.tryParse(_backDaysController.text) ?? 0,
        strNotes: _notesController.text,
        adminEmpCode: empcode,
        alternativeEmpCode: empcode,
      );
      final request = AddNewVacationBackRequestModel(
        requestId: int.tryParse(_requestnumberController.text) ?? 0,
        empCode: int.tryParse(idController.text) ?? 0,
        vacRequestDate: _dateController.text,
        vacRequestDateFrom: _startDateController.text,
        vacRequestDateTo: _endDateController.text,
        vacDayCount: int.tryParse(_daysController.text) ?? 0,
        actualHolEndDate: _returnDateController.text,
        lateDays: int.tryParse(_backDaysController.text) ?? 0,
        strNotes: _notesController.text,
        adminEmpCode: widget.empcode ?? 0,
        alternativeEmpCode: widget.empcode ?? 0,
      );
      if (widget.vacationBackRequestModel != null) {
        context.read<ServicesCubit>().updataVacationBackRequest(requestupdate);
      } else {
        context.read<ServicesCubit>().addNewVacationBack(request: request);
      }
    } catch (e) {
      CommonMethods.showToast(message: 'Error preparing request: $e', type: ToastType.error);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _returnDateController.dispose();
    _daysController.dispose();
    _requestOwnerController.dispose();
    _notesController.dispose();
    _requestnumberController.dispose();
    _backDaysController.dispose();
    idController.dispose();
    super.dispose();
  }

  String _formatForApi(String value) {
    if (value.isEmpty) return '';
    try {
      final parsed = DateFormat('yyyy-M-d', 'en').parse(value);
      return DateFormat('yyyy-MM-dd', 'en').format(parsed);
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: AppColor.whiteColor(context),
        appBar: CustomAppBarServicesWidget(
          context,
          title: AppLocalKay.backleave.tr(),
          helpText: AppLocalKay.back_from_vacation_screen.tr(),
        ),
        bottomNavigationBar: BlocListener<ServicesCubit, ServicesState>(
          listener: (context, state) {
            if (widget.vacationBackRequestModel != null) {
              if (state.updataVacationBackStatus.isSuccess) {
                CommonMethods.showToast(
                  message: AppLocalKay.request_back_vacation_update_success.tr(),
                  type: ToastType.success,
                );
                NavigatorMethods.pushNamedAndRemoveUntil(
                  context,
                  RoutesName.layoutScreen,
                  arguments: {'restoreIndex': 1, 'initialType': 'backleave'},
                );
              }
            }
            if (state.vacationBackAddStatus.isSuccess) {
              CommonMethods.showToast(
                message: AppLocalKay.request_back_vacation_submit_success.tr(),
                type: ToastType.success,
              );
              NavigatorMethods.pushNamedAndRemoveUntil(
                context,
                RoutesName.layoutScreen,
                arguments: {'restoreIndex': 1, 'initialType': 'backleave'},
              );
            } else if (state.vacationBackAddStatus.isFailure) {
              CommonMethods.showToast(
                message: state.vacationBackAddStatus.error ?? 'Error',
                type: ToastType.error,
              );
            }
          },
          child: CustomBottomNavButtonWidget(
            save: _submit,
            title: widget.vacationBackRequestModel != null
                ? AppLocalKay.edit.tr()
                : AppLocalKay.save.tr(),
            color: widget.vacationBackRequestModel != null
                ? Colors.orange
                : AppColor.primaryColor(context),

            newrequest: () {
              _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
              _startDateController.clear();
              _endDateController.clear();
              _returnDateController.clear();
              _daysController.clear();
              _requestOwnerController.clear();
              _notesController.clear();

              _backDaysController.clear();
              idController.clear();
            },
            isLoading: widget.vacationBackRequestModel != null
                ? context.watch<ServicesCubit>().state.updataVacationBackStatus.isLoading
                : context.watch<ServicesCubit>().state.vacationBackAddStatus.isLoading,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CustomFormField(
                        hintText: AppLocalKay.auto.tr(),
                        title: AppLocalKay.requestNumber.tr(),
                        readOnly: true,
                        controller: _requestnumberController,
                      ),
                    ),
                    Expanded(
                      child: CustomFormField(
                        title: AppLocalKay.requestDate.tr(),
                        controller: _dateController,
                        readOnly: true,
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColor.primaryColor(context),
                        ),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            setState(() {
                              _dateController.text = DateFormat('yyyy-M-d', 'en').format(selected);
                            });
                          }
                        },
                      ),
                    ),
                    // (widget.pagePrivID == 1 || widget.pagePrivID == 2)
                    //     ?
                    widget.vacationBackRequestModel == null
                        ? GestureDetector(
                            onTap: () async {
                              await context.read<ServicesCubit>().getVacationBack(
                                empcode: widget.empcode ?? 0,
                              );

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ServicesCubit>(),
                                  child: SizedBox(
                                    height: 500.h,
                                    child: BlocBuilder<ServicesCubit, ServicesState>(
                                      builder: (context, state) {
                                        final requests = state.vacationBackStatus?.data ?? [];
                                        if (state.vacationBackStatus!.isLoading) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (state.vacationBackStatus!.isFailure) {
                                          return Center(
                                            child: Text(AppLocalKay.failed_to_load_data.tr()),
                                          );
                                        } else if (requests.isEmpty) {
                                          return Center(child: Text(AppLocalKay.no_requests.tr()));
                                        }
                                        return VacationRequestsBottomSheetLight(
                                          requests: requests,
                                          onSelect: (selected) {
                                            setState(() {
                                              final parsedStartDate = DateFormat(
                                                'dd/MM/yyyy',
                                                'en',
                                              ).parse(selected.vacRequestDateFrom);
                                              final parsedEndDate = DateFormat(
                                                'dd/MM/yyyy',
                                                'en',
                                              ).parse(selected.vacRequestDateTo);

                                              _startDate = parsedStartDate;
                                              _endDate = parsedEndDate;
                                              _returnDate = null;
                                              _dateController.text = DateFormat('yyyy-M-d', 'en')
                                                  .format(
                                                    DateFormat(
                                                      'dd/MM/yyyy',
                                                      'en',
                                                    ).parse(selected.vacRequestDate),
                                                  );
                                              _startDateController.text = DateFormat(
                                                'yyyy-M-d',
                                                'en',
                                              ).format(parsedStartDate);
                                              _endDateController.text = DateFormat(
                                                'yyyy-M-d',
                                                'en',
                                              ).format(parsedEndDate);
                                              _daysController.text = selected.vacDayCount
                                                  .toString();
                                              _requestOwnerController.text =
                                                  context.locale.languageCode == 'en'
                                                  ? selected.empNameE ?? ''
                                                  : selected.empName ?? '';
                                              idController.text = selected.empCode.toString();
                                              _returnDateController.text = '';
                                              _requestnumberController.text = selected.vacRequestId
                                                  .toString();
                                              _backDaysController.text = '';
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(top: 30.h),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(context),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.blackColor(context).withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: AppColor.whiteColor(context),
                                  size: 28,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                CustomFormField(
                  title: AppLocalKay.requestOwner.tr(),
                  controller: _requestOwnerController,

                  validator: (p0) => p0!.isEmpty ? AppLocalKay.requestOwner.tr() : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        controller: _startDateController,
                        readOnly: true,
                        title: AppLocalKay.leaveStartDate.tr(),
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.leaveStartDate.tr() : null,
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColor.primaryColor(context),
                        ),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            setState(() {
                              _startDate = selected;
                              _startDateController.text = DateFormat(
                                'yyyy-M-d',
                                'en',
                              ).format(selected);
                              _calculateDays();
                              _calculateBackDays();
                            });
                          }
                        },
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: CustomFormField(
                        controller: _endDateController,
                        readOnly: true,
                        title: AppLocalKay.leaveEndDate.tr(),
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.leaveEndDate.tr() : null,
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColor.primaryColor(context),
                        ),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            setState(() {
                              _endDate = selected;
                              _endDateController.text = DateFormat(
                                'yyyy-M-d',
                                'en',
                              ).format(selected);
                              _calculateDays();
                              _calculateBackDays();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                CustomFormField(
                  controller: _daysController,
                  validator: (p0) => p0!.isEmpty ? AppLocalKay.numberOfDays.tr() : null,
                  readOnly: true,
                  title: AppLocalKay.numberOfDays.tr(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        controller: _returnDateController,
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.backDate.tr() : null,
                        readOnly: true,
                        title: AppLocalKay.backDate.tr(),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColor.primaryColor(context),
                        ),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _returnDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            setState(() {
                              _returnDate = selected;
                              _returnDateController.text = DateFormat(
                                'yyyy-M-d',
                                'en',
                              ).format(selected);

                              _calculateBackDays();
                            });
                          }
                        },
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: CustomFormField(
                        controller: _backDaysController,
                        title: AppLocalKay.backDays.tr(),
                        validator: (p0) => p0!.isEmpty ? AppLocalKay.backDays.tr() : null,
                      ),
                    ),
                  ],
                ),
                CustomFormField(
                  title: AppLocalKay.notes.tr(),
                  controller: _notesController,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
