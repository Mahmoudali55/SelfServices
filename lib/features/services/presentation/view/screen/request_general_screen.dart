import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class RequestGeneralScreen extends StatefulWidget {
  const RequestGeneralScreen({Key? key, this.dynamicOrderModel}) : super(key: key);
  final DynamicOrderModel? dynamicOrderModel;
  @override
  State<RequestGeneralScreen> createState() => _RequestGeneralScreenState();
}

class _RequestGeneralScreenState extends State<RequestGeneralScreen> {
  final _formKey = GlobalKey<FormState>();

  final requestNumber = TextEditingController();

  final notes = TextEditingController();

  final _dateController = TextEditingController();

  final requestDescription = TextEditingController();
  String empCode = '';
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);
    empCode = HiveMethods.getEmpCode() ?? '';
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    final model = widget.dynamicOrderModel;
    if (model == null) return;

    requestNumber.text = model.requestId.toString();
    notes.text = model.strNotes ?? '';
    requestDescription.text = model.strField1 ?? '';

    if (model.requestDate.isNotEmpty) {
      try {
        final parsedDate = DateFormat('dd/MM/yyyy', 'en').parse(model.requestDate);
        _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    requestNumber.dispose();
    notes.dispose();
    _dateController.dispose();
    requestDescription.dispose();
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
        title: AppLocalKay.requestgeneral.tr(),
        helpText: AppLocalKay.request_general_help.tr(),
      ),
      bottomNavigationBar: BlocListener<ServicesCubit, ServicesState>(
        listener: (context, state) => _handleState(context, state),
        child: CustomBottomNavButtonWidget(
          newrequest: () {
            _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
            requestDescription.clear();
            notes.clear();
            requestNumber.clear();
          },
          isLoading: widget.dynamicOrderModel == null
              ? context.watch<ServicesCubit>().state.addnewGeneralStatus.isLoading
              : context.watch<ServicesCubit>().state.updataGeneralStatus.isLoading,
          title: widget.dynamicOrderModel == null ? AppLocalKay.save.tr() : AppLocalKay.edit.tr(),
          color: widget.dynamicOrderModel == null ? AppColor.primaryColor(context) : Colors.orange,
          save: () async {
            final checkResult = await context.read<ServicesCubit>().checkEmpGeneral(
              empCode: int.parse(empCode),
              requesttypeid: 5007,
            );

            if (widget.dynamicOrderModel == null && checkResult != null) {
              if (!_canSubmitRequest(context, checkResult.column1)) return;
            }

            if (_formKey.currentState!.validate()) {
              if (widget.dynamicOrderModel != null) {
                context.read<ServicesCubit>().updateGeneral(
                  request: UpdataRequestGeneralModel(
                    requestId: int.tryParse(requestNumber.text) ?? 0,
                    empCode: int.parse(empCode),
                    requestDate: _dateController.text,
                    requestTypeId: 5007,
                    strField1: requestDescription.text,
                    strField2: '',
                    strNotes: notes.text,
                    attachment: attachmentList,
                  ),
                );
              } else {
                context.read<ServicesCubit>().addnewGeneral(
                  request: AddNewDynamicOrder(
                    empCode: int.parse(empCode),
                    requestDate: _dateController.text,
                    requestTypeId: 5007,
                    strField1: requestDescription.text,
                    strField2: '',
                    strNotes: notes.text,
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
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormField(
                  title: AppLocalKay.requestNumber.tr(),
                  readOnly: true,
                  controller: requestNumber,
                ),
                CustomFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                  title: AppLocalKay.requestDate.tr(),
                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
                ),
                const SizedBox(height: 16),
                CustomFormField(controller: notes, title: AppLocalKay.notes.tr()),
                const SizedBox(height: 16),
                CustomFormField(
                  controller: requestDescription,
                  title: AppLocalKay.reason.tr(),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'السبب مطلوب' : null,
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
                    widget.dynamicOrderModel == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(
                              bottom: attachmentController.text.isEmpty ? 0 : 55,
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                final cubit = context.read<ServicesCubit>();

                                await cubit.getAttachments(
                                  requestId: widget.dynamicOrderModel!.requestId,
                                  attchmentType: 5007,
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
                                              attchmentType: 5007,
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
                                                              requestId: widget
                                                                  .dynamicOrderModel!
                                                                  .requestId,
                                                              attachId: item.ser,
                                                              context: context,
                                                              attchmentType: 5007,
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
        _showToast(
          context,
          'عفوا ... هناك طلب مقدم سابقا تحت الاجراء',
          'Employee already has a pending leave request',
        );
        return false;
      case 148:
        _showToast(
          context,
          'عفوا ... لا يمكن عمل طلب الاجازة ... الموظف بديل لموظف اخر لم يعد من اجازته بعد',
          'Employee already has a pending leave request',
        );
        return false;
      case 149:
        _showToast(
          context,
          'عفوا ... لا يمكن عمل طلب الاجازة ... الموظف بديل لموظف اخر له طلب اجازه مقدم',
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

  void _handleState(BuildContext context, ServicesState state) {
    if (widget.dynamicOrderModel != null && state.updataGeneralStatus.isSuccess) {
      _showToastSuccess(
        context,
        'تم تعديل الطلب  بنجاح',
        'Update resignation request successfully',
      );
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'requestgenerals'},
      );
    } else if (state.addnewGeneralStatus.isSuccess) {
      _showToastSuccess(
        context,
        'تم تسجيل الطلب  بنجاح',
        'Submit resignation request successfully',
      );
      NavigatorMethods.pushNamedAndRemoveUntil(
        context,
        RoutesName.layoutScreen,
        arguments: {'restoreIndex': 1, 'initialType': 'requestgenerals'},
      );
    }

    if (state.addnewGeneralStatus.isFailure) {
      _showToast(context, state.addnewGeneralStatus.error ?? 'Error');
    }
  }
}
