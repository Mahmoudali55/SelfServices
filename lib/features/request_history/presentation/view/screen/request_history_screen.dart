import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_history_body.dart';

class RequestHistoryScreen extends StatefulWidget {
  final int empCode;
  final String? initialType;
  final int? pagePrivID;

  const RequestHistoryScreen({super.key, required this.empCode, this.initialType, this.pagePrivID});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  bool showSearch = false;
  String searchQuery = '';
  RequestFilterType filterType = RequestFilterType.all;

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim().toLowerCase();
    });
  }

  bool showFilter = false;
  @override
  void initState() {
    super.initState();
    final homeCubit = context.read<HomeCubit>();
    homeCubit.loadVacationAdditionalPrivilages(pageID: 14, empId: widget.empCode);

    homeCubit.stream.listen((state) {
      if (state.vacationStatus.data?.pagePrivID == 1) {
        setState(() {
          showFilter = true;
        });
      } else {
        setState(() {
          showFilter = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        context,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          if (showFilter)
            PopupMenuButton<RequestFilterType>(
              icon: const Icon(Icons.filter_list),
              initialValue: filterType,
              itemBuilder: (context) => [
                PopupMenuItem(value: RequestFilterType.all, child: Text(AppLocalKay.all.tr())),
                PopupMenuItem(
                  value: RequestFilterType.myRequests,
                  child: Text(AppLocalKay.myRequests.tr()),
                ),
                PopupMenuItem(
                  value: RequestFilterType.submittedRequests,
                  child: Text(AppLocalKay.submittedRequests.tr()),
                ),
              ],
              onSelected: (value) {
                setState(() {
                  filterType = value;
                });
              },
            ),
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) {
                  onSearchChanged('');
                }
              });
            },
          ),
        ],
        bottom: showSearch
            ? PreferredSize(
                preferredSize: Size.fromHeight(70.h),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomFormField(
                    prefixIcon: const Icon(Icons.search),
                    hintText: AppLocalKay.search.tr(),
                    onChanged: onSearchChanged,
                  ),
                ),
              )
            : null,
      ),
      body: RequestHistoryBody(
        empCode: widget.empCode,
        initialType: widget.initialType,
        searchQuery: searchQuery,
        filterType: filterType,
      ),
    );
  }
}

enum RequestFilterType { all, myRequests, submittedRequests }
