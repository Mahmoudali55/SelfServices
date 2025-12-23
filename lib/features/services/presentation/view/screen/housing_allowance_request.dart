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
import 'package:my_template/features/request_history/data/model/get_all_housing_allowance_model.dart';
import 'package:my_template/features/services/data/model/request_leave/get_vacation_attachment_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_request_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/custom_app_bar_services_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/housing_allowance/housing_allowance_form_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/housing_allowance/housing_allowance_save_button_widget.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/request_leave/custom_fileForm_field_chips_widget.dart';

class HousingAllowanceRequestScreen extends StatefulWidget {
  const HousingAllowanceRequestScreen({super.key, this.empCode, this.model});
  final int? empCode;
  final GetAllHousingAllowanceModel? model;

  @override
  State<HousingAllowanceRequestScreen> createState() => _HousingAllowanceRequestScreenState();
}

class _HousingAllowanceRequestScreenState extends State<HousingAllowanceRequestScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _requestIdController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? selectedPlace = AppLocalKay.vacationPeriodType2.tr();
  final Map<String, int> travelPlaceValues = {
    AppLocalKay.vacationPeriodType2.tr(): 1,
    AppLocalKay.vacationPeriodType3.tr(): 2,
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(now);

    if (widget.model != null) {
      final model = widget.model!;
      _requestIdController.text = model.requestID.toString();
      _noteController.text = model.strNotes ?? '';
      _amountController.text = model.sakanAmount.toString();

      if (model.requestDate.isNotEmpty) {
        try {
          DateTime parsedDate = DateFormat('dd/MM/yyyy', 'en').parse(model.requestDate);
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(parsedDate);
        } catch (_) {
          _dateController.text = model.requestDate;
        }
      }

      selectedPlace = travelPlaceValues.entries
          .firstWhere((e) => e.value == model.amountType, orElse: () => const MapEntry('', 0))
          .key;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _requestIdController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  final attachmentController = TextEditingController();
  List<Map<String, String>> selectedFilesMap = [];
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.model != null;
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
        title: AppLocalKay.vacation.tr(),
        helpText: AppLocalKay.housing_allowance_request_screen.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HousingAllowanceForm(
                formKey: _formKey,
                dateController: _dateController,
                noteController: _noteController,
                amountController: _amountController,
                requestIdController: _requestIdController,
                travelPlaceValues: travelPlaceValues,
                selectedPlace: selectedPlace,
                onPlaceChanged: (val) => setState(() => selectedPlace = val),
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
                  widget.model == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: GestureDetector(
                            onTap: () async {
                              final cubit = context.read<ServicesCubit>();

                              await cubit.getAttachments(
                                requestId: widget.model!.requestID,
                                attchmentType: 22,
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
                                            requestId: widget.model!.requestID,
                                            attchmentType: 22,
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
                                                            requestId: widget.model!.requestID,
                                                            attachId: item.ser,
                                                            context: context,
                                                            attchmentType: 22,
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
      bottomNavigationBar: HousingAllowanceSaveButton(
        formKey: _formKey,
        empCode: widget.empCode,
        attachmentList: attachmentList,
        newrequest: () {
          _dateController.text = DateFormat('yyyy-MM-dd', 'en').format(DateTime.now());

          _noteController.clear();
          _amountController.clear();
        },
        isEdit: isEdit,
        controllers: HousingAllowanceControllers(
          dateController: _dateController,
          noteController: _noteController,
          amountController: _amountController,
          requestIdController: _requestIdController,
          selectedPlaceNotifier: ValueNotifier(selectedPlace),
          travelPlaceValues: travelPlaceValues,
        ),
      ),
    );
  }
}
