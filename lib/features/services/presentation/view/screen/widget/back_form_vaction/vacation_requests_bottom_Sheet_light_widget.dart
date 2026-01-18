import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_template/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/services/data/model/vacation_back/vacation_back_model.dart';

class VacationRequestsBottomSheetLight extends StatefulWidget {
  final List<VacationBackRequestModel> requests;
  final Function(VacationBackRequestModel) onSelect;

  const VacationRequestsBottomSheetLight({
    super.key,
    required this.requests,
    required this.onSelect,
  });

  @override
  State<VacationRequestsBottomSheetLight> createState() => _VacationRequestsBottomSheetLightState();
}

class _VacationRequestsBottomSheetLightState extends State<VacationRequestsBottomSheetLight> {
  List<VacationBackRequestModel> filteredRequests = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredRequests = widget.requests;
  }

  void _filter(String query) {
    setState(() {
      filteredRequests = widget.requests
          .where(
            (r) =>
                (r.empName).toLowerCase().contains(query.toLowerCase()) ||
                (r.empNameE).toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalKay.backleaverequests.tr(),
            style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
          ),
          const SizedBox(height: 10),
          CustomFormField(controller: _searchController, onChanged: _filter),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                AppLocalKay.empCode.tr(),
                style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
              ),
              const Spacer(),
              Text(
                AppLocalKay.employeeName.tr(),
                style: AppTextStyle.text16MSecond(context, color: AppColor.blackColor(context)),
              ),
              const Spacer(),
            ],
          ),
          const Divider(),
          Expanded(
            child: filteredRequests.isEmpty
                ? Center(
                    child: Text(
                      AppLocalKay.noResults.tr(),
                      style: AppTextStyle.text16MSecond(
                        context,
                        color: AppColor.blackColor(context),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredRequests.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final r = filteredRequests[index];
                      final displayName = context.locale.languageCode == 'en'
                          ? r.empName
                          : r.empNameE;
                      return ListTile(
                        trailing: Text(displayName),
                        title: Text(r.empCode.toString()),
                        onTap: () => widget.onSelect(r),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
