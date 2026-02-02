import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../errors/failure.dart';
import '../logger/app_logger.dart';

/// 统一 API 客户端
/// 
/// 特性：
/// - 自动错误转换
/// - 网络状态检测
/// - 请求重试机制
/// - 日志记录
class ApiClient with AppLogger {
  final Dio _dio;
  final Connectivity _connectivity;
  final int _maxRetries;
  final Duration _timeout;
  
  ApiClient({
    required Dio dio,
    Connectivity? connectivity,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  })  : _dio = dio,
        _connectivity = connectivity ?? Connectivity(),
        _maxRetries = maxRetries,
        _timeout = timeout;

  /// GET 请求
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? params,
    Options? options,
    bool retryOnNetworkError = true,
  }) async {
    return _request<T>(
      method: 'GET',
      endpoint: endpoint,
      data: params,
      options: options,
      retryOnNetworkError: retryOnNetworkError,
    );
  }

  /// POST 请求
  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Options? options,
    bool retryOnNetworkError = true,
  }) async {
    return _request<T>(
      method: 'POST',
      endpoint: endpoint,
      data: data,
      options: options,
      retryOnNetworkError: retryOnNetworkError,
    );
  }

  Future<T> _request<T>({
    required String method,
    required String endpoint,
    dynamic data,
    Options? options,
    int retryCount = 0,
    bool retryOnNetworkError = true,
  }) async {
    // 检测网络
    if (!await _isConnected()) {
      if (retryOnNetworkError && retryCount < _maxRetries) {
        return _retry<T>(
          method: method,
          endpoint: endpoint,
          data: data,
          options: options,
          retryCount: retryCount,
        );
      }
      throw const NetworkFailure();
    }

    try {
      final response = await _dio.request(
        endpoint,
        data: data,
        options: Options(
          method: method,
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
          ..options?.merge,
        ),
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      if (retryOnNetworkError && _isNetworkError(e) && retryCount < _maxRetries) {
        return _retry<T>(
          method: method,
          endpoint: endpoint,
          data: data,
          options: options,
          retryCount: retryCount,
        );
      }
      throw e.toFailure();
    } catch (e, stack) {
      logError('Unexpected error: $e', stack);
      throw ServerFailure(e.toString(), originalError: e);
    }
  }

  Future<T> _retry<T>({
    required String method,
    required String endpoint,
    dynamic data,
    Options? options,
    required int retryCount,
  }) async {
    final delay = Duration(milliseconds: 1000 * (retryCount + 1));
    logInfo('Retrying request in ${delay.inSeconds}s (attempt ${retryCount + 1})');
    
    await Future.delayed(delay);
    
    return _request<T>(
      method: method,
      endpoint: endpoint,
      data: data,
      options: options,
      retryCount: retryCount + 1,
    );
  }

  T _handleResponse<T>(Response response) {
    if (response.statusCode == null || response.statusCode! >= 400) {
      throw ServerFailure(
        '服务器错误: ${response.statusCode}',
        originalError: response.data,
      );
    }

    // 如果返回的是 List，直接返回
    if (response.data is List) {
      return response.data as T;
    }

    // 如果返回的是 Map，提取 data 字段（如果存在）
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('data') && data['data'] != null) {
        return data['data'] as T;
      }
      return response.data as T;
    }

    return response.data as T;
  }

  Future<bool> _isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.connectionTimeout;
  }
}
