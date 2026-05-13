import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/paymob_constants.dart';
import '../errors/exceptions.dart';

class PaymobDioClient {
  PaymobDioClient._();
  static final PaymobDioClient _instance = PaymobDioClient._();
  factory PaymobDioClient() => _instance;

  late final Dio _dio;
  bool _initialised = false;

  // Call once inside your DI init() before any payment request
  void init() {
    if (_initialised) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: PaymobConstants.baseUrl,
        connectTimeout: PaymobConstants.connectTimeout,
        receiveTimeout: PaymobConstants.receiveTimeout,
        sendTimeout: PaymobConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Don't throw on 4xx we parse Paymob's error body ourselves
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Debug logging only in debug builds
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          responseBody: true,
          error: true,
          compact: false,
        ),
      );
    }
    _initialised = true;
  }

  // POST 

  Future<Response> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // GET 

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  //  Error mapping ->  existing exceptions 

  Exception _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const PaymobTimeoutException();

      case DioExceptionType.connectionError:
        return OfflineException();

      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final msg  = _extractMessage(e.response?.data)
            ?? 'Server error ($code)';
        if (code == 401 || code == 403) {
          return PaymobAuthException(msg);
        }
        return PaymobServerException(message: msg, statusCode: code);

      case DioExceptionType.cancel:
        return OfflineException(); // treat cancel same as connectivity

      default:
        return ServerException(); // fall back to your existing exception
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map) {
      return body['message']?.toString()
          ?? body['detail']?.toString()
          ?? body['error']?.toString();
    }
    return null;
  }
}
