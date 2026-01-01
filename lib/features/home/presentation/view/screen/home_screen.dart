import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/home/presentation/cubit/home_state.dart';
import 'package:my_template/features/home/presentation/view/screen/widget/custom_grid_view_list.dart';
import 'package:my_template/features/home/presentation/view/screen/widget/custom_home_header_widget.dart';
import 'package:my_template/features/home/presentation/view/screen/widget/news_marquee_widget.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:my_template/features/profile/presentation/cubit/prefile_cubit.dart';
import 'package:my_template/features/services/presentation/cubit/services_cubit.dart';
import 'package:my_template/features/setting/presentation/screen/widget/show_change_password_sheet_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.name, this.empId});
  final String? name;
  final int? empId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier('');
  late FocusNode _focusNode;
  String empName = '';
  String empCode = '';

  @override
  bool get wantKeepAlive => true; // منع إعادة بناء الشاشة

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    empCode = HiveMethods.getEmpCode() ?? '0';

    final homeCubit = context.read<HomeCubit>();
    final servicesCubit = context.read<ServicesCubit>();
    homeCubit.loadHomeData();
    homeCubit.loadVacationAdditionalPrivilages(pageID: 14, empId: int.tryParse(empCode) ?? 0);
    servicesCubit.getEmployees(empcode: int.tryParse(empCode) ?? 0, privid: 1);
    context.read<PrefileCubit>().getProfile(empId: int.tryParse(empCode) ?? 0);

    _searchController.addListener(() {
      searchQueryNotifier.value = _searchController.text.toLowerCase().trim();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storedPassword = HiveMethods.getEmpPassword();
      if (storedPassword == null || storedPassword.isEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          showChangePasswordSheet(context);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.locale.languageCode;
    empName = lang == 'ar' ? HiveMethods.getEmpNameAR() ?? '' : HiveMethods.getEmpNameEn() ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    searchQueryNotifier.dispose();
    super.dispose();
  }

  /// دالة لإعادة تحميل جميع البيانات
  Future<void> _refreshData() async {
    final empId = int.tryParse(empCode) ?? 0;
    final homeCubit = context.read<HomeCubit>();
    final servicesCubit = context.read<ServicesCubit>();
    final profileCubit = context.read<PrefileCubit>();
    final notificationCubit = context.read<NotifictionCubit>();

    // إعادة تعيين flags للسماح بإعادة التحميل
    await Future.wait([
      homeCubit.loadHomeData(),
      homeCubit.loadVacationAdditionalPrivilages(pageID: 14, empId: empId),
      servicesCubit.getEmployees(empcode: empId, privid: 1, refresh: true),
      profileCubit.getProfile(empId: empId),
      notificationCubit.getReqCount(empId: empId),
      notificationCubit.getemployeeRequestsNotify(empId: empId),
      notificationCubit.getDynamicRequestToDecideModel(empId: empId, requestType: 5007),
      notificationCubit.getDynamicRequestToDecideModel(empId: empId, requestType: 5008),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ضروري لعمل AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColor.whiteColor(context),
      extendBody: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColor.primaryColor(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // ضروري لعمل RefreshIndicator
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHomeHeaderWidget(
                searchController: _searchController,
                child: SizedBox(
                  height: 40.h,
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
                    cursorColor: AppColor.blackColor(context),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: ValueListenableBuilder<String>(
                        valueListenable: searchQueryNotifier,
                        builder: (context, value, _) {
                          return value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, color: Colors.black, size: 24),
                                  onPressed: () {
                                    _searchController.clear();
                                    searchQueryNotifier.value = '';
                                  },
                                )
                              : const SizedBox();
                        },
                      ),
                      hintText: context.locale.languageCode == 'ar'
                          ? 'ابحث عن خدمة...'
                          : 'Search for a service...',
                      hintStyle: AppTextStyle.text16MSecond(
                        context,
                        color: AppColor.blackColor(context),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColor.blackColor(context).withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColor.blackColor(context).withOpacity(0.2),
                        ),
                      ),
                      fillColor: AppColor.textFormFillColor(context),
                      filled: true,
                    ),
                    onFieldSubmitted: (value) => _focusNode.unfocus(),
                  ),
                ),
              ),
              Gap(10.h),

              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final newsList = state.newsStatus.data ?? [];
                  if (state.newsStatus.isLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state.newsStatus.isFailure || newsList.isEmpty) {
                    return SizedBox(
                      height: 30.h,
                      child: Center(
                        child: Text(
                          context.locale.languageCode == 'ar'
                              ? 'لا توجد أخبار حالياً'
                              : 'No news available',
                          style: AppTextStyle.text16MSecond(context, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return NewsTicker(newsList: newsList);
                },
              ),

              Gap(10.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(AppLocalKay.services.tr(), style: AppTextStyle.text18MSecond(context)),
              ),
              Gap(10.h),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    final langCode = context.locale.languageCode;
                    final services = state.servicesStatus.data ?? [];
                    final pageItem = state.vacationStatus.data;

                    return ValueListenableBuilder<String>(
                      valueListenable: searchQueryNotifier,
                      builder: (context, query, _) {
                        final filteredServices = services.where((service) {
                          final name = service.getName(langCode).toLowerCase().trim();
                          return name.contains(query);
                        }).toList();

                        final filteredServicesForGrid = filteredServices.where((service) {
                          if (service.id == 2 && pageItem?.pagePrivID != 1) return false;
                          return true;
                        }).toList();

                        if (filteredServicesForGrid.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppImages.assetsGlobalIconEmptyFolderIcon,
                                  height: 100,
                                  width: 100,
                                  color: AppColor.primaryColor(context),
                                ),
                                const Gap(10),
                                Text(
                                  context.locale.languageCode == 'ar'
                                      ? 'لا توجد خدمات مطابقة'
                                      : 'No matching services',
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: filteredServicesForGrid.length,
                          itemBuilder: (context, index) {
                            final service = filteredServicesForGrid[index];
                            final cubit = context.read<HomeCubit>();
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColor.whiteColor(context),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CustomGridViewList(
                                cubit: cubit,
                                service: service,
                                widget: widget,
                                langCode: langCode,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
