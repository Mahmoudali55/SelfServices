import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/file_viewer_utils.dart';
import 'package:my_template/features/notification/data/model/vacation_request_to_decide_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';

class PendingRequestDetailScreen extends StatelessWidget {
  final VacationRequestToDecideModel request;

  const PendingRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;

    Widget buildInfoRow({
      required IconData icon,
      required String title,
      required String value,
      Widget? value2,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyle.text16MSecond(context)),
                      const Spacer(),
                      value2 ?? const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyle.text14RGrey(context)),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.blackColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        context,
        centerTitle: true,
        title: Text(
          AppLocalKay.orderDetails.tr(),
          style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow(
                  icon: Icons.numbers,
                  title: AppLocalKay.empCode.tr(),
                  value: request.empCode?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.numbers,
                  title: AppLocalKay.requestNumber.tr(),
                  value: request.requestId?.toString() ?? '',
                ),

                buildInfoRow(
                  icon: Icons.person,
                  title: AppLocalKay.employee.tr(),
                  value: langCode == 'en' ? request.empEngName ?? '' : request.empArName ?? '',
                ),
                buildInfoRow(
                  icon: Icons.calendar_month,
                  title: AppLocalKay.requestDate.tr(),
                  value: request.insrtDate ?? '',
                ),
                buildInfoRow(
                  icon: Icons.list_alt,
                  title: AppLocalKay.management.tr(),
                  value: langCode == 'en'
                      ? request.empDeptEngName ?? ''
                      : request.empDeptArName ?? '',
                ),
                buildInfoRow(
                  icon: Icons.beach_access,
                  title: request.requestType.toString() == '1'
                      ? AppLocalKay.leaveType.tr()
                      : AppLocalKay.requestType.tr(),
                  value: request.requestType.toString() == '1'
                      ? (langCode == 'en'
                            ? (request.vacTypeNameEng ?? '')
                            : (request.vacTypeNameAr ?? ''))
                      : (request.strRequestType ?? ''),
                ),

                buildInfoRow(
                  icon: Icons.notes,
                  title: AppLocalKay.notes.tr(),
                  value: request.strNotes ?? '-',
                ),
                buildInfoRow(
                  icon: Icons.notes,
                  title: AppLocalKay.reason.tr(),
                  value: request.cAUSES ?? '-',
                ),
                if (request.attachments.isNotEmpty)
                  ...request.attachments.map((attachment) {
                    return buildInfoRow(
                      icon: Icons.remove_red_eye,
                      title: AppLocalKay.attachment.tr(),
                      value: formatAttachmentName(attachment.attachmentName),
                      value2: GestureDetector(
                        onTap: () async {
                          final cubit = context.read<ServicesCubit>();

                          await cubit.imageFileName(attachment.attachmentFileName ?? '', context);
                          final stateStatus = cubit.state.imageFileNameStatus;

                          if (stateStatus?.isSuccess == true) {
                            final base64File = stateStatus?.data ?? '';

                            await FileViewerUtils.displayFile(
                              context,
                              base64File,
                              attachment.attachmentFileName ?? '',
                            );
                          } else if (stateStatus?.isFailure == true) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(content: Text(stateStatus?.error ?? '')),
                            );
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColor.primaryColor(context),
                          ),
                          child: Text(
                            AppLocalKay.view.tr(),
                            style: AppTextStyle.text14RGrey(
                              context,
                              color: AppColor.whiteColor(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList()
                else
                  buildInfoRow(
                    icon: Icons.remove_red_eye,
                    title: AppLocalKay.attachment.tr(),
                    value: formatAttachmentName(request.attatchmentName),
                    value2: request.attatchmentName != null
                        ? GestureDetector(
                            onTap: () async {
                              final cubit = context.read<ServicesCubit>();

                              await cubit.imageFileName(request.AttchmentFileName ?? '', context);
                              final stateStatus = cubit.state.imageFileNameStatus;

                              if (stateStatus?.isSuccess == true) {
                                final base64File = stateStatus?.data ?? '';

                                await FileViewerUtils.displayFile(
                                  context,
                                  base64File,
                                  request.AttchmentFileName ?? '',
                                );
                              } else if (stateStatus?.isFailure == true) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      AlertDialog(content: Text(stateStatus?.error ?? '')),
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColor.primaryColor(context),
                              ),
                              child: Text(
                                AppLocalKay.view.tr(),
                                style: AppTextStyle.text14RGrey(
                                  context,
                                  color: AppColor.whiteColor(context),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatAttachmentName(String? name) {
    if (name == null || name.isEmpty) return '-';

    final parts = name.split('/');
    final fileName = parts.last;

    if (fileName.length <= 18) return fileName;

    final ext = fileName.split('.').last;
    return '${fileName.substring(0, 20)}...$ext';
  }
}
