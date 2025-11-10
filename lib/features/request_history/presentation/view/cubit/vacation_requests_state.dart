import 'package:equatable/equatable.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/features/request_history/data/model/delete_request_solfa_model.dart';
import 'package:my_template/features/request_history/data/model/delete_requests_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_cars_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_housing_allowance_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_resignation_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_ticket_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_transfer_model.dart';
import 'package:my_template/features/request_history/data/model/get_all_vacation_model.dart';
import 'package:my_template/features/request_history/data/model/get_dynamic_order_model.dart';
import 'package:my_template/features/request_history/data/model/get_requests_vacation_back.dart';
import 'package:my_template/features/request_history/data/model/get_solfa_model.dart';
import 'package:my_template/features/request_history/data/model/request_leave_updata_response_model.dart';
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';

class VacationRequestsState extends Equatable {
  final StatusState<List<VacationRequestOrdersModel>> vacationRequestsStatus;
  final StatusState<List<GetRequestVacationBackModel>> requestVacationBackStatus;
  final StatusState<DeleteRequestModel> deleteRequestStatus;
  final StatusState<DeleteRequestModel> deleteRequestBackStatus;
  final StatusState<DeleteRequestSolfaModel> deleteSolfaStatus;
  final StatusState<DeleteRequestSolfaModel> deleteHousingAllowanceStatus;
  final StatusState<DeleteRequestSolfaModel> deleteResignationStatus;
  final StatusState<DeleteRequestSolfaModel> deleteCarStatus;
  final StatusState<DeleteRequestSolfaModel> deleteTransferStatus;
  final StatusState<DeleteRequestSolfaModel> deleteTicketStatus;
  final StatusState<DeleteRequestSolfaModel> deleteDynamicOrderStatus;
  final StatusState<List<SolfaItem>> getSolfaStatus;
  final StatusState<List<VacationRequestItem>> getallVacationStatus;
  final StatusState<List<GetAllHousingAllowanceModel>> getAllHousingAllowanceStatus;
  final StatusState<List<GetAllResignationModel>> getAllResignationStatus;
  final StatusState<List<GetAllCarsModel>> getAllCarsStatus;
  final StatusState<List<GetAllTransferModel>> getAllTransferStatus;
  final StatusState<List<AllTicketModel>> getAllTicketsStatus;
  final StatusState<List<DynamicOrderModel>> dynamicOrderStatus;

  const VacationRequestsState({
    this.vacationRequestsStatus = const StatusState.initial(),

    this.deleteRequestStatus = const StatusState.initial(),
    this.deleteRequestBackStatus = const StatusState.initial(),
    this.requestVacationBackStatus = const StatusState.initial(),
    this.getSolfaStatus = const StatusState.initial(),
    this.deleteSolfaStatus = const StatusState.initial(),
    this.getallVacationStatus = const StatusState.initial(),
    this.getAllHousingAllowanceStatus = const StatusState.initial(),
    this.getAllResignationStatus = const StatusState.initial(),
    this.deleteHousingAllowanceStatus = const StatusState.initial(),
    this.deleteResignationStatus = const StatusState.initial(),
    this.getAllCarsStatus = const StatusState.initial(),
    this.deleteCarStatus = const StatusState.initial(),
    this.getAllTransferStatus = const StatusState.initial(),
    this.deleteTransferStatus = const StatusState.initial(),
    this.getAllTicketsStatus = const StatusState.initial(),
    this.deleteTicketStatus = const StatusState.initial(),
    this.dynamicOrderStatus = const StatusState.initial(),
    this.deleteDynamicOrderStatus = const StatusState.initial(),
  });

