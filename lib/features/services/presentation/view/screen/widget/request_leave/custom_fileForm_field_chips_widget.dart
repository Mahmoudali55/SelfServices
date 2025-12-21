import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:open_filex/open_filex.dart';

class CustomFileFormFieldChips extends StatefulWidget {
  const CustomFileFormFieldChips({
    super.key,
    required this.controller,
    required this.onFilesChanged,
  });

  final TextEditingController controller;
  final void Function(List<Map<String, String>> files) onFilesChanged;

  @override
  State<CustomFileFormFieldChips> createState() => _CustomFileFormFieldChipsState();
}

class _CustomFileFormFieldChipsState extends State<CustomFileFormFieldChips> {
  List<Map<String, String>> selectedFilesMap = [];
  List<String> selectedFilesPaths = [];

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      final newFiles = result.files.map((file) {
        return {
          'AttatchmentName': file.name,
          'AttchmentFileName': file.path!,
          'LocalPath': file.path!,
        };
      }).toList();

      setState(() {
        selectedFilesMap.addAll(newFiles);
        selectedFilesPaths.addAll(newFiles.map((e) => e['AttchmentFileName']!));
        widget.controller.text = selectedFilesMap.map((e) => e['AttatchmentName']).join(', ');
      });

      // رفع الملفات
      context.read<ServicesCubit>().uploadFiles(selectedFilesPaths);
    }
  }

  void _removeFile(Map<String, String> file) {
    setState(() {
      selectedFilesMap.remove(file);
      selectedFilesPaths.remove(file['AttchmentFileName']);
      widget.controller.text = selectedFilesMap.map((e) => e['AttatchmentName']).join(', ');
    });
    widget.onFilesChanged(selectedFilesMap);
  }

  void _showSelectedFilesSheet(BuildContext context) {
    if (selectedFilesMap.isEmpty) {
      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar' ? 'لا توجد ملفات مختارة' : 'No files selected',
        type: ToastType.warning,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.locale.languageCode == 'ar' ? 'الملفات المختارة' : 'Selected Files',
                style: AppTextStyle.formTitleStyle(context, color: AppColor.primaryColor(context)),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedFilesMap.length,
                  itemBuilder: (context, index) {
                    final file = selectedFilesMap[index];
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(file['AttatchmentName'] ?? ''),
                      onTap: () {
                        final localPath = file['LocalPath'] ?? '';
                        final serverPath = file['AttchmentFileName'] ?? '';
                        final path = localPath.isNotEmpty ? localPath : serverPath;

                        if (path.isEmpty) return;

                        final isImage = [
                          '.jpg',
                          '.jpeg',
                          '.png',
                          '.gif',
                          '.bmp',
                          '.webp',
                        ].any((ext) => path.toLowerCase().endsWith(ext));

                        if (isImage) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ImagePreviewScreen(imagePath: path)),
                          );
                        } else {
                          OpenFilex.open(path);
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeFile(file);
                          Navigator.pop(context);
                          _showSelectedFilesSheet(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServicesCubit, ServicesState>(
      listener: (context, state) {
        final status = state.uploadedFilesStatus;

        if (status.isLoading) return;

        if (status.isSuccess) {
          // تحويل List<String> → List<Map<String,String>>
          // مع الحفاظ على المسارات المحلية للمعاينة
          final responseFiles = (status.data as List<String>).asMap().entries.map((entry) {
            final index = entry.key;
            final serverPath = entry.value;
            String localPath = '';
            if (index < selectedFilesMap.length) {
              localPath = selectedFilesMap[index]['LocalPath'] ?? '';
            }

            return {
              'AttatchmentName': serverPath.split('\\').last,
              'AttchmentFileName': serverPath,
              'LocalPath': localPath,
            };
          }).toList();

          setState(() {
            selectedFilesMap = responseFiles;
            selectedFilesPaths = responseFiles.map((e) => e['AttchmentFileName']!).toList();
            widget.controller.text = selectedFilesMap.map((e) => e['AttatchmentName']).join(', ');
          });

          widget.onFilesChanged(selectedFilesMap);

          CommonMethods.showToast(
            message: context.locale.languageCode == 'ar'
                ? 'تم رفع الملفات بنجاح'
                : 'Files uploaded successfully',
            type: ToastType.success,
          );
        } else if (status.isFailure) {
          CommonMethods.showToast(
            message: status.error ?? 'فشل رفع الملفات',
            type: ToastType.error,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalKay.attachmentName.tr(),
            style: AppTextStyle.formTitleStyle(context, color: AppColor.blackColor(context)),
          ),
          const SizedBox(height: 5),
          CustomFormField(
            controller: widget.controller,
            readOnly: true,
            hintText: AppLocalKay.selectFile.tr(),
            suffixIcon: IconButton(
              icon: Icon(Icons.attach_file, color: AppColor.primaryColor(context)),
              onPressed: _pickFiles,
            ),
          ),
          if (selectedFilesMap.isNotEmpty) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.folder_open),
              label: Text(
                context.locale.languageCode == 'ar'
                    ? 'عرض الملفات المختارة'
                    : 'Show Selected Files',
              ),
              onPressed: () => _showSelectedFilesSheet(context),
            ),
          ],
        ],
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context),
      body: Center(child: Image.file(File(imagePath), fit: BoxFit.contain)),
    );
  }
}
