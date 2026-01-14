import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_template/core/network/status_code.dart';

/// Base class for all failures
abstract class Failure {
  final String errMessage;
  const Failure(this.errMessage);
}

/// Server failure handler
class ServerFailure extends Failure {
  ServerFailure(super.errMessage);

  /// Map Dio exceptions to ServerFailure
  factory ServerFailure.fromDioError(DioException dioError) {
    try {
      final raw = dioError.response?.data;
      Map<String, dynamic>? map;

      if (raw != null) {
        if (raw is Map<String, dynamic>) {
          map = raw;
        } else if (raw is String) {
          try {
            map = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            map = null;
          }
        }
      }

      // Prefer server-sent messages
      final message = _extractServerMessage(map ?? raw);
      if (message != null) return ServerFailure(message);

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          return ServerFailure('Connection timeout with API server');
        case DioExceptionType.sendTimeout:
          return ServerFailure('Send timeout with API server');
        case DioExceptionType.receiveTimeout:
          return ServerFailure('Receive timeout with API server');
        case DioExceptionType.cancel:
          return ServerFailure('Request to API server was cancelled');
        case DioExceptionType.connectionError:
          return ServerFailure('No internet connection');
        case DioExceptionType.unknown:
          return ServerFailure('Unexpected error, please try again!');
        case DioExceptionType.badResponse:
          return ServerFailure.fromResponse(dioError.response?.statusCode, map ?? raw);
        default:
          return ServerFailure('Oops! There was an error, please try again.');
      }
    } catch (e) {
      return ServerFailure('An unknown error occurred');
    }
  }

  /// Handle different status codes
  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    try {
      final message = _extractServerMessage(response);
      if (message != null) return ServerFailure(message);

      switch (statusCode) {
        case StatusCode.badRequest:
        case StatusCode.unauthorized:
        case StatusCode.forbidden:
          return ServerFailure('Invalid request, please check your input');
        case StatusCode.notFound:
          return ServerFailure('Requested resource not found');
        case StatusCode.internalServerError:
          return ServerFailure('Internal server error, please try later');
        default:
          return ServerFailure('Request failed with status $statusCode');
      }
    } catch (_) {
      return ServerFailure('Failed to parse server response');
    }
  }

  /// Extract message safely
  static String? _extractServerMessage(dynamic rawData) {
    try {
      if (rawData is Map<String, dynamic>) {
        if (rawData['Message'] is String) return rawData['Message'] as String;
        if (rawData['error_description'] is String) return rawData['error_description'] as String;
      }
      if (rawData is String) {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) {
          if (decoded['Message'] is String) return decoded['Message'] as String;
          if (decoded['error_description'] is String) return decoded['error_description'] as String;
        }
      }
    } catch (_) {}
    return null;
  }
}

/// Safe Dio request handler
Future<Either<Failure, T>> handleDioRequest<T>({required Future<T> Function() request}) async {
  try {
    final response = await request();
    return Right(response);
  } on DioException catch (e) {
    final serverMsg = ServerFailure._extractServerMessage(
      e.response?.data['Message'] ?? e.response?.data,
    );
    if (serverMsg != null) {}
    return Left(ServerFailure.fromDioError(e));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
