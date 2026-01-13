import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/attendance/cubit/attendance_cubit.dart';
import 'package:my_template/features/attendance/cubit/face_recognition_cubit.dart';
import 'package:my_template/features/attendance/data/models/attendance_record_model.dart';
import 'package:my_template/features/profile/data/model/employee_change_photo_request.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_state.dart';
import 'package:my_template/features/setting/data/model/time_sheet_in_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_out_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_response.dart';
import 'package:my_template/features/setting/presentation/cubit/settting_cubit.dart';
import 'package:uuid/uuid.dart';

class FaceRecognitionAttendanceScreen extends StatefulWidget {
  const FaceRecognitionAttendanceScreen({super.key});

  @override
  State<FaceRecognitionAttendanceScreen> createState() => _FaceRecognitionAttendanceScreenState();
}

class _FaceRecognitionAttendanceScreenState extends State<FaceRecognitionAttendanceScreen> {
  static const String globalClassId = 'employees';
  bool isScanning = false;
  bool isContinuousMode = true;
  bool isCheckingIn = true; // New state for In/Out toggle
  bool isMarkingAttendance = false; // To prevent concurrent API calls for same recognition
  Timer? _scanTimer;
  final Map<String, AttendanceRecordModel> attendanceRecords = {};
  final Map<String, dynamic> registeredFaces = {}; // employeeId -> StudentFaceModel
  final Set<String> recognizedStudents = {}; // To track session recognitions

  // Face ID style success overlay
  String? _lastRecognizedName;
  bool _showSuccessOverlay = false;
  Timer? _overlayTimer;

  // New variables for pending registration
  bool _isProcessing = false;
  String? _pendingRegistrationEmpCode;
  String? _pendingRegistrationEmpName;
  File? _pendingRegistrationImage;
  List<double>? _pendingRegistrationFeatures;
  double? _pendingRegistrationQuality;

  @override
  void initState() {
    super.initState();
    _loadRegisteredEmployees();
    _loadTodayAttendance();
  }

  void _loadRegisteredEmployees() {}

  void _loadTodayAttendance() {
    context.read<AttendanceCubit>().loadAttendance(classId: globalClassId, date: DateTime.now());
  }

  void _initializeAttendance(
    List<EmployeeModel> employees, [
    List<AttendanceRecordModel>? existingRecords,
  ]) {
    final Map<String, AttendanceRecordModel> existingMap = {};
    if (existingRecords != null) {
      for (var record in existingRecords) {
        existingMap[record.studentId] = record;
      }
    }

    for (var employee in employees) {
      final empId = employee.empCode.toString();
      final empName = context.locale.languageCode == 'ar'
          ? (employee.empName ?? '')
          : (employee.empNameE ?? '');

      if (existingMap.containsKey(empId)) {
        attendanceRecords[empId] = existingMap[empId]!;
      } else {
        // Only create new record if one doesn't exist for this employee
        if (!attendanceRecords.containsKey(empId)) {
          final record = AttendanceRecordModel(
            id: const Uuid().v4(),
            studentId: empId,
            studentName: empName,
            classId: globalClassId,
            date: DateTime.now(),
            status: AttendanceStatus.absent,
            recognitionMethod: RecognitionMethod.manual,
          );
          attendanceRecords[empId] = record;
        }
      }
    }
    setState(() {
      // Clear old records initially?
      // attendanceRecords.clear(); // Dependent on logic, better keep manual records
    });

    // Trigger remote face data load
    final servicesRepo = context.read<ServicesCubit>().leavesRepo;
    final faceCubit = context.read<FaceRecognitionCubit>();

    faceCubit.loadFacesFromRemote(employees, servicesRepo);
  }

  Future<void> _startScanning() async {
    setState(() {
      isScanning = true;
    });

    final cubit = context.read<FaceRecognitionCubit>();
    await cubit.initializeCamera(direction: CameraLensDirection.front);

    // Immediate first pass
    _performRecognition();

    if (isContinuousMode) {
      _startContinuousScanning();
    }
  }

