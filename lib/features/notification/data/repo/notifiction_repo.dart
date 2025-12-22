import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/core/network/handle_dio_request.dart';
import 'package:my_template/features/notification/data/model/deciding_In_request_model.dart';
import 'package:my_template/features/notification/data/model/deciding_in_response_model.dart';
import 'package:my_template/features/notification/data/model/employee_requests_notify_model.dart';
import 'package:my_template/features/notification/data/model/req_count_response.dart';
import 'package:my_template/features/notification/data/model/request_dynamic_count_model.dart';
import 'package:my_template/features/notification/data/model/vacation_request_to_decide_model.dart';

import '../../../../core/error/failures.dart' hide handleDioRequest;

abstract interface class NotifictionRepo {
  Future<Either<Failure, ReqCountResponse>> getReqCounts({required int empId});
  Future<Either<Failure, List<VacationRequestToDecideModel>>> vacationRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> vacationBackRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> carRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> housingAllowanceRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> resignationRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> transferRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> solfaRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> ticketRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, List<VacationRequestToDecideModel>>> dynamicRequestToDecideModel({
    required int empId,
  });
  Future<Either<Failure, DecidingInResponseModel>> decidingIn(DecidingInRequestModel request);
  Future<Either<Failure, EmployeeRequestsNotify>> employeeRequestsNotify(int Empid);
  Future<Either<Failure, List<RequestDynamicCountModel>>> requestDynamicCountModel(
    int Empid,
    int requesttypeid,
  );
}

class NotifictionRepoImpl implements NotifictionRepo {
  final ApiConsumer apiConsumer;
  NotifictionRepoImpl(this.apiConsumer);

  @override
  Future<Either<Failure, ReqCountResponse>> getReqCounts({required int empId}) {
    return handleDioRequest<ReqCountResponse>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getRequestsCount(empId));
        return ReqCountResponse.fromJson(Map<String, dynamic>.from(response));
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> vacationRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.vacationRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> vacationBackRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.vacationBackRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> carRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.carRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> housingAllowanceRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.housingAllowanceRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> resignationRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.resignationRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> solfaRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.solfaRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> transferRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.transferRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> ticketRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.ticketRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<VacationRequestToDecideModel>>> dynamicRequestToDecideModel({
    required int empId,
  }) {
    return handleDioRequest<List<VacationRequestToDecideModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.dynamicRequestToDecide(empId));

        final String dataString = response['Data'] ?? '[]';

        final List<dynamic> dataList = List<Map<String, dynamic>>.from(
          (jsonDecode(dataString) as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
        );

        return _groupRequests(
          dataList.map((e) => VacationRequestToDecideModel.fromJson(e)).toList(),
        );
      },
    );
  }

  @override
  Future<Either<Failure, DecidingInResponseModel>> decidingIn(DecidingInRequestModel request) {
    return handleDioRequest<DecidingInResponseModel>(
      request: () async {
        final response = await apiConsumer.post(EndPoints.decidingIn, body: request.toJson());
        return DecidingInResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, EmployeeRequestsNotify>> employeeRequestsNotify(int Empid) {
    return handleDioRequest<EmployeeRequestsNotify>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.employeeRequestsNotify(Empid));
        return EmployeeRequestsNotify.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<RequestDynamicCountModel>>> requestDynamicCountModel(
    int empId,
    int requesttypeid,
  ) {
    return handleDioRequest<List<RequestDynamicCountModel>>(
      request: () async {
        final response = await apiConsumer.get(EndPoints.requestDynamicCount(empId, requesttypeid));
        final rawData = response['Data'] as String? ?? '[]';
        final decoded = jsonDecode(rawData) as List<dynamic>;
        final list = decoded
            .map((e) => RequestDynamicCountModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      },
    );
  }

  List<VacationRequestToDecideModel> _groupRequests(List<VacationRequestToDecideModel> list) {
    final Map<int, VacationRequestToDecideModel> grouped = {};

    for (var item in list) {
      final id = item.requestId;
      if (id == null) continue;

      if (grouped.containsKey(id)) {
        final existing = grouped[id]!;
        final newAttachments = List<AttachmentModel>.from(existing.attachments);
        if (item.attatchmentName != null) {
          newAttachments.add(
            AttachmentModel(
              attachmentName: item.attatchmentName,
              attachmentFileName: item.AttchmentFileName,
            ),
          );
        }
        grouped[id] = existing.copyWith(attachments: newAttachments);
      } else {
        final attachments = <AttachmentModel>[];
        if (item.attatchmentName != null) {
          attachments.add(
            AttachmentModel(
              attachmentName: item.attatchmentName,
              attachmentFileName: item.AttchmentFileName,
            ),
          );
        }
        grouped[id] = item.copyWith(attachments: attachments);
      }
    }

    return grouped.values.toList();
  }
}
