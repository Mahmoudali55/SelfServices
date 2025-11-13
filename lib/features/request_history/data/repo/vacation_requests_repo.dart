import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/core/network/handle_dio_request.dart';
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
import 'package:my_template/features/services/data/model/request_leave/vacation_requests_response_model.dart';

import '../../../../core/error/failures.dart' hide handleDioRequest;

abstract interface class VacationRequestsRepo {
  Future<Either<Failure, List<VacationRequestOrdersModel>>> vacationRequests({
    int? requestId,
    required int empcode,
  });

  Future<Either<Failure, DeleteRequestModel>> deleteVacationRequest({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, DeleteRequestModel>> deleteVacationBackRequest({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteHousingAllowanceRequest({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteResignation({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, List<GetRequestVacationBackModel>>> getRequestVacationBack({
    required int empCode,
  });
  Future<Either<Failure, List<SolfaItem>>> getSolfaRequests({required int empCode});
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteSolfaRequest({
    required int requestId,
    required int empcode,
  });

  Future<Either<Failure, List<VacationRequestItem>>> getallVacationRequests({required int empcode});
  Future<Either<Failure, List<GetAllHousingAllowanceModel>>> getAllHousingAllowance({
    required int empCode,
  });
  Future<Either<Failure, List<GetAllResignationModel>>> getAllResignation({required int empCode});
  Future<Either<Failure, List<GetAllCarsModel>>> getAllCars({required int empcode});
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteCarRequest({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, List<GetAllTransferModel>>> getAllTransfer({required int empcode});
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteTransferRequest({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, List<AllTicketModel>>> getAllTickets({required int empcode});
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteTicketRequest({
    required int requestId,
    required int empcode,
  });
  Future<Either<Failure, List<DynamicOrderModel>>> getDynamicOrder({
    required int empcode,
    required int requesttypeid,
  });
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteDynamicOrder({
    required int requestId,
    required int empcode,
    required int requesttypeid,
  });
}

class VacationRequestsRepoImpl implements VacationRequestsRepo {
  final ApiConsumer apiConsumer;
  VacationRequestsRepoImpl(this.apiConsumer);

  @override
  Future<Either<Failure, List<VacationRequestOrdersModel>>> vacationRequests({
    int? requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getAllVacationdetails(requestId: requestId, empcode: empcode),
        );

        final dataField = response['Data'];
        final String dataString = dataField != null ? dataField.toString() : '[]';
        final List dataList = jsonDecode(dataString);

        return dataList.map((x) => VacationRequestOrdersModel.fromJson(x)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestModel>> deleteVacationRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deletevacation,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, List<GetRequestVacationBackModel>>> getRequestVacationBack({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getempVacationBack(empCode));
        return GetRequestVacationBackModel.listFromResponse(response);
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestModel>> deleteVacationBackRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deletevacationBack,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, List<SolfaItem>>> getSolfaRequests({required int empCode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getSolfa(empcode: empCode));

        final model = GetSolfaModel.fromJson(response);
        return model.data;
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteSolfaRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteSolfa,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestItem>>> getallVacationRequests({
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getAllVacationes(empId: empcode));
        final dataField = response['Data'];
        final String dataString = dataField != null ? dataField.toString() : '[]';
        final List dataList = jsonDecode(dataString);
        return dataList.map((x) => VacationRequestItem.fromJson(x)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, List<GetAllHousingAllowanceModel>>> getAllHousingAllowance({
    required int empCode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getAllHousingAllowanceInProccissing(empCode),
        );

        // 🔑 فكّ الحقل Data مرتين
        final dataField = response['Data'];
        final String dataString = dataField != null ? dataField.toString() : '[]';
        final List dataList = jsonDecode(dataString);

        return dataList.map((e) => GetAllHousingAllowanceModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, List<GetAllResignationModel>>> getAllResignation({required int empCode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getAllResignationInProccissing(empCode));

        final dataField = response['Data'] ?? '[]';
        final dataString = dataField.toString();

        final List<dynamic> dataList = jsonDecode(dataString);

        return dataList.map((e) => GetAllResignationModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteHousingAllowanceRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteHousingAllowance,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteResignation({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteResignation,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, List<GetAllCarsModel>>> getAllCars({required int empcode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getAllCars(empcode));

        final dataField = response['Data'] ?? '[]';
        final dataString = dataField.toString();

        final List<dynamic> dataList = jsonDecode(dataString);

        return dataList.map((e) => GetAllCarsModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteCarRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteCar,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, List<GetAllTransferModel>>> getAllTransfer({required int empcode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getAllTransfer(empcode));

        final dataField = response['Data'] ?? '[]';
        final dataString = dataField.toString();

        final List<dynamic> dataList = jsonDecode(dataString);

        return dataList.map((e) => GetAllTransferModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteTransferRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteTransfer,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, DeleteRequestSolfaModel>> deleteTicketRequest({
    required int requestId,
    required int empcode,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteTicket,
          body: {'Requestid': requestId, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }

  @override
  Future<Either<Failure, List<AllTicketModel>>> getAllTickets({required int empcode}) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getAllTickets(empcode));

        final jsonString = json.encode(response);
        return parseTicketRequests(jsonString);
      },
    );
  }

  @override
  Future<Either<Failure, List<DynamicOrderModel>>> getDynamicOrder({
    required int empcode,
    required int requesttypeid,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getAllRequestsGeneral(empcode, requesttypeid),
        );

        final dataString = response['Data'] as String?;

        if (dataString == null || dataString.isEmpty) {
          return <DynamicOrderModel>[];
        }

        return DynamicOrderModel.fromJsonList(dataString);
      },
    );
  }

  Future<Either<Failure, DeleteRequestSolfaModel>> deleteDynamicOrder({
    required int requestId,
    required int empcode,
    required int requesttypeid,
  }) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.delete(
          EndPoints.deleteRequestGeneral,
          body: {'Requestid': requestId, 'RequestTypeId': requesttypeid, 'EmpCode': empcode},
        );
        return DeleteRequestSolfaModel.fromJson(response ?? {});
      },
    );
  }
}