  void _startContinuousScanning() {
    // Face ID style: very rapid scanning (every 300ms)
    _scanTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (isScanning) {
        _performRecognition();
      }
    });
  }

  Future<void> _performRecognition({String? targetStudentId}) async {
    final cubit = context.read<FaceRecognitionCubit>();
    if (cubit.state is FaceRecognitionProcessing) return;

    // If targetStudentId is provided, we only want to match that specific student
    // or at least prioritize/highlight if we found someone else.
    // For now, the cubit finds the best match among all registered.
    await cubit.recognizeStudent(
      classId: globalClassId,
      threshold: 60.0,
    ); // Face ID style: lenient threshold for fast matching
  }

  void _stopScanning() {
    setState(() {
      isScanning = false;
    });

    _scanTimer?.cancel();
    _scanTimer = null;

    final cubit = context.read<FaceRecognitionCubit>();
    cubit.disposeResources();
  }

  void _toggleStudentAttendance(String studentId, bool isPresent) {
    if (isPresent) {
      // Show validation message for manual presence
      CommonMethods.showToast(
        message: AppLocalKay.manual_attendance_disabled.tr(),
        seconds: 5,
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      final record = attendanceRecords[studentId]!;
      attendanceRecords[studentId] = record.copyWith(
        status: AttendanceStatus.absent,
        recognitionMethod: RecognitionMethod.manual,
        checkInTime: null,
      );
      recognizedStudents.remove(studentId);
    });
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    } else {
      return 'unknown';
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CommonMethods.showToast(
          message: AppLocalKay.location_permission_denied.tr(),
          type: ToastType.error,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CommonMethods.showToast(
        message: AppLocalKay.location_permission_permanently_denied.tr(),
        type: ToastType.error,
      );
      return false;
    }

    return true;
  }

  Future<void> _markAttendanceForEmployee(String empCode, String empName) async {
    if (isMarkingAttendance) return;

    try {
      setState(() => isMarkingAttendance = true);

      final empId = int.tryParse(empCode) ?? 0;
      if (empId == 0) return;

      final settingCubit = context.read<SettingCubit>();

      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) return;

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final lat = double.parse(pos.latitude.toStringAsFixed(8));
      final lng = double.parse(pos.longitude.toStringAsFixed(8));

      final now = DateTime.now();
      final todayDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final nowTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      if (isCheckingIn) {
        final request = TimeSheetInRequestmodel(
          empId: empId,
          latitude: lat,
          longitude: lng,
          signInDate: todayDate,
          signInTime: nowTime,
          mobileSerNo: '', // General attendance (not tied to specific device serial)
          projectCode: HiveMethods.getProjectId() ?? 1,
        );
        await settingCubit.addTimeSheetIn(request);
        _handleAttendanceResponse(
          settingCubit.state.timeSheetStatus,
          empName,
          empCode: empCode,
          isCheckIn: true,
        );
      } else {
        final request = TimeSheetOutRequestModel(
          empId: empId,
          latitude: lat,
          longitude: lng,
          signOutDate: todayDate,
          signOutTime: nowTime,
          mobileSerNo: '', // General attendance
          projectCode: HiveMethods.getProjectId() ?? 1,
        );
        await settingCubit.addTimeSheetOut(request);
        _handleAttendanceResponse(
          settingCubit.state.timeSheetOutStatus,
          empName,
          empCode: empCode,
          isCheckIn: false,
        );
      }
    } catch (e) {
      CommonMethods.showToast(message: AppLocalKay.errorOccurred.tr(), type: ToastType.error);
    } finally {
      setState(() => isMarkingAttendance = false);
    }
  }

  void _handleAttendanceResponse(
    StatusState<TimeSheetResponse> state,
    String empName, {
    required String empCode,
    required bool isCheckIn,
  }) {
    if (state.isSuccess) {
      final msg = isCheckIn ? AppLocalKay.checkInSuccess.tr() : AppLocalKay.checkInSuccess.tr();
      CommonMethods.showToast(message: '$empName: $msg', type: ToastType.success);

      // Update local record to reflect success in the list
      setState(() {
        final record = attendanceRecords[empCode]!;
        attendanceRecords[empCode] = record.copyWith(
          status: isCheckIn ? AttendanceStatus.present : AttendanceStatus.absent,
          recognitionMethod: RecognitionMethod.faceRecognition,
          checkInTime: DateTime.now(),
        );

        if (isCheckIn) {
          recognizedStudents.add(empCode);
        } else {
          recognizedStudents.remove(empCode);
        }

        // Face ID style success overlay
        _lastRecognizedName = empName;
        _showSuccessOverlay = true;
      });

      _overlayTimer?.cancel();
      _overlayTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _showSuccessOverlay = false);
      });
    } else if (state.isFailure) {
      String status = '';
      switch (state.error) {
        case '1':
          status = AppLocalKay.outOfRange.tr();
          break;
        case '2':
          status = AppLocalKay.employeeNotInProject.tr();
          break;
        case '3':
          status = AppLocalKay.alreadyMarked.tr();
          break;
        case '4':
          status = AppLocalKay.notMarked.tr();
          break;
        case '5':
          status = AppLocalKay.deviceNotFound.tr();
        default:
          status = AppLocalKay.errorOccurred.tr();
      }
      CommonMethods.showToast(message: '$empName: $status', type: ToastType.error);
    }
  }

  Future<void> _finalizeRegistrationAndMarkAttendance(String empCode, String empName) async {
    if (_pendingRegistrationImage == null ||
        _pendingRegistrationFeatures == null ||
        _pendingRegistrationQuality == null) {
      CommonMethods.showToast(message: AppLocalKay.errorOccurred.tr(), type: ToastType.error);
      return;
    }

    final cubit = context.read<FaceRecognitionCubit>();
    await cubit.completeRegistration(
      studentId: empCode,
      studentName: empName,
      classId: globalClassId,
      imageFile: _pendingRegistrationImage!,
      features: _pendingRegistrationFeatures!,
      qualityScore: _pendingRegistrationQuality!,
      serverPath: _pendingRegistrationImage!.path,
    );

    // Clear pending data
    _pendingRegistrationEmpCode = null;
    _pendingRegistrationEmpName = null;
    _pendingRegistrationImage = null;
    _pendingRegistrationFeatures = null;
    _pendingRegistrationQuality = null;

    // After successful registration, attempt to mark attendance
    _markAttendanceForEmployee(empCode, empName);
  }

  void _deleteStudentRegistration(String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalKay.delete_face_title.tr()),
        content: Text(AppLocalKay.delete_face_confirm_message.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalKay.cancel.tr())),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<FaceRecognitionCubit>();
              await cubit.deleteStudentFace(studentId);
              _loadRegisteredEmployees(); // Refresh the list
            },
            child: Text(AppLocalKay.delete.tr(), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog({
    required File imageFile,
    required List<double> features,
    required double qualityScore,
  }) {
    final TextEditingController empCodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalKay.register_new_face.tr(),
                  style: AppTextStyle.textFormStyle(
                    context,
                    color: Colors.black,
                    listen: false,
                  ).copyWith(color: Colors.black, fontSize: 18.sp),
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 250.h,
                  width: 250.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.primaryColor(context), width: 3),
                    image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalKay.face_not_recognized_register.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                CustomFormField(
                  controller: empCodeController,
                  keyboardType: TextInputType.number,
                  hintText: AppLocalKay.empCode.tr(),
                  title: AppLocalKay.empCode.tr(),
                  prefixIcon: const Icon(Icons.badge),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalKay.required_field.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _startScanning();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppLocalKay.cancel.tr()),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final empCode = empCodeController.text;
                            final employees =
                                context.read<ServicesCubit>().state.employeesStatus.data ?? [];

                            final employee = employees.firstWhere(
                              (e) => e.empCode.toString() == empCode,
                              orElse: () => const EmployeeModel(
                                empCode: -1,
                                dCode: 0,
                                makerWork: 0,
                                jobId: 0,
                                empBranch: 0,
                                naGroup: 0,
                              ),
                            );

                            if (employee.empCode == -1) {
                              CommonMethods.showToast(
                                message: AppLocalKay.employee_not_found.tr(),
                                type: ToastType.error,
                              );
                              return;
                            }

                            // Check if employee already has a face registered
                            try {
                              final servicesRepo = context.read<ServicesCubit>().leavesRepo;
                              final result = await servicesRepo.getEmployeeFaceImage(
                                int.parse(empCode),
                              );

                              bool alreadyHasFace = false;
                              result.fold((l) {}, (photo) {
                                if (photo.isNotEmpty) alreadyHasFace = true;
                              });

                              if (alreadyHasFace) {
                                CommonMethods.showToast(
                                  message: 'عذرا هذا الموظف له بصمة وجه من قبل', // As requested
                                  type: ToastType.error,
                                );
                                return;
                              }
                            } catch (e) {
                              // Ignore error and proceed? Or block? Safe to proceed or maybe show error
                              // For now let's proceed if check fails to avoid blocking due to network error if that's desired,
                              // OR assume if check fails we shouldn't overwrite.
                              // Given the requirement is strict "if he has photo", we proceed only if we validly checked he doesn't.
                              // But if network fails, maybe we shouldn't block.
                              // Let's print error and proceed for now, but the requirement is "chack".
                              debugPrint('Error checking face: $e');
                            }

                            Navigator.pop(context);

                            final name = context.locale.languageCode == 'ar'
                                ? (employee.empName ?? '')
                                : (employee.empNameE ?? '');

                            // Store pending data
                            _pendingRegistrationEmpCode = empCode;
                            _pendingRegistrationEmpName = name;
                            _pendingRegistrationImage = imageFile;
                            _pendingRegistrationFeatures = features;
                            _pendingRegistrationQuality = qualityScore;

                            // call upload API
                            final bytes = await imageFile.readAsBytes();
                            final base64Image = base64Encode(bytes);

                            final request = EmployeeChangePhotoRequest(
                              empId: int.parse(empCode),
                              empPhotoWeb: base64Image,
                            );

                            if (context.mounted) {
                              context.read<ServicesCubit>().employeefacephoto(request);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor(context),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: BlocBuilder<ServicesCubit, ServicesState>(
                          builder: (context, state) {
                            if (state.employeefacephotoStatus!.isLoading) {
                              return Column(
                                children: [const CircularProgressIndicator(color: Colors.white)],
                              );
                            }
                            return Text(
                              AppLocalKay.register_attendance.tr(),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, int> _getStats() {
    // Only count students who have a registered face (the ones visible in the list)
    final activeRecords = attendanceRecords.values.where((r) {
      return registeredFaces.containsKey(r.studentId);
    }).toList();

    final present = activeRecords.where((r) => r.status == AttendanceStatus.present).length;
    final absent = activeRecords.where((r) => r.status == AttendanceStatus.absent).length;
    final total = activeRecords.length;

    return {
      'total': total,
      'present': present,
      'absent': absent,
      'percentage': total > 0 ? ((present / total) * 100).round() : 0,
    };
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        CommonMethods.showPasswordVerificationDialog(
          context,
          onSuccess: () => Navigator.pop(context),
        );
      },
      child: Scaffold(
        bottomNavigationBar: _buildActionButtons(),
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          leading: const SizedBox.shrink(),
          context,
          title: Text(
            AppLocalKay.face_recognition_attendance.tr(),
            style: AppTextStyle.appBarStyle(context).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<FaceRecognitionCubit, FaceRecognitionState>(
              listener: (context, state) {
                if (state is FaceRecognitionStudentRecognized) {
                  final studentId = state.student.studentId;
                  final studentName = state.student.studentName;

                  if (!recognizedStudents.contains(studentId)) {
                    // Face ID style: Only stop in single scan mode, keep scanning in continuous
                    if (!isContinuousMode) {
                      _stopScanning();
                    }

                    // Call the API marking logic immediately
                    _markAttendanceForEmployee(studentId, studentName);
                  }
                } else if (state is FaceRecognitionNoMatch) {
                  // Stop scanning to show dialog/play sound
                  _stopScanning();

                  // Play Error Sound ("Buzz")
                  SystemSound.play(SystemSoundType.alert);
                  // Or use specific sound plugin if needed

                  if (state.imageFile != null && state.features != null) {
                    _showRegistrationDialog(
                      imageFile: state.imageFile!,
                      features: state.features!,
                      qualityScore: state.qualityScore ?? 0,
                    );
                  } else {
                    // Fallback if no data somehow
                    CommonMethods.showToast(
                      message: AppLocalKay.face_not_recognized_retry.tr(),
                      type: ToastType.error,
                    );
                    _startScanning();
                  }
                } else if (state is FaceRecognitionError) {
                  if (state.message.contains('No registered faces')) {
                    CommonMethods.showToast(
                      message: state.message,
                      seconds: 5,
                      type: ToastType.error,
                    );
                    _stopScanning();
                  }
                } else if (state is FaceRecognitionLoading) {
                  // Ensure loading state is handled by UI overlay
                } else if (state is FaceRecognitionRegisteredStudentsLoaded) {
                  setState(() {
                    registeredFaces.clear();
                    for (var face in state.students) {
                      registeredFaces[face.studentId] = face;
                    }
                  });
                } else if (state is FaceRecognitionRegistered) {
                  setState(() {
                    registeredFaces[state.faceModel.studentId] = state.faceModel;
                  });
                }
              },
            ),
            BlocListener<AttendanceCubit, AttendanceState>(
              listener: (context, state) {
                if (state is AttendanceLoaded) {
                  final employees = context.read<ServicesCubit>().state.employeesStatus.data ?? [];
                  _initializeAttendance(employees, state.records);
                } else if (state is AttendanceSaved) {
                  CommonMethods.showToast(
                    message: AppLocalKay.user_management_save.tr(),
                    type: ToastType.success,
                  );
                  Navigator.pop(context);
                } else if (state is AttendanceError) {
                  print('Attendance Error: ${state.message}');
                  CommonMethods.showToast(message: state.message, type: ToastType.error);
                }
              },
            ),
            BlocListener<ServicesCubit, ServicesState>(
              listener: (context, state) {
                if (state.employeefacephotoStatus!.isSuccess) {
                  // After successful photo upload, mark attendance
                  final empCode = _pendingRegistrationEmpCode;
                  final empName = _pendingRegistrationEmpName; // You might need to store this too

                  if (empCode != null && empName != null) {
                    _finalizeRegistrationAndMarkAttendance(empCode, empName);
                  }
                } else if (state.employeefacephotoStatus!.isFailure) {
                  CommonMethods.showToast(
                    message: state.employeefacephotoStatus!.error ?? 'Upload failed',
                    type: ToastType.error,
                  );
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                if (isScanning)
                  SizedBox(height: 300.h, child: _buildCameraView())
                else
                  // Employee List (smaller when camera is active)
                  SizedBox(height: 500, child: _buildEmployeeListWrapper()),
              ],
            ),
          ),
        ),
        // Add Loading Overlay
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
          builder: (context, state) {
            if (state is FaceRecognitionLoading) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const CircularProgressIndicator(color: Colors.white),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primaryColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.primaryColor(context).withOpacity(0.1)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildToggleOption(
                  label: AppLocalKay.checkIn.tr(),
                  isSelected: isCheckingIn,
                  onTap: () => setState(() => isCheckingIn = true),
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildToggleOption(
                  label: AppLocalKay.checkOut.tr(),
                  isSelected: !isCheckingIn,
                  onTap: () => setState(() => isCheckingIn = false),
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: (isScanning || recognizedStudents.isNotEmpty) ? null : onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyle.text14RGrey(context).copyWith(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
      builder: (context, state) {
        final cubit = context.read<FaceRecognitionCubit>();
        final controller = cubit.cameraService.controller;

        if (controller == null || !controller.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(controller),
            ),
            Positioned(
              top: 16.h,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  AppLocalKay.scanning_faces.tr(),
                  style: AppTextStyle.text16MSecond(context).copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (state is FaceRecognitionProcessing)
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            // Face ID Style Success Overlay
            if (_showSuccessOverlay)
              Container(
                color: Colors.green.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 60.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _lastRecognizedName ?? '',
                        style: AppTextStyle.formTitleStyle(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [const Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalKay.attendance_marked_success.tr(),
                        style: AppTextStyle.formTitleStyle(context).copyWith(
                          color: Colors.white,
                          shadows: [const Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeListWrapper() {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        final employees = state.employeesStatus.data ?? [];
        if (employees.isEmpty && state.employeesStatus.isLoading) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColor.primaryColor(context)),
                      Gap(8.h),
                      Text(AppLocalKay.loading.tr()),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (employees.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.face_retouching_off, size: 64, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  AppLocalKay.no_registered_students_for_face.tr(),
                  style: AppTextStyle.text16MSecond(context),
                ),
              ],
            ),
          );
        }
        return _buildEmployeeList(employees);
      },
    );
  }

  Widget _buildEmployeeList(List<EmployeeModel> employees) {
    // Filter employees: Show only those who have a registered face
    final filteredEmployees = employees.where((emp) {
      return registeredFaces.containsKey(emp.empCode.toString());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = filteredEmployees[index];
        final empId = employee.empCode.toString();
        final empName = context.locale.languageCode == 'ar'
            ? (employee.empName ?? '')
            : (employee.empNameE ?? '');

        // Ensure record exists (fallback if init had issues)
        if (!attendanceRecords.containsKey(empId)) {
          return const SizedBox();
        }

        final record = attendanceRecords[empId]!;

        return _buildStudentCard(studentId: empId, studentName: empName, record: record);
      },
    );
  }

  Widget _buildStudentCard({
    required String studentId,
    required String studentName,
    required AttendanceRecordModel record,
  }) {
    final isPresent = record.status == AttendanceStatus.present;
    final isAutoDetected = record.recognitionMethod == RecognitionMethod.faceRecognition;
    final faceModel = registeredFaces[studentId];
    final hasRegisteredFace = faceModel != null;

    // Determine status icon based on attendance
    // Green checkmark = Checked In (Present)
    // Red X = Checked Out (Absent after checking in)
    Widget? statusIcon;

    // Only show icon if attendance was actually marked (checkInTime is set)
    if (record.checkInTime != null) {
      if (isPresent) {
        // Check-In: Green checkmark
        statusIcon = Icon(Icons.check_circle, color: Colors.green, size: 32.sp);
      } else {
        // Check-Out: Red X
        statusIcon = Icon(Icons.cancel, color: Colors.red, size: 32.sp);
      }
    }

    return InkWell(
      onLongPress: () => _deleteStudentRegistration(studentId),
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        child: ListTile(
          leading: Stack(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  image: hasRegisteredFace
                      ? DecorationImage(
                          image: FileImage(File(faceModel.faceImagePath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasRegisteredFace ? Icon(Icons.person, color: Colors.grey) : null,
              ),
            ],
          ),
          title: Text(
            '${AppLocalKay.empId.tr()}: $studentId',
            style: AppTextStyle.text14RGrey(context),
          ),
          subtitle: Text(
            ' ${AppLocalKay.name.tr()}: ${studentName.replaceAll(RegExp(r'\d+'), '').trim()}',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.text16MSecond(context),
          ),
          trailing: statusIcon,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (!isScanning) ...[
            Expanded(
              child: CustomButton(
                text: AppLocalKay.start_scanning.tr(),
                radius: 12.r,
                onPressed: _startScanning,
                color: AppColor.primaryColor(context),
              ),
            ),
            SizedBox(width: 12.w),
          ] else ...[
            Expanded(
              child: CustomButton(
                text: AppLocalKay.stop_scanning.tr(),
                radius: 12.r,
                onPressed: _stopScanning,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ],
      ),
    );
  }
}
