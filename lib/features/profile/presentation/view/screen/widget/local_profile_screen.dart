import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/profile/data/model/employee_change_photo_request.dart';
import 'package:my_template/features/profile/presentation/cubit/prefile_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadProfileWidget extends StatefulWidget {
  const UploadProfileWidget({super.key});

  @override
  State<UploadProfileWidget> createState() => _UploadProfileWidgetState();
}

class _UploadProfileWidgetState extends State<UploadProfileWidget> {
  File? _imageFile;
  String? _imageBase64;
  String? _cachedImageBase64;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCachedImage();
    });
  }

  Future<void> _loadCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cachedProfileImage');

    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _cachedImageBase64 = cached;
        _imageBase64 = cached;
      });
    } else {
      final empImage = context.read<PrefileCubit>().state.profileStatus.data?[0].empPhotoWeb ?? '';
      if (empImage.isNotEmpty) {
        await context.read<ServicesCubit>().imageFileName(empImage, context);
      }
    }
  }

  Future<void> _saveImageCache(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedProfileImage', base64Image);
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);

      setState(() {
        _imageFile = file;
        _isUploading = true;
      });

      await context.read<ServicesCubit>().uploadFiles([file.path]);

      await context.read<ServicesCubit>().employeechangephoto(
        EmployeeChangePhotoRequest(
          empId: int.parse(HiveMethods.getEmpCode() ?? '0'),
          empPhotoWeb: file.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicesCubit, ServicesState>(
      listener: (context, state) async {
        if (state.employeechangephoto?.isSuccess ?? false) {
          CommonMethods.showToast(
            message: AppLocalKay.photo_changed_success.tr(),
            type: ToastType.success,
          );

          final empImagePath = _imageFile?.path ?? '';
          if (empImagePath.isNotEmpty) {
            await context.read<ServicesCubit>().imageFileName(empImagePath, context);
          }
        }

        if (state.imageFileNameStatus?.isSuccess ?? false) {
          final newBase64 = state.imageFileNameStatus!.data;
          if (newBase64 != null && newBase64.isNotEmpty) {
            setState(() {
              _cachedImageBase64 = newBase64;
              _imageBase64 = newBase64;
              _imageFile = null;
              _isUploading = false;
            });

            await _saveImageCache(newBase64);
          } else {
            setState(() {
              _imageFile = null;
              _isUploading = false;
              _imageBase64 = _cachedImageBase64;
            });
          }
        }
      },
      builder: (context, state) {
        ImageProvider? imageProvider;

        if (_imageFile != null) {
          imageProvider = FileImage(_imageFile!);
        } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
          try {
            imageProvider = MemoryImage(base64Decode(_imageBase64!));
          } catch (_) {
            imageProvider = null;
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: imageProvider != null ? () => _viewImage(imageProvider!) : null,
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Colors.grey[300],
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 35)
                    : null,
              ),
            ),
            Positioned(
              bottom: -5.h,
              right: 5.h,
              child: InkWell(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColor.primaryColor(context),
                  child: _isUploading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColor.whiteColor(context),
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.camera_alt, color: AppColor.whiteColor(context), size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _viewImage(ImageProvider imageProvider) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
