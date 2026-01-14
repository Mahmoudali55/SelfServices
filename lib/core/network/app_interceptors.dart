import 'package:dio/dio.dart';

import '../utils/common_methods.dart';

class AppInterceptors extends Interceptor {
  AppInterceptors();
  static bool isInternet = true;
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    isInternet = true;

    options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

    // Check internet connectivity before sending request
    if (!await CommonMethods.hasConnection()) {
      isInternet = false;
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'No Internet Connection',
          type: DioExceptionType.connectionError,
        ),
      );
    }

    super.onRequest(options, handler);
  }


}
