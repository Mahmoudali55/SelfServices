import 'package:dartz/dartz.dart';
import 'package:my_template/core/error/failures.dart';
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/features/setting/data/model/change_password_response.dart';
import 'package:my_template/features/setting/data/model/change_password_resquest.dart';
import 'package:my_template/features/setting/data/model/employee_salary_model.dart';
import 'package:my_template/features/setting/data/model/mobile_response_model.dart';
import 'package:my_template/features/setting/data/model/time_sheet_in_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_model.dart';
import 'package:my_template/features/setting/data/model/time_sheet_out_request.dart';
import 'package:my_template/features/setting/data/model/time_sheet_response.dart';

abstract interface class SettingRepo {
  Future<Either<Failure, ChangePasswordResponse>> changePassword(ChangePasswordRequest request);
  Future<Either<Failure, TimeSheetResponse>> addTimeSheetIn(TimeSheetInRequestmodel request);
  Future<Either<Failure, TimeSheetResponse>> addTimeSheetOut(TimeSheetOutRequestModel request);
  Future<Either<Failure, List<TimeSheetModel>>> getTimeSheet(String day, int empcode);
  Future<Either<Failure, MobileResponse>> employeeMobileSerialno(int empCode);

  Future<Either<Failure, EmployeeSalaryModel>> getEmployeeSalary(
    int empCode,
    int month,
    int year,
    String lang,
  );
}

class SettingRepoImp implements SettingRepo {
  final ApiConsumer apiConsumer;

  SettingRepoImp(this.apiConsumer);

  @override
  Future<Either<Failure, ChangePasswordResponse>> changePassword(ChangePasswordRequest request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.changePassword, body: request.toJson());
        return ChangePasswordResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, TimeSheetResponse>> addTimeSheetIn(TimeSheetInRequestmodel request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addpresenceFinger,
          body: request.toJson(),
        );
        return TimeSheetResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, TimeSheetResponse>> addTimeSheetOut(TimeSheetOutRequestModel request) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(EndPoints.addabsenceFinger, body: request.toJson());
        return TimeSheetResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<TimeSheetModel>>> getTimeSheet(String day, int empcode) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getAllTimesheet,
          queryParameters: {'empcode': empcode, 'day': day},
        );
        final dataString = response['Data'] as String;
        return TimeSheetModel.getAllTimesheet(dataString);
      },
    );
  }

  
  @override
  Future<Either<Failure, EmployeeSalaryModel>> getEmployeeSalary(
    int empCode,
    int month,
    int year,
    String lang,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.employeeSalary,
          queryParameters: {'EMPCODE': empCode, 'MONTH': month, 'YEAR': year, 'lang': lang},
        );

        return EmployeeSalaryModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, MobileResponse>> employeeMobileSerialno(int empCode) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getEmployeeMobileSerialno(empCode));
        return MobileResponse.fromJson(response);
      },
    );
  }
}
