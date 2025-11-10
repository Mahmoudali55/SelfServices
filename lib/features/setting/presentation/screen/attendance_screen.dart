import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
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
import 'package:my_template/core/utils/url_launcher_methods%20.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/services/presentation/view/screen/widget/transfer/custom_project_picker_widget.dart';
import 'package:my_template/features/setting/data/model/time_sheet_in_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_out_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_response.dart';
import 'package:my_template/features/setting/presentation/cubit/settting_cubit.dart';
import 'package:my_template/features/setting/presentation/screen/widget/add_device_bottom_sheet.dart';
import 'package:my_template/features/setting/presentation/screen/widget/attendance_button_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String status = AppLocalKay.chooseCheckInCheckOut.tr();
  double? lat, lng;
  bool isLoadingIn = false;
  bool isLoadingOut = false;

  int empId = int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0;

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

  final projectIdController = TextEditingController();
  final projectNameController = TextEditingController();

  Future<void> _markAttendance(bool isCheckIn, int empcode, String? mobileser) async {
    try {
      if (isCheckIn) {
        setState(() => isLoadingIn = true);
      } else {
        setState(() => isLoadingOut = true);
      }

      final settingCubit = context.read<SettingCubit>();

      bool isSupported = await auth.isDeviceSupported();
      bool canCheck = await auth.canCheckBiometrics;
      if (!isSupported || !canCheck) {
        status = AppLocalKay.deviceNotSupported.tr();
        CommonMethods.showToast(message: status, type: ToastType.error);
        return;
      }

      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) return;

      bool didAuthenticate = await auth.authenticate(
        localizedReason: AppLocalKay.fingerprintPrompt.tr(),
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: false,
          stickyAuth: false,
          sensitiveTransaction: true,
        ),
      );
      if (!didAuthenticate) {
        status = AppLocalKay.authFailed.tr();
        CommonMethods.showToast(message: status, type: ToastType.error);
        return;
      }

      final deviceId = await getDeviceId();
      final savedDeviceId = HiveMethods.getDeviceId();

      if (savedDeviceId != null && savedDeviceId != deviceId) {
        status = context.locale.languageCode == 'ar'
            ? 'عذرًا، هذا الجهاز مسجل باسم موظف غير موجود، ولا يُسمح بتسجيل البصمة من خلاله.'
            : 'Sorry, this device is registered with a different employee name and is not allowed to sign in with it.';
        CommonMethods.showToast(message: status, type: ToastType.error);
        return;
      }

      status = AppLocalKay.loadingdata.tr();
      CommonMethods.showToast(message: status, type: ToastType.help);

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      lat = double.parse(pos.latitude.toStringAsFixed(8));
      lng = double.parse(pos.longitude.toStringAsFixed(8));

      final now = DateTime.now();
      final todayDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final nowTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      if (isCheckIn) {
        final request = TimeSheetInRequestmodel(
          empId: empcode,
          latitude: lat!,
          longitude: lng!,
          signInDate: todayDate,
          signInTime: nowTime,
          mobileSerNo: mobileser ?? '',
          projectCode: int.tryParse(projectIdController.text) ?? HiveMethods.getProjectId() ?? 0,
        );
        await settingCubit.addTimeSheetIn(request);
        _handleResponse(settingCubit.state.timeSheetStatus, isCheckIn: true);

        if (settingCubit.state.timeSheetStatus.isSuccess && savedDeviceId == null) {
          await HiveMethods.saveDeviceId(deviceId);
        }
      } else {
        final request = TimeSheetOutRequestModel(
          empId: empcode,
          latitude: lat!,
          longitude: lng!,
          signOutDate: todayDate,
          signOutTime: nowTime,
          mobileSerNo: mobileser ?? '',
        );
        await settingCubit.addTimeSheetOut(request);
        _handleResponse(settingCubit.state.timeSheetOutStatus, isCheckIn: false);
      }
    } catch (e) {
      status = AppLocalKay.errorOccurred.tr();
      CommonMethods.showToast(message: status, type: ToastType.error);
      debugPrint('Attendance Error: $e');
    } finally {
      setState(() {
        isLoadingIn = false;
        isLoadingOut = false;
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CommonMethods.showToast(
          message: context.locale.languageCode == 'ar'
              ? 'يرجى السماح بالوصول للموقع أولاً'
              : 'Please allow location access first',
          type: ToastType.error,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar'
            ? 'تم منع التطبيق من الوصول للموقع نهائيًا، الرجاء تعديل الإعدادات'
            : 'Location permission is permanently denied, please go to settings and allow location access',
        type: ToastType.error,
      );
      return false;
    }

    return true;
  }

  void _handleResponse(StatusState<TimeSheetResponse> state, {required bool isCheckIn}) {
    if (state.isLoading) {
      status = AppLocalKay.loading.tr();
      CommonMethods.showToast(message: status, type: ToastType.help);
      return;
    }
    if (state.isSuccess) {
      status = isCheckIn ? AppLocalKay.checkInSuccess.tr() : AppLocalKay.checkInSuccess.tr();
      CommonMethods.showToast(message: status, type: ToastType.success);
      return;
    }
    if (state.isFailure) {
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
          status = isCheckIn ? AppLocalKay.checkInSuccess.tr() : AppLocalKay.checkInSuccess.tr();
      }
      CommonMethods.showToast(message: status, type: ToastType.error);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateFormat('hh:mm a').format(DateTime.now());
    final currentDate = DateFormat(
      'EEEE, dd MMM yyyy',
      context.locale.languageCode,
    ).format(DateTime.now());

    return Scaffold(
      appBar: CustomAppBar(
        context,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(AppLocalKay.timesheet.tr(), style: AppTextStyle.text18MSecond(context)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSlide(
                    offset: const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 600),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: AppColor.whiteColor(context),
                        shadowColor: Colors.grey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColor.blackColor(context),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentDate,
                                    style: AppTextStyle.text16MSecond(context).copyWith(
                                      fontSize: 16,
                                      color: AppColor.blackColor(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: AppColor.blackColor(context),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentTime,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.blackColor(context),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Gap(100.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AttendanceButtonWidget(
                        label: AppLocalKay.checkIn.tr(),
                        color: Colors.greenAccent.shade400,
                        isLoading: isLoadingIn,
                        isOtherButtonLoading: isLoadingOut,
                        onTap: () async {
                          final homeCubit = context.read<HomeCubit>();
                          await homeCubit.loadVacationAdditionalPrivilages(
                            pageID: 14,
                            empId: empId,
                          );
                          final privilegeData = homeCubit.state.vacationStatus.data;
                          final PagePrivID = (privilegeData != null) ? privilegeData.pagePrivID : 0;

                          final currentDeviceId = await getDeviceId();
                          if (PagePrivID == 1) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      context.locale.languageCode == 'ar'
                                          ? 'اختر نوع الحضور'
                                          : 'Select Check In Type',
                                      style: AppTextStyle.text18MSecond(
                                        context,
                                        color: AppColor.primaryColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    customCheckInForSelf(context, currentDeviceId),
                                    customCheckInforAnotherEmployee(context),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            final cubit = context.read<SettingCubit>();
                            await cubit.employeeMobileSerialno(empId);
                            final mobileStatus = cubit.state.mobileSerialnoStatus;
                            if (mobileStatus.isSuccess) {
                              final mobileList = mobileStatus.data?.data;
                              final mobileSerNo = (mobileList != null && mobileList.isNotEmpty)
                                  ? mobileList.first.mobileSerno
                                  : null;

                              if (mobileSerNo == null) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (_) => Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: AddDeviceBottomSheet(
                                      onSubmit: () async {
                                        Navigator.pop(context);
                                        CommonMethods.showToast(
                                          message: context.locale.languageCode == 'ar'
                                              ? 'تم تسجيل الجهاز بنجاح'
                                              : 'Device registered successfully',
                                          type: ToastType.success,
                                        );
                                        ();
                                        await _markAttendance(true, empId, currentDeviceId);
                                      },
                                    ),
                                  ),
                                );
                              } else if (mobileSerNo == HiveMethods.getDeviceId()) {
                                await _markAttendance(true, empId, currentDeviceId);
                              } else if (mobileSerNo != HiveMethods.getDeviceId()) {
                                CommonMethods.showToast(
                                  message: context.locale.languageCode == 'ar'
                                      ? 'عذرا ، يوجد جهاز اخر مسجل لهذا المستخدم'
                                      : 'This device is already registered by another user',
                                  type: ToastType.error,
                                );
                              } else {}
                            } else if (mobileStatus.isFailure) {
                              CommonMethods.showToast(
                                message: mobileStatus.error ?? 'Error',
                                type: ToastType.error,
                              );
                            }
                          }
                        },
                      ),
                      AttendanceButtonWidget(
                        label: AppLocalKay.checkOut.tr(),
                        color: Colors.redAccent,
                        isLoading: isLoadingOut,
                        isOtherButtonLoading: isLoadingIn,
                        onTap: () async {
                          final homeCubit = context.read<HomeCubit>();
                          await homeCubit.loadVacationAdditionalPrivilages(
                            pageID: 14,
                            empId: empId,
                          );
                          final PagePrivID = homeCubit.state.vacationStatus.data?.pagePrivID ?? 0;

                          final currentDeviceId = await getDeviceId();
                          if (PagePrivID == 1) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      context.locale.languageCode == 'ar'
                                          ? 'اختر نوع الانصراف'
                                          : 'Select Check Out Type',
                                      style: AppTextStyle.text18MSecond(
                                        context,
                                        color: AppColor.primaryColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    customCheckOut(context, currentDeviceId),
                                    customCheckOutforAnotherEmployee(context),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            final cubit = context.read<SettingCubit>();
                            await cubit.employeeMobileSerialno(empId);
                            final mobileStatus = cubit.state.mobileSerialnoStatus;
                            if (mobileStatus.isSuccess) {
                              final mobileList = mobileStatus.data?.data;
                              final mobileSerNo = (mobileList != null && mobileList.isNotEmpty)
                                  ? mobileList.first.mobileSerno
                                  : null;
                              if (mobileSerNo == null) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (_) => Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: AddDeviceBottomSheet(
                                      onSubmit: () async {
                                        Navigator.pop(context);
                                        CommonMethods.showToast(
                                          message: context.locale.languageCode == 'ar'
                                              ? 'تم تسجيل الجهاز بنجاح'
                                              : 'Device registered successfully',
                                          type: ToastType.success,
                                        );
                                        ();
                                        await _markAttendance(false, empId, currentDeviceId);
                                      },
                                    ),
                                  ),
                                );
                              } else if (mobileSerNo == HiveMethods.getDeviceId()) {
                                await _markAttendance(true, empId, currentDeviceId);
                              } else if (mobileSerNo != HiveMethods.getDeviceId()) {
                                CommonMethods.showToast(
                                  message: context.locale.languageCode == 'ar'
                                      ? 'عذرا ، يوجد جهاز اخر مسجل لهذا المستخدم'
                                      : 'This device is already registered by another user',
                                  type: ToastType.error,
                                );
                              } else {}
                            } else if (mobileStatus.isFailure) {
                              CommonMethods.showToast(
                                message: mobileStatus.error ?? 'Error',
                                type: ToastType.error,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (lat != null && lng != null)
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.location_on_outlined, color: AppColor.whiteColor(context)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          backgroundColor: AppColor.primaryColor(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => UrlLauncherMethods.launchGoogleMap(lat, lng),
                        label: Text(
                          AppLocalKay.showOnMap.tr(),
                          style: AppTextStyle.text16MSecond(context).copyWith(
                            color: AppColor.whiteColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Gap(10.h),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => CustomProjectPickerWidget(
                          context: context,
                          projectIdController: projectIdController,
                          projectNameController: projectNameController,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            context.locale.languageCode == 'ar'
                                ? 'تغير مشروعك الي مشروع اخر'
                                : 'Change your project to another project',
                            style: AppTextStyle.text16MSecond(context).copyWith(
                              color: AppColor.primaryColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListTile customCheckOutforAnotherEmployee(BuildContext context) {
    return ListTile(
      title: Text(
        context.locale.languageCode == 'ar'
            ? 'تسجيل انصراف لموظف آخر'
            : 'Check Out for another employee',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async {
        Navigator.pop(context);
        final empIdController = TextEditingController();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Container(
            padding: const EdgeInsets.all(20),
            height: 400.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomFormField(
                  title: context.locale.languageCode == 'ar' ? 'رقم الموظف' : 'Employee ID',
                  hintText: context.locale.languageCode == 'ar'
                      ? 'ادخل رقم الموظف'
                      : 'Enter employee ID',
                  controller: empIdController,
                  keyboardType: TextInputType.number,
                ),
                const Spacer(),
                CustomButton(
                  text: context.locale.languageCode == 'ar' ? 'تسجيل انصراف' : 'Check Out',
                  onPressed: () async {
                    Navigator.pop(context);
                    await _markAttendance(false, int.parse(empIdController.text), '');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile customCheckOut(BuildContext context, String currentDeviceId) {
    return ListTile(
      title: Text(
        context.locale.languageCode == 'ar' ? 'تسجيل انصراف ' : 'Check Out',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async {
        Navigator.pop(context);
        final cubit = context.read<SettingCubit>();
        await cubit.employeeMobileSerialno(empId);
        final mobileStatus = cubit.state.mobileSerialnoStatus;
        if (mobileStatus.isSuccess) {
          final mobileData = mobileStatus.data;
          final mobileSerNo = mobileData?.data.first.mobileSerno;
          if (mobileSerNo == null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: AddDeviceBottomSheet(
                  onSubmit: () async {
                    Navigator.pop(context);
                    CommonMethods.showToast(
                      message: context.locale.languageCode == 'ar'
                          ? 'تم تسجيل الجهاز بنجاح'
                          : 'Device registered successfully',
                      type: ToastType.success,
                    );
                    ();
                    await _markAttendance(false, empId, currentDeviceId);
                  },
                ),
              ),
            );
          } else if (mobileSerNo == HiveMethods.getDeviceId()) {
            await _markAttendance(false, empId, currentDeviceId);
          } else if (mobileSerNo != HiveMethods.getDeviceId()) {
            CommonMethods.showToast(
              message: context.locale.languageCode == 'ar'
                  ? 'عذرا ، يوجد جهاز اخر مسجل لهذا المستخدم'
                  : 'This device is already registered by another user',
              type: ToastType.error,
            );
          } else {}
        } else if (mobileStatus.isFailure) {
          CommonMethods.showToast(message: mobileStatus.error ?? 'Error', type: ToastType.error);
        }
      },
    );
  }

  ListTile customCheckInforAnotherEmployee(BuildContext context) {
    return ListTile(
      title: Text(
        context.locale.languageCode == 'ar'
            ? 'تسجيل حضور لموظف آخر'
            : 'Check In for Another Employee',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async {
        Navigator.pop(context);
        final empIdController = TextEditingController();
        showModalBottomSheet(
          context: context,

          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Container(
            padding: const EdgeInsets.all(20),
            height: 400.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomFormField(
                  title: context.locale.languageCode == 'ar' ? 'رقم الموظف' : 'Employee ID',
                  hintText: context.locale.languageCode == 'ar'
                      ? 'ادخل رقم الموظف'
                      : 'Enter Employee ID',
                  controller: empIdController,
                  keyboardType: TextInputType.number,
                ),
                const Spacer(),
                CustomButton(
                  text: context.locale.languageCode == 'ar' ? 'تسجيل حضور' : 'Check In',
                  onPressed: () async {
                    Navigator.pop(context);
                    await _markAttendance(true, int.parse(empIdController.text), '');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  ListTile customCheckInForSelf(BuildContext context, String currentDeviceId) {
    return ListTile(
      title: Text(
        context.locale.languageCode == 'ar' ? 'تسجيل حضور ' : 'Check In for Self',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async {
        Navigator.pop(context);
        final cubit = context.read<SettingCubit>();
        await cubit.employeeMobileSerialno(empId);
        final mobileStatus = cubit.state.mobileSerialnoStatus;
        if (mobileStatus.isSuccess) {
          final mobileData = mobileStatus.data;
          final mobileSerNo = mobileData?.data.first.mobileSerno;
          if (mobileSerNo == null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: AddDeviceBottomSheet(
                  onSubmit: () async {
                    Navigator.pop(context);
                    CommonMethods.showToast(
                      message: context.locale.languageCode == 'ar'
                          ? 'تم تسجيل الجهاز بنجاح'
                          : 'Device registered successfully',
                      type: ToastType.success,
                    );
                    ();
                    await _markAttendance(true, empId, currentDeviceId);
                  },
                ),
              ),
            );
          } else if (mobileSerNo == HiveMethods.getDeviceId()) {
            await _markAttendance(true, empId, currentDeviceId);
          } else if (mobileSerNo != HiveMethods.getDeviceId()) {
            CommonMethods.showToast(
              message: context.locale.languageCode == 'ar'
                  ? 'عذرا ، يوجد جهاز اخر مسجل لهذا المستخدم'
                  : 'This device is already registered by another user',
              type: ToastType.error,
            );
          } else {}
        } else if (mobileStatus.isFailure) {
          CommonMethods.showToast(message: mobileStatus.error ?? 'Error', type: ToastType.error);
        }
      },
    );
  }
}
