import 'package:dartz/dartz.dart';
import 'package:my_template/core/network/api_consumer.dart';
import 'package:my_template/core/network/end_points.dart';
import 'package:my_template/core/network/handle_dio_request.dart';
import 'package:my_template/features/auth/data/model/emp_login_model.dart';

import '../../../../core/error/failures.dart' hide handleDioRequest;
import '../model/user_model.dart';

abstract interface class AuthRepo {
  Future<Either<Failure, AuthResponseModel>> login({
    required String mobile,
    required String password,
  });
  Future<Either<Failure, EmpLoginModel>> empLogin({required int emp_id});
}

class AuthRepoImpl implements AuthRepo {
  final ApiConsumer apiConsumer;
  AuthRepoImpl(this.apiConsumer);
  @override
  Future<Either<Failure, AuthResponseModel>> login({
    required String mobile,
    required String password,
  }) {
    return handleDioRequest<AuthResponseModel>(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.login,
          body: {'Username': mobile, 'Password': password, 'grant_type': 'password'},
        );
        return AuthResponseModel.fromJson(Map<String, dynamic>.from(response));
      },
    );
  }

  @override
  Future<Either<Failure, EmpLoginModel>> empLogin({required int emp_id}) {
    return handleDioRequest<EmpLoginModel>(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.empLogin,
          queryParameters: {'emp_id': emp_id},
        );
        return EmpLoginModel.fromJson(Map<String, dynamic>.from(response));
      },
    );
  }
}
