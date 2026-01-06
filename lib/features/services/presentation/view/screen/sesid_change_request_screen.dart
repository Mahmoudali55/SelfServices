import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:my_template/core/utils/file_viewer_utils.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/request_history/data/model/get_dynamic_order_model.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/add_new_dynamic_order.dart';
import 'package:my_template/features/services/data/model/dynamic_orders/updata_request_general_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';

class SesidChangeRequestScreen extends StatefulWidget {
  const SesidChangeRequestScreen({super.key, this.dynamicOrderModel});
  final DynamicOrderModel? dynamicOrderModel;
  @override
  State<SesidChangeRequestScreen> createState() => _SesidChangeRequestScreenState();
}

class _SesidChangeRequestScreenState extends State<SesidChangeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final requestNumber = TextEditingController();
  final _employeeId = TextEditingController();
  final _newSesid = TextEditingController();
  final _dateController = TextEditingController();

  final _reason = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    String empCode = HiveMethods.getEmpCode() ?? '0';
    _employeeId.text = empCode;
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    // جلب معرف الجهاز وملء حقل SESID الجديد
    _getDeviceId().then((id) {
      setState(() {
        _newSesid.text = id;
      });
    });

    empCode = HiveMethods.getEmpCode() ?? '';
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    final model = widget.dynamicOrderModel;
    if (model == null) return;

    requestNumber.text = model.requestId.toString();
    _employeeId.text = model.empCode.toString();
    _newSesid.text = model.strField1 ?? '';
    _reason.text = model.strField2 ?? '';
    if (model.requestDate.isNotEmpty) {
      try {
        final parsedDate = DateFormat('dd/MM/yyyy', 'en').parse(model.requestDate);
        _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
      } catch (_) {}
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? '';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }

  void dispose() {
    _employeeId.dispose();
    _newSesid.dispose();
    _reason.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.changeDevice.tr(),
        helpText: AppLocalKay.sesid_change_help.tr(),
      ),
      bottomNavigationBar: BlocListener<ServicesCubit, ServicesState>(
        listener: (context, state) => _handleState(context, state),
        child: CustomBottomNavButtonWidget(
          newrequest: () {
            _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());

            _reason.clear();
          },
          isLoading: widget.dynamicOrderModel == null
              ? context.watch<ServicesCubit>().state.addnewGeneralStatus.isLoading
              : context.watch<ServicesCubit>().state.updataGeneralStatus.isLoading,
          title: widget.dynamicOrderModel == null ? AppLocalKay.save.tr() : AppLocalKay.edit.tr(),
          color: widget.dynamicOrderModel == null ? AppColor.primaryColor(context) : Colors.orange,
          save: () async {
            final checkResult = await context.read<ServicesCubit>().checkEmpGeneral(
              empCode: int.parse(_employeeId.text),
              requesttypeid: 5008,
            );

            if (widget.dynamicOrderModel == null && checkResult != null) {
              if (!_canSubmitRequest(context, checkResult.column1)) return;
            }

            if (_formKey.currentState!.validate()) {
              if (widget.dynamicOrderModel != null) {
                context.read<ServicesCubit>().updateGeneral(
                  request: UpdataRequestGeneralModel(
                    requestId: int.tryParse(requestNumber.text) ?? 0,
                    empCode: int.parse(_employeeId.text),
                    requestDate: _dateController.text,
                    requestTypeId: 5008,
                    strField1: _newSesid.text,
                    strField2: _reason.text,
                    strNotes: '',
                    attachment: attachmentList,
                  ),
                );
              } else {
                context.read<ServicesCubit>().addnewGeneral(
                  request: AddNewDynamicOrder(
                    empCode: int.parse(_employeeId.text),
                    requestDate: _dateController.text,
                    requestTypeId: 5008,
                    strField1: _reason.text,
                    strField2: _newSesid.text,
                    strNotes: '',
                    attachment: attachmentList,
                  ),
                );
              }
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormField(
                  controller: requestNumber,
                  title: AppLocalKay.requestNumber.tr(),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                CustomFormField(
                  controller: _employeeId,
                  title: AppLocalKay.empCode.tr(),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppLocalKay.employee_id_required.tr()
                      : null,
                  readOnly: true,
                ),
                CustomFormField(
                  controller: _dateController,
                  readOnly: true,

                  title: AppLocalKay.requestDate.tr(),
                ),
                const SizedBox(height: 16),

                CustomFormField(
                  controller: _newSesid,
                  title: AppLocalKay.newDevice.tr(),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? AppLocalKay.sesid_required.tr() : null,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                CustomFormField(
                  controller: _reason,
                  title: AppLocalKay.reason.tr(),
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? AppLocalKay.reason_required.tr() : null,
                ),
                Gap(10.h),
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
                    widget.dynamicOrderModel == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: GestureDetector(
                              onTap: () async {
                                final cubit = context.read<ServicesCubit>();

                                await cubit.getAttachments(
                                  requestId: widget.dynamicOrderModel!.requestId,
                                  attchmentType: 5008,
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
                                              requestId: widget.dynamicOrderModel!.requestId,
                                              attchmentType: 5008,
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
                                                  AppLocalKay.attachments_title.tr(),
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
                                                      AppLocalKay.no_attachments_found.tr(),
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
                                                              requestId: widget
                                                                  .dynamicOrderModel!
                                                                  .requestId,
                                                              attachId: item.ser,
                                                              context: context,
                                                              attchmentType: 5008,
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
                                    message: AppLocalKay.attachment_load_error.tr(),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canSubmitRequest(BuildContext context, double column) {
    switch (column) {
      case 136:
        CommonMethods.showToast(
          message: AppLocalKay.request_pending_error.tr(),
          type: ToastType.error,
        );
        return false;
      case 148:
        CommonMethods.showToast(
          message: AppLocalKay.employee_alternative_error_1.tr(),
          type: ToastType.error,
        );
        return false;
      case 149:
        CommonMethods.showToast(
          message: AppLocalKay.employee_alternative_error_2.tr(),
          type: ToastType.error,
        );
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

  void _handleState(BuildContext context, ServicesState state) {
    if (widget.dynamicOrderModel != null && state.updataGeneralStatus.isSuccess) {
      _showToastSuccess(context, AppLocalKay.request_update_success.tr());
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'requestchangePhone'},
      );
    } else if (state.addnewGeneralStatus.isSuccess) {
      _showToastSuccess(context, AppLocalKay.request_submit_success.tr());
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'requestchangePhone'},
      );
    }

    if (state.addnewGeneralStatus.isFailure) {
      _showToast(context, state.addnewGeneralStatus.error ?? 'Error');
    }
  }
}
