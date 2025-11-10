import 'package:equatable/equatable.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/notification/data/model/deciding_in_response_model.dart';
import 'package:my_template/features/notification/data/model/employee_requests_notify_model.dart';
import 'package:my_template/features/notification/data/model/req_count_response.dart';
import 'package:my_template/features/notification/data/model/request_dynamic_count_model.dart';
import 'package:my_template/features/notification/data/model/vacation_request_to_decide_model.dart';

class NotificationState extends Equatable {
  final StatusState<ReqCountResponse> reqCountStatus;
  final StatusState<List<VacationRequestToDecideModel>> vacationRequestToDecideModelList;
  final StatusState<List<VacationRequestToDecideModel>> vacationBackRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> carRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> solfaRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> resignationRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> transferRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> housingAllowanceRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> ticketRequestToDecideModel;
  final StatusState<List<VacationRequestToDecideModel>> dynamicRequestToDecideModel;
  final StatusState<List<RequestDynamicCountModel>> requestDynamicCountModel;
  final StatusState<DecidingInResponseModel> decidingInStatus;
  final StatusState<EmployeeRequestsNotify> employeeRequestsNotify;

  const NotificationState({
    this.reqCountStatus = const StatusState.initial(),
    this.vacationRequestToDecideModelList = const StatusState.initial(),
    this.vacationBackRequestToDecideModel = const StatusState.initial(),
    this.carRequestToDecideModel = const StatusState.initial(),
    this.solfaRequestToDecideModel = const StatusState.initial(),
    this.resignationRequestToDecideModel = const StatusState.initial(),
    this.transferRequestToDecideModel = const StatusState.initial(),
    this.housingAllowanceRequestToDecideModel = const StatusState.initial(),
    this.ticketRequestToDecideModel = const StatusState.initial(),
    this.decidingInStatus = const StatusState.initial(),
    this.employeeRequestsNotify = const StatusState.initial(),
    this.dynamicRequestToDecideModel = const StatusState.initial(),
    this.requestDynamicCountModel = const StatusState.initial(),
  });

  NotificationState copyWith({
    StatusState<ReqCountResponse>? reqCountStatus,
    StatusState<List<VacationRequestToDecideModel>>? vacationRequestToDecideModelList,
    StatusState<List<VacationRequestToDecideModel>>? vacationBackRequestToDecideModel,
    StatusState<List<VacationRequestToDecideModel>>? carRequestToDecideModel,
    StatusState<List<VacationRequestToDecideModel>>? solfaRequestToDecideModel,
    StatusState<List<VacationRequestToDecideModel>>? resignationRequestToDecideModel,
    StatusState<List<VacationRequestToDecideModel>>? transferRequestToDecideModel,
    StatusState<List<VacationRequestToDecideModel>>? housingAllowanceRequestToDecideModel,
    StatusState<List<VacationRequestToDecideModel>>? ticketRequestToDecideModel,
    StatusState<DecidingInResponseModel>? decidingInStatus,
    StatusState<EmployeeRequestsNotify>? employeeRequestsNotify,
    StatusState<List<VacationRequestToDecideModel>>? dynamicRequestToDecideModel,
    StatusState<List<RequestDynamicCountModel>>? requestDynamicCountModel,
  }) {
    return NotificationState(
      reqCountStatus: reqCountStatus ?? this.reqCountStatus,
      vacationRequestToDecideModelList:
          vacationRequestToDecideModelList ?? this.vacationRequestToDecideModelList,
      vacationBackRequestToDecideModel:
          vacationBackRequestToDecideModel ?? this.vacationBackRequestToDecideModel,
      carRequestToDecideModel: carRequestToDecideModel ?? this.carRequestToDecideModel,
      solfaRequestToDecideModel: solfaRequestToDecideModel ?? this.solfaRequestToDecideModel,
      resignationRequestToDecideModel:
          resignationRequestToDecideModel ?? this.resignationRequestToDecideModel,
      transferRequestToDecideModel:
          transferRequestToDecideModel ?? this.transferRequestToDecideModel,
      housingAllowanceRequestToDecideModel:
          housingAllowanceRequestToDecideModel ?? this.housingAllowanceRequestToDecideModel,
      ticketRequestToDecideModel: ticketRequestToDecideModel ?? this.ticketRequestToDecideModel,
      decidingInStatus: decidingInStatus ?? this.decidingInStatus,
      employeeRequestsNotify: employeeRequestsNotify ?? this.employeeRequestsNotify,
      dynamicRequestToDecideModel: dynamicRequestToDecideModel ?? this.dynamicRequestToDecideModel,
      requestDynamicCountModel: requestDynamicCountModel ?? this.requestDynamicCountModel,
    );
  }

  @override
  List<Object?> get props => [
    reqCountStatus,
    vacationRequestToDecideModelList,
    vacationBackRequestToDecideModel,
    carRequestToDecideModel,
    solfaRequestToDecideModel,
    resignationRequestToDecideModel,
    transferRequestToDecideModel,
    housingAllowanceRequestToDecideModel,
    ticketRequestToDecideModel,
    decidingInStatus,
    employeeRequestsNotify,
    dynamicRequestToDecideModel,
    requestDynamicCountModel,
  ];
}
