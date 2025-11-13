import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer_list.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_state.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_type_dropdown.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_tabView.dart';

class RequestHistoryBody extends StatefulWidget {
  final int empCode;
  final String? initialType;

  const RequestHistoryBody({super.key, required this.empCode, this.initialType});

  @override
  State<RequestHistoryBody> createState() => _RequestHistoryBodyState();
}

class _RequestHistoryBodyState extends State<RequestHistoryBody> {
  late String selectedType;
  late final List<String> requestTypes;
  @override
  void initState() {
    super.initState();
    requestTypes = [
      AppLocalKay.leavesRequest.tr(),
      AppLocalKay.backleave.tr(),
      AppLocalKay.deductionRequest.tr(),
      AppLocalKay.solfaRequest.tr(),
      AppLocalKay.siraRequest.tr(),
      AppLocalKay.sakalRequest.tr(),
      AppLocalKay.nqalRequest.tr(),
      AppLocalKay.tickets.tr(),
      AppLocalKay.requestgenerals.tr(),
      AppLocalKay.requestchangePhone.tr(),
    ];
    final Map<String, String> requestTypeKeys = {
      'leavesRequest': AppLocalKay.leavesRequest.tr(),
      'backleave': AppLocalKay.backleave.tr(),
      'deductionRequest': AppLocalKay.deductionRequest.tr(),
      'solfaRequest': AppLocalKay.solfaRequest.tr(),
      'siraRequest': AppLocalKay.siraRequest.tr(),
      'sakalRequest': AppLocalKay.sakalRequest.tr(),
      'nqalRequest': AppLocalKay.nqalRequest.tr(),
      'tickets': AppLocalKay.tickets.tr(),
      'requestgenerals': AppLocalKay.requestgenerals.tr(),
      'requestchangePhone': AppLocalKay.requestchangePhone.tr(),
    };
    final incomingKey = widget.initialType?.trim() ?? 'leavesRequest';
    selectedType = requestTypeKeys[incomingKey] ?? AppLocalKay.leavesRequest.tr();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRequests());
  }

  void _fetchRequests() {
    final cubit = context.read<VacationRequestsCubit>();
    final empCode = widget.empCode;

    if (selectedType == AppLocalKay.leavesRequest.tr()) {
      cubit.getVacationRequests(empcode: empCode);
    } else if (selectedType == AppLocalKay.backleave.tr()) {
      cubit.getRequestVacationBack(empCode: empCode);
    } else if (selectedType == AppLocalKay.solfaRequest.tr()) {
      cubit.getSolfaRequests(empCode: empCode);
    } else if (selectedType == AppLocalKay.deductionRequest.tr()) {
      cubit.getAllHousingAllowance(empCode: empCode);
    } else if (selectedType == AppLocalKay.sakalRequest.tr()) {
      cubit.getAllResignationInProccissing(empCode: empCode);
    } else if (selectedType == AppLocalKay.siraRequest.tr()) {
      cubit.getAllCars(empCode: empCode);
    } else if (selectedType == AppLocalKay.nqalRequest.tr()) {
      cubit.getAllTransfer(empCode: empCode);
    } else if (selectedType == AppLocalKay.tickets.tr()) {
      cubit.getTicketRequests(empCode: empCode);
    } else if (selectedType == AppLocalKay.requestgenerals.tr()) {
      cubit.getAllRequestsGeneral(empCode: empCode, requestId: 5007);
    } else if (selectedType == AppLocalKay.requestchangePhone.tr()) {
      cubit.getAllRequestsGeneral(empCode: empCode, requestId: 5008);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RequestTypeDropdown(
            requestTypes: requestTypes,
            selectedType: selectedType,
            onChanged: (value) {
              setState(() => selectedType = value);
              _fetchRequests();
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: BlocBuilder<VacationRequestsCubit, VacationRequestsState>(
              builder: (context, state) {
                final status = _mapStatus(state);
                if (status.isLoading) {
                  return const Center(
                    child: CustomShimmerList(
                      length: 4,
                      height: 300,
                      width: double.infinity,
                      radius: 30,
                      padding: EdgeInsets.all(16),
                    ),
                  );
                }
                if (status.isFailure) {
                  return Center(child: Text(status.error ?? 'Something went wrong'));
                }

                final data = (status.data is List) ? status.data as List : [];
                final classified = _classifyRequests(data, selectedType == AppLocalKay.leave.tr());

                return RequestsTabView(
                  empCode: widget.empCode,
                  underReview: classified['underReview']!,
                  approved: classified['approved']!,
                  rejected: classified['rejected']!,
                );
              },
            ),
          ),
          Gap(90.h),
        ],
      ),
    );
  }

  StatusState _mapStatus(VacationRequestsState state) {
    return selectedType == AppLocalKay.leavesRequest.tr()
        ? state.vacationRequestsStatus
        : selectedType == AppLocalKay.backleave.tr()
        ? state.requestVacationBackStatus
        : selectedType == AppLocalKay.solfaRequest.tr()
        ? state.getSolfaStatus
        : selectedType == AppLocalKay.deductionRequest.tr()
        ? state.getAllHousingAllowanceStatus
        : selectedType == AppLocalKay.sakalRequest.tr()
        ? state.getAllResignationStatus
        : selectedType == AppLocalKay.siraRequest.tr()
        ? state.getAllCarsStatus
        : selectedType == AppLocalKay.nqalRequest.tr()
        ? state.getAllTransferStatus
        : selectedType == AppLocalKay.tickets.tr()
        ? state.getAllTicketsStatus
        : state.dynamicOrderStatus;
  }

  Map<String, List<dynamic>> _classifyRequests(List<dynamic> requests, bool isLeave) {
    final under = <dynamic>[];
    final approved = <dynamic>[];
    final rejected = <dynamic>[];
    for (var r in requests) {
      final status = isLeave ? r.requestDesc : (r.requestDesc ?? '');
      if (status.contains('تحت الاجراء') || status.contains('Under Review')) {
        under.add(r);
      } else if (status.contains('تمت الموافقة علي الطلب') || status.contains('Approved')) {
        approved.add(r);
      } else if (status.contains('تم رفض الطلب') || status.contains('Rejected')) {
        rejected.add(r);
      }
    }
    return {'underReview': under, 'approved': approved, 'rejected': rejected};
  }
}
