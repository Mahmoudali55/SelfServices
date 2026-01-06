import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/network/status.state.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/request_history/data/repo/vacation_requests_repo.dart';

import 'vacation_requests_state.dart';

class VacationRequestsCubit extends Cubit<VacationRequestsState> {
  final VacationRequestsRepo vacationRequestsRepo;

  VacationRequestsCubit(this.vacationRequestsRepo) : super(const VacationRequestsState());

  Future<void> getVacationRequests({required int empcode, int? requestId}) async {
    emit(state.copyWith(vacationRequestsStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.vacationRequests(
      empcode: empcode,
      requestId: requestId,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(vacationRequestsStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(vacationRequestsStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteRequest({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteRequestStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteVacationRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteRequestStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteRequestStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getVacationRequests(empcode: empcodeadmin);
      },
    );
  }

  Future<void> getRequestVacationBack({required int empCode}) async {
    emit(state.copyWith(requestVacationBackStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getRequestVacationBack(empCode: empCode);

    result.fold(
      (error) =>
          emit(state.copyWith(requestVacationBackStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(requestVacationBackStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteRequestBack({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteRequestBackStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteVacationBackRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteRequestBackStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteRequestBackStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getRequestVacationBack(empCode: empcodeadmin);
      },
    );
  }

  Future<void> getSolfaRequests({required int empCode}) async {
    emit(state.copyWith(getSolfaStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getSolfaRequests(empCode: empCode);

    result.fold(
      (error) => emit(state.copyWith(getSolfaStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getSolfaStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteRequestSolfa({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteSolfaStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteSolfaRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteSolfaStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteSolfaStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getSolfaRequests(empCode: empcodeadmin);
      },
    );
  }

  Future<void> getAllVacation({required int empCode}) async {
    emit(state.copyWith(getallVacationStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getallVacationRequests(empcode: empCode);

    result.fold(
      (error) => emit(state.copyWith(getallVacationStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getallVacationStatus: StatusState.success(success))),
    );
  }

  Future<void> getAllHousingAllowance({required int empCode}) async {
    emit(state.copyWith(getAllHousingAllowanceStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getAllHousingAllowance(empCode: empCode);

    result.fold(
      (error) =>
          emit(state.copyWith(getAllHousingAllowanceStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getAllHousingAllowanceStatus: StatusState.success(success))),
    );
  }

  Future<void> getAllResignationInProccissing({required int empCode}) async {
    emit(state.copyWith(getAllResignationStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getAllResignation(empCode: empCode);

    result.fold(
      (error) =>
          emit(state.copyWith(getAllResignationStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getAllResignationStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteHousingAllowance({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteHousingAllowanceStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteHousingAllowanceRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteHousingAllowanceStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteHousingAllowanceStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getAllHousingAllowance(empCode: empcodeadmin);
      },
    );
  }

  Future<void> deleteResignation({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteResignationStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteResignation(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteResignationStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteResignationStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getAllResignationInProccissing(empCode: empcodeadmin);
      },
    );
  }

  Future<void> getAllCars({required int empCode}) async {
    emit(state.copyWith(getAllCarsStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getAllCars(empcode: empCode);

    result.fold(
      (error) => emit(state.copyWith(getAllCarsStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getAllCarsStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteCar({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteCarStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteCarRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteCarStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteCarStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getAllCars(empCode: empcodeadmin);
      },
    );
  }

  Future<void> getAllTransfer({required int empCode}) async {
    emit(state.copyWith(getAllTransferStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.getAllTransfer(empcode: empCode);

    result.fold(
      (error) => emit(state.copyWith(getAllTransferStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getAllTransferStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteTransfer({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteTransferStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteTransferRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteTransferStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteTransferStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getAllTransfer(empCode: empcodeadmin);
      },
    );
  }

  Future<void> getTicketRequests({required int empCode}) async {
    emit(state.copyWith(getAllTicketsStatus: const StatusState.loading()));
    final result = await vacationRequestsRepo.getAllTickets(empcode: empCode);
    result.fold(
      (error) => emit(state.copyWith(getAllTicketsStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(getAllTicketsStatus: StatusState.success(success))),
    );
  }

  Future<void> getAllRequestsGeneral({required int empCode, required int requestId}) async {
    emit(state.copyWith(dynamicOrderStatus: const StatusState.loading()));
    final result = await vacationRequestsRepo.getDynamicOrder(
      empcode: empCode,
      requesttypeid: requestId,
    );
    result.fold(
      (error) => emit(state.copyWith(dynamicOrderStatus: StatusState.failure(error.errMessage))),
      (success) => emit(state.copyWith(dynamicOrderStatus: StatusState.success(success))),
    );
  }

  Future<void> deleteTicket({
    required int requestId,
    required int empcode,
    required BuildContext context,
    required int empcodeadmin,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteTicketStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteTicketRequest(
      requestId: requestId,
      empcode: empcode,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteTicketStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteTicketStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getTicketRequests(empCode: empcodeadmin);
      },
    );
  }

  Future<void> deleteRequestGeneral({
    required int requestId,
    required BuildContext context,
    required int empcodeadmin,
    required int empcode,
    required int requesttypeid,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(deleteDynamicOrderStatus: const StatusState.loading()));

    final result = await vacationRequestsRepo.deleteDynamicOrder(
      requestId: requestId,
      empcode: empcode,
      requesttypeid: requesttypeid,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        emit(state.copyWith(deleteDynamicOrderStatus: StatusState.failure(error.errMessage)));
      },
      (success) {
        emit(state.copyWith(deleteDynamicOrderStatus: StatusState.success(success)));
        CommonMethods.showToast(
          message: AppLocalKay.deleted_successfully.tr(),
          type: ToastType.success,
        );
        getAllRequestsGeneral(empCode: empcodeadmin, requestId: requesttypeid);
      },
    );
  }
}
