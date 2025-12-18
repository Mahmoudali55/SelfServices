import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_loading/custom_shimmer_list.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_cubit.dart';
import 'package:my_template/features/request_history/presentation/view/cubit/vacation_requests_state.dart';
import 'package:my_template/features/request_history/presentation/view/screen/request_history_screen.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/request_type_dropdown.dart';
import 'package:my_template/features/request_history/presentation/view/screen/widget/requests_tabView.dart';

class RequestHistoryBody extends StatefulWidget {
  final int empCode;
  final String? initialType;
  final String searchQuery;
  final RequestFilterType filterType;

  const RequestHistoryBody({
    super.key,
    required this.empCode,
    this.initialType,
    this.searchQuery = '',
    required this.filterType,
  });

  @override
  State<RequestHistoryBody> createState() => RequestHistoryBodyState();
}

class RequestHistoryBodyState extends State<RequestHistoryBody> {
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
    return SafeArea(
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

          Expanded(
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

                var data = (status.data is List) ? status.data as List : [];

                if (widget.searchQuery.isNotEmpty) {
                  data = data.where((r) {
                    final name = (r.empName ?? '').toString().toLowerCase();
                    final nameE = (r.empNameE ?? '').toString().toLowerCase();
                    return name.contains(widget.searchQuery) || nameE.contains(widget.searchQuery);
                  }).toList();
                }

                data = _applyRequestFilter(data);

                final classified = _classifyRequests(
                  data,
                  selectedType == AppLocalKay.leavesRequest.tr(),
                );

                return RequestsTabView(
                  empCode: widget.empCode,
                  underReview: classified['underReview']!,
                  approved: classified['approved']!,
                  rejected: classified['rejected']!,
                );
              },
            ),
          ),
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

  List<dynamic> _applyRequestFilter(List<dynamic> requests) {
    if (widget.filterType == RequestFilterType.all) return requests;

    final empCode = widget.empCode;
    if (widget.filterType == RequestFilterType.myRequests) {
      return requests.where((r) => r.empCode == empCode).toList();
    } else if (widget.filterType == RequestFilterType.submittedRequests) {
      return requests.where((r) => r.empCode != empCode).toList();
    }
    return requests;
  }

  Map<String, List<dynamic>> _classifyRequests(List<dynamic> requests, bool isLeave) {
    final under = <dynamic>[];
    final approved = <dynamic>[];
    final rejected = <dynamic>[];
    for (var r in requests) {
      final status = isLeave ? r.reqDecideState : (r.reqDecideState ?? '');
      if (status == 3) {
        under.add(r);
      } else if (status == 1) {
        approved.add(r);
      } else if (status == 2) {
        rejected.add(r);
      }
    }
    return {'underReview': under, 'approved': approved, 'rejected': rejected};
  }
}
