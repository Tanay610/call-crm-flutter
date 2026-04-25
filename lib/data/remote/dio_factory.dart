import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioFactory {
  DioFactory(this._logger);

  final Logger _logger;

  Dio create({required String baseUrl}) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('HTTP ${options.method} ${options.baseUrl}${options.path}');
          handler.next(options);
        },
        onError: (error, handler) {
          _logger.e('HTTP error: ${error.message}');
          handler.next(error);
        },
      ),
    );
    return dio;
  }
}

