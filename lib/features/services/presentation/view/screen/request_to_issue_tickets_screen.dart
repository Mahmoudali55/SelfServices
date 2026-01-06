import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/routes/routes_name.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/file_viewer_utils.dart';
import 'package:my_template/core/utils/navigator_methods.dart';
import 'package:my_template/features/request_history/data/model/get_all_ticket_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/data/model/ticket/ticket_request_model.dart';
import 'package:my_template/features/services/data/model/ticket/update_request_ticket_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_bottom_nav_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';

class RequestToIssueTicketsScreen extends StatefulWidget {
  const RequestToIssueTicketsScreen({super.key, this.empCode, this.allTicketModel});
  final int? empCode;
  final AllTicketModel? allTicketModel;
  @override
  State<RequestToIssueTicketsScreen> createState() => _RequestToIssueTicketsScreenState();
}

class _RequestToIssueTicketsScreenState extends State<RequestToIssueTicketsScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _requestIdController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  String? selectedPlace;
  final List<String> travelPlaces = [AppLocalKay.travel_type.tr(), AppLocalKay.travel_type1.tr()];
  final attachmentController = TextEditingController();
  List<Map<String, String>> selectedFilesMap = [];
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);
    selectedPlace = travelPlaces.isNotEmpty ? travelPlaces[0] : null;
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);
    selectedPlace = travelPlaces[0]; // القيمة الافتراضية ✅

    if (widget.allTicketModel != null) {
      final model = widget.allTicketModel!;
      _requestIdController.text = model.requestID.toString();
      noteController.text = model.strNotes;
      countController.text = model.ticketcount.toString();
      countryController.text = model.ticketPath;

      // ✅ توحيد قراءة التاريخين
      try {
        _startDateController.text = DateFormat(
          'dd/MM/yyyy',
          'en',
        ).parse(model.travelDate).toIso8601String().substring(0, 10);
      } catch (_) {
        _startDateController.text = model.travelDate;
      }

      try {
        _dateController.text = DateFormat(
          'dd/MM/yyyy',
          'en',
        ).parse(model.requestDate).toIso8601String().substring(0, 10);
      } catch (_) {
        _dateController.text = model.requestDate;
      }

      selectedPlace = model.goback == 1 ? travelPlaces[0] : travelPlaces[1];
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startDateController.dispose();
    countController.dispose();
    countryController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
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
          if (widget.allTicketModel != null) {
            if (state.updataTicketStatus.isSuccess) {
              CommonMethods.showToast(
                message: AppLocalKay.request_update_success.tr(),
                type: ToastType.success,
              );
              NavigatorMethods.pushNamedAndRemoveUntil(
                context,
                RoutesName.layoutScreen,
                arguments: {'restoreIndex': 1, 'initialType': 'tickets'},
              );
            } else if (state.updataTicketStatus.isFailure) {
              CommonMethods.showToast(
                message: state.updataTicketStatus.error ?? 'حص',
                type: ToastType.error,
              );
            }
          } else {
            if (state.addnewTicketStatus.isSuccess) {
              CommonMethods.showToast(
                message: AppLocalKay.request_submit_success.tr(),
                type: ToastType.success,
              );
              NavigatorMethods.pushNamedAndRemoveUntil(
                context,
                RoutesName.layoutScreen,
                arguments: {'restoreIndex': 1, 'initialType': 'tickets'},
              );
            }
            if (state.addnewTicketStatus.isFailure) {
              CommonMethods.showToast(
                message: state.addnewTicketStatus.error ?? '',
                type: ToastType.error,
              );
            }
          }
        },
        child: CustomBottomNavButtonWidget(
          newrequest: () {
            _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
            selectedPlace = travelPlaces.isNotEmpty ? travelPlaces[0] : null;
            noteController.clear();
            countController.clear();
            countryController.clear();
            _startDateController.clear();
          },
          isLoading:
              context.watch<ServicesCubit>().state.addnewTicketStatus.isLoading ||
              context.watch<ServicesCubit>().state.updataTicketStatus.isLoading ||
              context.watch<ServicesCubit>().state.checkEmpHaveTicketRequestsStatus.isLoading,
          title: widget.allTicketModel != null ? AppLocalKay.edit.tr() : AppLocalKay.save.tr(),
          color: widget.allTicketModel != null ? Colors.orange : AppColor.primaryColor(context),
          save: () async {
            if (widget.allTicketModel == null) {
              await context.read<ServicesCubit>().checkEmpTicketHaveRequests(
                empCode: widget.empCode ?? 0,
              );

              final checkState = context
                  .read<ServicesCubit>()
                  .state
                  .checkEmpHaveTicketRequestsStatus;
              if (checkState.isSuccess) {
                final checkResult = checkState.data;
                if (checkResult != null) {
                  if (checkResult.column1 == 136) {
                    CommonMethods.showToast(
                      message: AppLocalKay.request_pending_error.tr(),
                      type: ToastType.error,
                    );
                    return;
                  } else if (checkResult.column1 == 148) {
                    CommonMethods.showToast(
                      message: AppLocalKay.ticket_alternative_error_1.tr(),
                      type: ToastType.error,
                    );
                    return;
                  } else if (checkResult.column1 == 149) {
                    CommonMethods.showToast(
                      message: AppLocalKay.ticket_alternative_error_2.tr(),
                      type: ToastType.error,
                    );
                    return;
                  }
                }
              }
            }

            if (_formKey.currentState!.validate()) {
              final goBack = (selectedPlace == travelPlaces[0]) ? 1 : 2;

              if (widget.allTicketModel != null) {
                // ✅ تعديل
                context.read<ServicesCubit>().updateTicket(
                  UpdateTicketsRequestModel(
                    empCode: widget.empCode ?? 0,
                    requestDate: _dateController.text,
                    ticketCount: int.parse(countController.text),
                    travelDate: _startDateController.text,
                    ticketPath: countryController.text,
                    goBack: goBack,
                    strNotes: noteController.text,
                    requestId: widget.allTicketModel?.requestID ?? 0,
                    attachment: attachmentList,
                  ),
                );
              } else {
                // ✅ إضافة جديدة
                context.read<ServicesCubit>().addnewTicket(
                  request: TicketRequest(
                    empCode: widget.empCode ?? 0,
                    requestDate: _dateController.text,
                    ticketCount: int.parse(countController.text),
                    travelDate: _startDateController.text,
                    ticketPath: countryController.text,
                    goBack: goBack,
                    strNotes: noteController.text,
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
        title: AppLocalKay.ticket.tr(),
        helpText: AppLocalKay.ticket_request_help.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Form(
          key: _formKey,
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
                        controller: _requestIdController,
                        readOnly: true,
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

                CustomFormField(title: AppLocalKay.ticket_number.tr(), controller: countController),
                CustomFormField(
                  controller: _startDateController,
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
                        _startDate = selectedDate;
                        _startDateController.text = DateFormat(
                          'yyyy-MM-dd',
                          'en',
                        ).format(selectedDate);
                      });
                    }
                  },
                  title: AppLocalKay.travel_date.tr(),
                  suffixIcon: Icon(Icons.calendar_month, color: AppColor.primaryColor(context)),
                ),
                CustomFormField(
                  title: AppLocalKay.travel_place.tr(),
                  controller: countryController,
                ),
                Row(
                  children: travelPlaces.map((place) {
                    return Flexible(
                      child: RadioListTile<String>(
                        title: Text(place, textAlign: TextAlign.center),
                        value: place,
                        activeColor: AppColor.primaryColor(context),
                        groupValue: selectedPlace,
                        onChanged: (value) {
                          setState(() {
                            selectedPlace = value;

                            int goBackValue = (selectedPlace == travelPlaces[0]) ? 1 : 2;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }).toList(),
                ),

                CustomFormField(title: AppLocalKay.travel_reason.tr(), controller: noteController),
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
                    widget.allTicketModel == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: GestureDetector(
                              onTap: () async {
                                final cubit = context.read<ServicesCubit>();

                                await cubit.getAttachments(
                                  requestId: widget.allTicketModel!.requestID,
                                  attchmentType: 18,
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
                                              requestId: widget.allTicketModel!.requestID,
                                              attchmentType: 18,
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
                                                              requestId:
                                                                  widget.allTicketModel!.requestID,
                                                              attachId: item.ser,
                                                              context: context,
                                                              attchmentType: 18,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
