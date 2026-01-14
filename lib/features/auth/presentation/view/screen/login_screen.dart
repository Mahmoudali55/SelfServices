import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/buttons/custom_button.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/custom_widgets/custom_lottie_isolate_widget.dart';
import 'package:my_template/core/images/app_images.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:my_template/features/auth/presentation/view/screen/base_url_page.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  initState() {
    context.read<AuthCubit>().passwordController.clear();
    context.read<AuthCubit>().mobileController.clear();
    context.read<HomeCubit>().getAllNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      appBar: CustomAppBar(
        height: 100.h,
        context,
        title: Text(
          AppLocalKay.login.tr(),
          style: AppTextStyle.formTitle20Style(
            context,
            color: AppColor.whiteColor(context),
          ).copyWith(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        appBarColor: AppColor.primaryColor(context),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          final languageCode = context.locale.languageCode;
          cubit.onLoginSuccess(context: context, state: state, languageCode: languageCode);
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.whiteColor(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.r),
                topRight: Radius.circular(25.r),
              ),
            ),
            child: Form(
              key: cubit.formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20.h,
                  children: [
                    Center(
                      child: LottieIsolate(assetPath: AppImages.login, height: 200.h),
                    ),
                    CustomFormField(
                      controller: cubit.mobileController,
                      title: AppLocalKay.empId.tr(),
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) => cubit.validateMobile(value, context),
                    ),
                    CustomFormField(
                      controller: cubit.passwordController,
                      title: AppLocalKay.password.tr(),
                      prefixIcon: const Icon(Icons.lock),
                      isPassword: true,
                      onFieldSubmitted: (_) => cubit.submitLogin(context),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BaseUrlPage()));
                      },
                      child: Text(
                        AppLocalKay.loginWithCompany.tr(),
                        style: AppTextStyle.formTitleStyle(
                          context,
                          color: AppColor.primaryColor(context),
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),

                    Semantics(
                      label: AppLocalKay.login.tr(),
                      hint: AppLocalKay.login.tr(),
                      button: true,
                      child: CustomButton(
                        text: AppLocalKay.login.tr(),
                        cubitState: cubit.state.loginStatus,
                        onPressed: () => cubit.submitLogin(context),
                      ),
                    ),
                    Gap(90.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
