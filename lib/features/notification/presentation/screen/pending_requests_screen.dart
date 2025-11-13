import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer_list.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/notification/data/model/req_count_response.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_state.dart';
import 'package:my_template/features/notification/presentation/screen/widget/empty_requests_widget.dart';
import 'package:my_template/features/notification/presentation/screen/widget/show_notes_bottom_sheet.dart';

import 'widget/pending_request_card.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key, required this.type});
  final RequestType type;

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotifictionCubit>().fetchRequests(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BlocBuilder<NotifictionCubit, NotificationState>(
        builder: (context, state) {
          final status = _extractStatus(state);
          final requests = status.$2;
          return requests.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: Text(
                            AppLocalKay.acceptAll.tr(),
                            style: AppTextStyle.text16MSecond(context, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.greenColor(context),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final notes = await showNotesBottomSheet(context);
                            context.read<NotifictionCubit>().decidingAll(
                              notes: notes ?? '',
                              requests: requests,
                              requestType: widget.type,
                              isAccept: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                          label: Text(
                            AppLocalKay.rejectAll.tr(),
                            style: AppTextStyle.text16MSecond(context, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final notes = await showNotesBottomSheet(context);
                            context.read<NotifictionCubit>().decidingAll(
                              notes: notes ?? '',
                              requests: requests,
                              requestType: widget.type,
                              isAccept: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
      appBar: CustomAppBar(
        context,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.blackColor(context)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          RequestTypeHelper.name(widget.type),
          style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
        ),
      ),
      body: BlocBuilder<NotifictionCubit, NotificationState>(
        builder: (context, state) {
          final status = _extractStatus(state);
          final isLoading = status.$1;
          final requests = status.$2;

          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomShimmerList(height: 200, length: 10),
            );
          }

          if (requests.isEmpty) {
            return const EmptyRequestsWidget();
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<NotifictionCubit>().fetchRequests(widget.type),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        PendingRequestCard(request: requests[index], type: widget.type),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  (bool, List<dynamic>) _extractStatus(NotificationState state) {
    switch (widget.type) {
      case RequestType.vacation:
        return (
          state.vacationRequestToDecideModelList.isLoading,
          state.vacationRequestToDecideModelList.data ?? [],
        );
      case RequestType.loan:
        return (
          state.solfaRequestToDecideModel.isLoading,
          state.solfaRequestToDecideModel.data ?? [],
        );
      case RequestType.resignation:
        return (
          state.resignationRequestToDecideModel.isLoading,
          state.resignationRequestToDecideModel.data ?? [],
        );
      case RequestType.travelTicket:
        return (
          state.ticketRequestToDecideModel.isLoading,
          state.ticketRequestToDecideModel.data ?? [],
        );
      case RequestType.housingAllowance:
        return (
          state.housingAllowanceRequestToDecideModel.isLoading,
          state.housingAllowanceRequestToDecideModel.data ?? [],
        );
      case RequestType.carRequest:
        return (state.carRequestToDecideModel.isLoading, state.carRequestToDecideModel.data ?? []);
      case RequestType.returnFromLeave:
        return (
          state.vacationBackRequestToDecideModel.isLoading,
          state.vacationBackRequestToDecideModel.data ?? [],
        );
      case RequestType.transferRequest:
        return (
          state.transferRequestToDecideModel.isLoading,
          state.transferRequestToDecideModel.data ?? [],
        );
      case RequestType.dynamicRequest:
        return (
          state.dynamicRequestToDecideModel5007.isLoading,
          state.dynamicRequestToDecideModel5007.data ?? [],
        );
      case RequestType.changeIdPhoneRequest:
        return (
          state.dynamicRequestToDecideModel5008.isLoading,
          state.dynamicRequestToDecideModel5008.data ?? [],
        );
      default:
        return (false, []);
    }
  }
}
