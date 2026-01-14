import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_template/core/error/failures.dart';

Future<Either<Failure, T>> handleDioRequest<T>({required Future<T> Function() request}) async {
  try {
    final response = await request();
    return Right(response);
  } on DioException catch (e) {
    // log error type and message

    String serverMsg = 'An unknown error occurred';

    final data = e.response?.data;

    if (data != null) {
      // لو الـ response Map
      if (data is Map<String, dynamic>) {
        serverMsg =
            data['Message']?.toString() ?? data['error_description']?.toString() ?? data.toString();
      }
      // لو الـ response String
      else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            serverMsg =
                decoded['Message']?.toString() ??
                decoded['error_description']?.toString() ??
                decoded.toString();
          } else {
            serverMsg = data;
          }
        } catch (_) {
          serverMsg = data;
        }
      }
      // أي نوع آخر
      else {
        serverMsg = data.toString();
      }
    }

    // هنا بنمرر الرسالة اللي رجعت من السيرفر
    return Left(ServerFailure(serverMsg));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
