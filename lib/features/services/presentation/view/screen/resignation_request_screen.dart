import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/core/utils/file_viewer_utils.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/resignation/resignatin_save_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/resignation/resignation_form_widget.dart';

class ResignationRequestScreen extends StatefulWidget {
  const ResignationRequestScreen({super.key, this.empCode, this.resignationModel});
  final int? empCode;
  final GetAllResignationModel? resignationModel;

  @override
  State<ResignationRequestScreen> createState() => _ResignationRequestScreenState();
}

class _ResignationRequestScreenState extends State<ResignationRequestScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _lastWorkController = TextEditingController();
  final TextEditingController _requestIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final attachmentController = TextEditingController();
  List<Map<String, String>> selectedFilesMap = [];
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    if (widget.resignationModel != null) {
      _requestIdController.text = widget.resignationModel?.requestID.toString() ?? '';
      _notesController.text = widget.resignationModel?.strNotes ?? '';
      _lastWorkController.text = widget.resignationModel?.lastWorkDate ?? '';
      try {
        if (widget.resignationModel!.requestDate.isNotEmpty) {
          DateTime parsedDate = DateFormat(
            'yyyy-MM-dd',
            'en',
          ).parse(widget.resignationModel!.requestDate);
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    _lastWorkController.dispose();
    _requestIdController.dispose();
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
      appBar: CustomAppBarServicesWidget(
        context,
        title: AppLocalKay.resignation.tr(),
        helpText: AppLocalKay.resignation_help.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResignationForm(
                formKey: _formKey,
                dateController: _dateController,
                lastWorkController: _lastWorkController,
                notesController: _notesController,
                requestIdController: _requestIdController,
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
                  widget.resignationModel == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: GestureDetector(
                            onTap: () async {
                              final cubit = context.read<ServicesCubit>();

                              await cubit.getAttachments(
                                requestId: widget.resignationModel!.requestID,
                                attchmentType: 15,
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
                                            requestId: widget.resignationModel!.requestID,
                                            attchmentType: 15,
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
                                                                widget.resignationModel!.requestID,
                                                            attachId: item.ser,
                                                            context: context,
                                                            attchmentType: 15,
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
      bottomNavigationBar: ResignationSaveButton(
        newrequest: () {
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());
          _notesController.clear();
          _lastWorkController.clear();
        },
        formKey: _formKey,
        empCode: widget.empCode,
        resignationModel: widget.resignationModel,
        dateController: _dateController,
        lastWorkController: _lastWorkController,
        notesController: _notesController,
        requestIdController: _requestIdController,
        attachmentList: attachmentList,
      ),
    );
  }
}
