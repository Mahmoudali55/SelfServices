import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/attendance/cubit/face_recognition_cubit.dart';
import 'package:my_template/features/profile/data/model/employee_change_photo_request.dart';
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';

class EmployeesFaceRegistrationScreen extends StatefulWidget {
  const EmployeesFaceRegistrationScreen({super.key});

  @override
  State<EmployeesFaceRegistrationScreen> createState() => _EmployeesFaceRegistrationScreenState();
}

class _EmployeesFaceRegistrationScreenState extends State<EmployeesFaceRegistrationScreen>
    with TickerProviderStateMixin {
  static const String globalClassId = 'employees';

  String? selectedEmployeeId;
  String? selectedEmployeeName;

  Set<String> registeredEmployees = {};

  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegisteredEmployees();
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadRegisteredEmployees() async {
    final cubit = context.read<FaceRecognitionCubit>();
    await cubit.getRegisteredStudents(globalClassId);
  }

  void _selectEmployee(String id, String name) {
    setState(() {
      selectedEmployeeId = id;
      selectedEmployeeName = name;
    });
  }

  Future<void> _openCamera() async {
    if (selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalKay.select_student_to_register.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cubit = context.read<FaceRecognitionCubit>();
    await cubit.initializeCamera();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      enableDrag: false,
      builder: (_) => BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
        builder: (context, state) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _buildCameraView(state),
          );
        },
      ),
    ).whenComplete(() {
      cubit.disposeResources();
    });
  }

  Future<void> _captureAndRegister() async {
    if (selectedEmployeeId == null || selectedEmployeeName == null) return;
    context.read<FaceRecognitionCubit>().captureAndExtractFeatures();
  }

  /// ✅ هذه الدالة تم نقلها داخل الـ State لتعمل مع context و setState
  Future<void> _deleteRegistration(String employeeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(AppLocalKay.delete_user_message.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalKay.cancel.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalKay.delete.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<FaceRecognitionCubit>().deleteStudentFace(employeeId);

      setState(() {
        registeredEmployees.remove(employeeId);
      });

      CommonMethods.showToast(
        message: AppLocalKay.face_registration_deleted.tr(),
        type: ToastType.success,
      );
    }
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
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          leading: const SizedBox.shrink(),
          context,
          title: Text(
            AppLocalKay.face_registration.tr(),
            style: AppTextStyle.appBarStyle(context).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<FaceRecognitionCubit, FaceRecognitionState>(
              listener: (context, state) async {
                if (state is FaceRecognitionCaptured) {
                  final servicesCubit = context.read<ServicesCubit>();
                  final faceCubit = context.read<FaceRecognitionCubit>();

                  await servicesCubit.uploadFiles([state.imageFile.path]);

                  await servicesCubit.employeefacephoto(
                    EmployeeChangePhotoRequest(
                      empId: int.parse(selectedEmployeeId!),
                      empPhotoWeb: state.imageFile.path,
                    ),
                  );

                  await faceCubit.completeRegistration(
                    studentId: selectedEmployeeId!,
                    studentName: selectedEmployeeName!,
                    classId: globalClassId,
                    imageFile: state.imageFile,
                    features: state.features,
                    qualityScore: state.qualityScore,
                    serverPath: state.imageFile.path,
                  );
                } else if (state is FaceRecognitionRegistered) {
                  setState(() {
                    registeredEmployees.add(state.faceModel.studentId);
                    selectedEmployeeId = null;
                    selectedEmployeeName = null;
                  });

                  if (mounted && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  CommonMethods.showToast(
                    message: AppLocalKay.face_registered_successfully.tr(),
                    type: ToastType.success,
                  );
                } else if (state is FaceRecognitionError) {
                  CommonMethods.showToast(message: state.message, type: ToastType.error);
                } else if (state is FaceRecognitionRegisteredStudentsLoaded) {
                  setState(() {
                    registeredEmployees = state.students.map((e) => e.studentId).toSet();
                  });
                }
              },
            ),
          ],
          child: BlocBuilder<FaceRecognitionCubit, FaceRecognitionState>(
            builder: (context, state) {
              final employees = context.select(
                (ServicesCubit cubit) => cubit.state.employeesStatus.data ?? [],
              );

              final notRegistered = employees
                  .where((e) => !registeredEmployees.contains(e.empCode.toString()))
                  .toList();

              final registered = employees
                  .where((e) => registeredEmployees.contains(e.empCode.toString()))
                  .toList();

              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: AppColor.primaryColor(context),
                      labelColor: AppColor.primaryColor(context),
                      unselectedLabelColor: AppColor.blackColor(context),
                      tabs: [
                        Tab(text: AppLocalKay.employees_not_registered.tr()),
                        Tab(text: AppLocalKay.employees_registered.tr()),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildEmployeeListView(notRegistered, false),
                          _buildEmployeeListView(registered, true),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeListView(List<EmployeeModel> employees, bool isRegistered) {
    if (employees.isEmpty) {
      return Center(
        child: Text(
          AppLocalKay.no_registered_students_for_face.tr(),
          style: AppTextStyle.text16MSecond(context),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final id = employee.empCode.toString();
        final name = context.locale.languageCode == 'ar'
            ? (employee.empName ?? '')
            : (employee.empNameE ?? '');
        return _buildEmployeeCard(id, name, isRegistered);
      },
    );
  }

  Widget _buildEmployeeCard(String id, String name, bool isRegistered) {
    return ListTile(
      title: Text(name),
      trailing: isRegistered
          ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteRegistration(id),
            )
          : ElevatedButton(
              onPressed: () {
                _selectEmployee(id, name);
                _openCamera();
              },
              child: Text(AppLocalKay.face_registration.tr()),
            ),
    );
  }

  Widget _buildCameraView(FaceRecognitionState state) {
    final cubit = context.read<FaceRecognitionCubit>();
    final controller = cubit.cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final isProcessing = state is FaceRecognitionProcessing || state is FaceRecognitionCaptured;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 320.w,
                    height: 320.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(160.w),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: RotationTransition(
              turns: _scanController,
              child: Container(
                width: 330.w,
                height: 330.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.transparent, width: 4.w),
                ),
                child: CustomPaint(
                  painter: _ScannerRingPainter(color: Colors.blue.withOpacity(0.8)),
                ),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 315.w,
                height: 315.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2.w),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 100.h,
                  padding: EdgeInsets.only(top: 40.h, left: 16.w, right: 16.w),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        selectedEmployeeName ?? '',
                        style: AppTextStyle.text14MPrimary(
                          context,
                        ).copyWith(color: AppColor.whiteColor(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isProcessing)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.face, color: Colors.blue[300], size: 20.sp),
                        SizedBox(width: 12.w),
                        Flexible(
                          child: Text(
                            AppLocalKay.position_face_in_frame.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 40.h),
                GestureDetector(
                  onTap: isProcessing ? null : _captureAndRegister,
                  child: Container(
                    width: 85.w,
                    height: 85.w,
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isProcessing ? Colors.blue.withOpacity(0.5) : Colors.white,
                        width: 4.w,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isProcessing ? Colors.blue.withOpacity(0.3) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (!isProcessing)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isProcessing
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : Icon(Icons.camera_alt, color: Colors.black, size: 30.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isProcessing)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              color: Colors.blue,
                              strokeWidth: 4,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            AppLocalKay.loading.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerRingPainter extends CustomPainter {
  final Color color;
  _ScannerRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.01), color],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), 0, 3.14 * 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
