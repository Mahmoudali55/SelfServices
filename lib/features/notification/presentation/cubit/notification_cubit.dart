import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:my_template/core/utils/app_local_kay.dart';
import 'package:my_template/core/utils/common_methods.dart';
import 'package:my_template/features/notification/data/model/deciding_In_request_model.dart';
import 'package:my_template/features/notification/data/model/req_count_response.dart';
import 'package:my_template/features/notification/data/repo/notifiction_repo.dart';
import 'package:my_template/features/notification/presentation/cubit/notification_state.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/status.state.dart';

class NotifictionCubit extends Cubit<NotificationState> {
  final NotifictionRepo repo;

  NotifictionCubit(this.repo) : super(const NotificationState());

  Future<void> getReqCount({required int empId}) async {
    emit(state.copyWith(reqCountStatus: const StatusState.loading()));

    try {
      final result = await repo.getReqCounts(empId: empId);

      result.fold(
        (failure) => emit(
          state.copyWith(reqCountStatus: StatusState.failure(_mapFailureToMessage(failure))),
        ),
        (response) => emit(state.copyWith(reqCountStatus: StatusState.success(response))),
      );
    } catch (e) {
      emit(state.copyWith(reqCountStatus: StatusState.failure(e.toString())));
    }
  }

  Future<void> getVacationRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(vacationRequestToDecideModelList: const StatusState.loading()));

    try {
      final result = await repo.vacationRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              vacationRequestToDecideModelList: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(vacationRequestToDecideModelList: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(vacationRequestToDecideModelList: StatusState.failure(e.toString())));
    }
  }

  Future<void> getVacationBackRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(vacationBackRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.vacationBackRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              vacationBackRequestToDecideModel: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(vacationBackRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(vacationBackRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> getCarRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(carRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.carRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              carRequestToDecideModel: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(carRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(carRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> getSolfaRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(solfaRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.solfaRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              solfaRequestToDecideModel: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(solfaRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(solfaRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> getResignationRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(resignationRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.resignationRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              resignationRequestToDecideModel: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(resignationRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(resignationRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> getTransferRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(transferRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.transferRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              transferRequestToDecideModel: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(transferRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(transferRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> getHousingAllowanceRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(housingAllowanceRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.housingAllowanceRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              housingAllowanceRequestToDecideModel: StatusState.failure(
                _mapFailureToMessage(failure),
              ),
            ),
          );
        },
        (response) {
          emit(state.copyWith(housingAllowanceRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(housingAllowanceRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> getTicketRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(ticketRequestToDecideModel: const StatusState.loading()));

    try {
      final result = await repo.ticketRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              ticketRequestToDecideModel: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(ticketRequestToDecideModel: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(ticketRequestToDecideModel: StatusState.failure(e.toString())));
    }
  }

  Future<void> dynamicRequestToDecideModel({required int empId}) async {
    emit(state.copyWith(dynamicRequestToDecideModel5007: const StatusState.loading()));
    emit(state.copyWith(dynamicRequestToDecideModel5008: const StatusState.loading()));

    try {
      final result = await repo.dynamicRequestToDecideModel(empId: empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              dynamicRequestToDecideModel5007: StatusState.failure(_mapFailureToMessage(failure)),
              dynamicRequestToDecideModel5008: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          final list5007 = response.where((e) => e.requestType == 5007).toList();
          final list5008 = response.where((e) => e.requestType == 5008).toList();

          emit(
            state.copyWith(
              dynamicRequestToDecideModel5007: StatusState.success(list5007),
              dynamicRequestToDecideModel5008: StatusState.success(list5008),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          dynamicRequestToDecideModel5007: StatusState.failure(e.toString()),
          dynamicRequestToDecideModel5008: StatusState.failure(e.toString()),
        ),
      );
    }
  }

  Future<void> getDynamicRequestToDecideModel({
    required int empId,
    required int requestType,
  }) async {
    if (requestType == 5007) {
      emit(state.copyWith(requestDynamic5007: const StatusState.loading()));
    } else if (requestType == 5008) {
      emit(state.copyWith(requestDynamic5008: const StatusState.loading()));
    }

    try {
      final result = await repo.requestDynamicCountModel(empId, requestType);
      result.fold(
        (failure) {
          if (requestType == 5007) {
            emit(
              state.copyWith(
                requestDynamic5007: StatusState.failure(_mapFailureToMessage(failure)),
              ),
            );
          } else {
            emit(
              state.copyWith(
                requestDynamic5008: StatusState.failure(_mapFailureToMessage(failure)),
              ),
            );
          }
        },
        (response) {
          if (requestType == 5007) {
            emit(state.copyWith(requestDynamic5007: StatusState.success(response)));
          } else {
            emit(state.copyWith(requestDynamic5008: StatusState.success(response)));
          }
        },
      );
    } catch (e) {
      if (requestType == 5007) {
        emit(state.copyWith(requestDynamic5007: StatusState.failure(e.toString())));
      } else {
        emit(state.copyWith(requestDynamic5008: StatusState.failure(e.toString())));
      }
    }
  }

  Future<void> decidingIn({
    required DecidingInRequestModel request,
    required String message,
    required RequestType requestType,
  }) async {
    emit(state.copyWith(decidingInStatus: const StatusState.loading()));

    try {
      final result = await repo.decidingIn(request);

      result.fold(
        (failure) {
          emit(
            state.copyWith(decidingInStatus: StatusState.failure(_mapFailureToMessage(failure))),
          );
        },
        (response) {
          emit(state.copyWith(decidingInStatus: StatusState.success(response)));
          CommonMethods.showToast(message: message, type: ToastType.success);
          fetchRequests(requestType);
        },
      );
    } catch (e) {
      emit(state.copyWith(decidingInStatus: StatusState.failure(e.toString())));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.errMessage;
  }

  void fetchRequests(RequestType type) {
    final empCode = HiveMethods.getEmpCode() ?? '0';
    final empId = int.tryParse(empCode) ?? 0;

    switch (type) {
      case RequestType.vacation:
        getVacationRequestToDecideModel(empId: empId);
        break;
      case RequestType.loan:
        getSolfaRequestToDecideModel(empId: empId);
        break;
      case RequestType.resignation:
        getResignationRequestToDecideModel(empId: empId);
        break;
      case RequestType.travelPermit:
        // cubit.getTravelPermitRequests(empId: empId);
        break;
      case RequestType.travelTicket:
        getTicketRequestToDecideModel(empId: empId);
        break;
      case RequestType.housingAllowance:
        getHousingAllowanceRequestToDecideModel(empId: empId);
        break;
      case RequestType.introLetter:
        // cubit.getIntroLetterRequests(empId: empId);
        break;
      case RequestType.trainingCourse:
        // cubit.getTrainingCourseRequests(empId: empId);
        break;
      case RequestType.carRequest:
        getCarRequestToDecideModel(empId: empId);
        break;
      case RequestType.hiringRequest:
        // cubit.getHiringRequestRequests(empId: empId);
        break;
      case RequestType.performanceEval:
        // cubit.getPerformanceEvalRequests(empId: empId);
        break;
      case RequestType.warningRequest:
        // cubit.getWarningRequestRequests(empId: empId);
        break;
      case RequestType.returnFromLeave:
        getVacationBackRequestToDecideModel(empId: empId);
        break;
      case RequestType.transferRequest:
        getTransferRequestToDecideModel(empId: empId);
      case RequestType.dynamicRequest:
        dynamicRequestToDecideModel(empId: empId);
      case RequestType.changeIdPhoneRequest:
        dynamicRequestToDecideModel(empId: empId);
        break;
    }
  }

  Future<void> decidingAll({
    required List<dynamic> requests,
    required RequestType requestType,
    required bool isAccept,
    required String notes,
  }) async {
    emit(state.copyWith(decidingInStatus: const StatusState.loading()));

    final empId = int.tryParse(HiveMethods.getEmpCode() ?? '0') ?? 0;
    final List<String> errors = [];

    try {
      for (final req in requests) {
        final result = await repo.decidingIn(
          DecidingInRequestModel(
            requestType: req.requestType ?? 0,
            requestId: req.requestId ?? 0,
            actionType: isAccept ? 1 : 2,
            actionMakerEmpID: empId,
            strNotes: notes,
            isLastDecidingEmp: req.isLastDecidingEmp,
            haveSpecialDecide: 0,
            specialDecideEmpId: null,
          ),
        );

        result.fold((failure) => errors.add(failure.errMessage), (_) {});
      }

      if (errors.isEmpty) {
        CommonMethods.showToast(
          message: isAccept
              ? AppLocalKay.allRequestsAccepted.tr()
              : AppLocalKay.allRequestsRejected.tr(),
          type: ToastType.success,
        );
      } else {
        CommonMethods.showToast(message: errors.join('\n'), type: ToastType.error);
      }

      fetchRequests(requestType);

      emit(state.copyWith(decidingInStatus: const StatusState.initial()));
    } catch (e) {
      emit(state.copyWith(decidingInStatus: StatusState.failure(e.toString())));
    }
  }

  Future<void> getemployeeRequestsNotify({required int empId}) async {
    emit(state.copyWith(employeeRequestsNotify: const StatusState.loading()));

    try {
      final result = await repo.employeeRequestsNotify(empId);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              employeeRequestsNotify: StatusState.failure(_mapFailureToMessage(failure)),
            ),
          );
        },
        (response) {
          emit(state.copyWith(employeeRequestsNotify: StatusState.success(response)));
        },
      );
    } catch (e) {
      emit(state.copyWith(employeeRequestsNotify: StatusState.failure(e.toString())));
    }
  }
}
