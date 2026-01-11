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
import 'package:my_template/features/services/data/model/request_leave/employee_model.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';

class EmployeesFaceRegistrationScreen extends StatefulWidget {
  const EmployeesFaceRegistrationScreen({super.key});

  @override
  State<EmployeesFaceRegistrationScreen> createState() => _EmployeesFaceRegistrationScreenState();
}

class _EmployeesFaceRegistrationScreenState extends State<EmployeesFaceRegistrationScreen> {
  static const String globalClassId = 'employees';
  String? selectedEmployeeId;
  String? selectedEmployeeName;
  bool isCapturing = false;
  Set<String> registeredEmployees = {};

  @override
  void initState() {
    super.initState();
    _loadRegisteredEmployees();
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

    setState(() {
      isCapturing = true;
    });

    final cubit = context.read<FaceRecognitionCubit>();
    await cubit.initializeCamera();

    // Open camera in BottomSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.8),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: _buildCameraView(cubit.state),
      ),
    ).whenComplete(() {
      setState(() {
        isCapturing = false;
      });
      cubit.disposeResources();
    });
  }

  Future<void> _captureAndRegister() async {
    if (selectedEmployeeId == null || selectedEmployeeName == null) return;

    final cubit = context.read<FaceRecognitionCubit>();

    // تسجيل الوجه
    await cubit.registerStudentFace(
      studentId: selectedEmployeeId!,
      studentName: selectedEmployeeName!,
      classId: globalClassId,
    );

    // بعد ما يخلص التسجيل
    if (mounted) {
      // غلق الـ BottomSheet
      Navigator.pop(context);

      // إعادة تهيئة الحالة
      setState(() {
        isCapturing = false;
        selectedEmployeeId = null;
        selectedEmployeeName = null;
      });

      // اظهار Toast نجاح
      CommonMethods.showToast(
        message: AppLocalKay.face_registered_successfully.tr(),
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
        body: BlocConsumer<FaceRecognitionCubit, FaceRecognitionState>(
          listener: (context, state) {
            if (state is FaceRecognitionRegistered) {
              setState(() {
                registeredEmployees.add(state.faceModel.studentId);
                selectedEmployeeId = null;
                selectedEmployeeName = null;
              });

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
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
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
    );
  }

  Widget _buildStatistics(List<EmployeeModel> registered, List<EmployeeModel> notRegistered) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primaryColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(AppLocalKay.employees_registered.tr(), '${registered.length}', Colors.green),
          _buildStat(
            AppLocalKay.employees_not_registered.tr(),
            '${notRegistered.length}',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.formTitle20Style(
            context,
          ).copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(title, style: AppTextStyle.text14RGrey(context).copyWith(color: Colors.grey)),
      ],
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final empId = employee.empCode.toString();
        final empName = context.locale.languageCode == 'ar'
            ? (employee.empName ?? '')
            : (employee.empNameE ?? '');
        return _buildEmployeeCard(empId, empName, isRegistered);
      },
    );
  }

  Widget _buildEmployeeCard(String id, String name, bool isRegistered) {
    final isSelected = selectedEmployeeId == id;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isSelected ? AppColor.primaryColor(context).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: isRegistered
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              child: Icon(
                isRegistered ? Icons.verified : Icons.person_outline,
                color: isRegistered ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(name, style: AppTextStyle.text16MSecond(context)),
            subtitle: Text(
              isRegistered
                  ? AppLocalKay.face_registered_successfully.tr()
                  : AppLocalKay.register_face.tr(),
              style: AppTextStyle.text14RGrey(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: isRegistered
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteRegistration(id),
                  )
                : ElevatedButton(
                    onPressed: () {
                      _selectEmployee(id, name);
                      _openCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalKay.face_registration.tr()),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(FaceRecognitionState state) {
    final cubit = context.read<FaceRecognitionCubit>();
    final controller = cubit.cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(controller),
        // Overlay
        Positioned(
          top: 24.h,
          left: 16.w,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  selectedEmployeeName ?? '',
                  style: AppTextStyle.text16MSecond(context).copyWith(color: Colors.white),
                ),
                SizedBox(height: 6.h),
                Text(
                  AppLocalKay.position_face_in_frame.tr(),
                  style: AppTextStyle.text14RGrey(context),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 260.w,
            height: 320.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(160),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
            ),
          ),
        ),
        // Capture Button
        Positioned(
          bottom: 40.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'cancel',
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
              FloatingActionButton.extended(
                heroTag: 'capture',
                onPressed: state is FaceRecognitionProcessing ? null : _captureAndRegister,
                backgroundColor: AppColor.primaryColor(context),
                icon: state is FaceRecognitionProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.camera),
                label: Text(AppLocalKay.capture_face.tr()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteRegistration(String employeeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Text(AppLocalKay.delete_face_registration.tr()),
          ],
        ),
        content: Text(AppLocalKay.delete_user_message.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalKay.cancel.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalKay.delete.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final cubit = context.read<FaceRecognitionCubit>();
      await cubit.deleteStudentFace(employeeId);

      setState(() {
        registeredEmployees.remove(employeeId);
      });

      if (mounted) {
        CommonMethods.showToast(
          message: AppLocalKay.face_registration_deleted.tr(),
          type: ToastType.success,
        );
      }
    }
  }
}