  VacationRequestsState copyWith({
    StatusState<List<VacationRequestOrdersModel>>? vacationRequestsStatus,
    StatusState<RequestLeaveUpdataResponseModel>? updataVacationStatus,
    StatusState<DeleteRequestModel>? deleteRequestStatus,
    StatusState<DeleteRequestModel>? deleteRequestBackStatus,
    StatusState<List<GetRequestVacationBackModel>>? requestVacationBackStatus,
    StatusState<List<SolfaItem>>? getSolfaStatus,
    StatusState<DeleteRequestSolfaModel>? deleteSolfaStatus,
    StatusState<DeleteRequestSolfaModel>? deleteHousingAllowanceStatus,
    StatusState<DeleteRequestSolfaModel>? deleteResignationStatus,
    StatusState<List<VacationRequestItem>>? getallVacationStatus,
    StatusState<List<GetAllHousingAllowanceModel>>? getAllHousingAllowanceStatus,
    StatusState<List<GetAllHousingAllowanceModel>>? updataVacationBackStatus,
    StatusState<List<GetAllResignationModel>>? getAllResignationStatus,
    StatusState<List<GetAllCarsModel>>? getAllCarsStatus,
    StatusState<DeleteRequestSolfaModel>? deleteCarStatus,
    StatusState<List<GetAllTransferModel>>? getAllTransferStatus,
    StatusState<DeleteRequestSolfaModel>? deleteTransferStatus,
    StatusState<DeleteRequestSolfaModel>? deleteTicketStatus,
    StatusState<List<AllTicketModel>>? getAllTicketsStatus,
    StatusState<List<DynamicOrderModel>>? dynamicOrderStatus,
    StatusState<DeleteRequestSolfaModel>? deleteDynamicOrderStatus,
  }) {
    return VacationRequestsState(
      vacationRequestsStatus: vacationRequestsStatus ?? this.vacationRequestsStatus,

      deleteRequestStatus: deleteRequestStatus ?? this.deleteRequestStatus,
      deleteRequestBackStatus: deleteRequestBackStatus ?? this.deleteRequestBackStatus,
      requestVacationBackStatus: requestVacationBackStatus ?? this.requestVacationBackStatus,
      getSolfaStatus: getSolfaStatus ?? this.getSolfaStatus,
      deleteSolfaStatus: deleteSolfaStatus ?? this.deleteSolfaStatus,
      getallVacationStatus: getallVacationStatus ?? this.getallVacationStatus,
      getAllHousingAllowanceStatus:
          getAllHousingAllowanceStatus ?? this.getAllHousingAllowanceStatus,
      getAllResignationStatus: getAllResignationStatus ?? this.getAllResignationStatus,
      deleteHousingAllowanceStatus:
          deleteHousingAllowanceStatus ?? this.deleteHousingAllowanceStatus,
      deleteResignationStatus: deleteResignationStatus ?? this.deleteResignationStatus,
      getAllCarsStatus: getAllCarsStatus ?? this.getAllCarsStatus,
      deleteCarStatus: deleteCarStatus ?? this.deleteCarStatus,
      getAllTransferStatus: getAllTransferStatus ?? this.getAllTransferStatus,
      deleteTransferStatus: deleteTransferStatus ?? this.deleteTransferStatus,
      getAllTicketsStatus: getAllTicketsStatus ?? this.getAllTicketsStatus,
      deleteTicketStatus: deleteTicketStatus ?? this.deleteTicketStatus,
      dynamicOrderStatus: dynamicOrderStatus ?? this.dynamicOrderStatus,
      deleteDynamicOrderStatus: deleteDynamicOrderStatus ?? this.deleteDynamicOrderStatus,
    );
  }

  @override
  List<Object?> get props => [
    vacationRequestsStatus,
    deleteRequestStatus,
    requestVacationBackStatus,
    deleteRequestBackStatus,
    getSolfaStatus,
    deleteSolfaStatus,
    getallVacationStatus,
    getAllHousingAllowanceStatus,
    getAllResignationStatus,
    deleteHousingAllowanceStatus,
    deleteResignationStatus,
    getAllCarsStatus,
    deleteCarStatus,
    getAllTransferStatus,
    deleteTransferStatus,
    getAllTicketsStatus,
    deleteTicketStatus,
    dynamicOrderStatus,
    deleteDynamicOrderStatus,
  ];
}
