import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

/// 编码工具类
class EncodingUtils {
  /// 解码API响应（支持UTF-8和GBK）
  static String decodeResponse(Uint8List bodyBytes) {
    try {
      return utf8.decode(bodyBytes);
    } catch (e) {
      try {
        return latin1.decode(bodyBytes);
      } catch (e2) {
        return '';
      }
    }
  }
}

/// API错误类型
enum ApiError {
  networkError,
  timeout,
  dataNotFound,
  parsingError,
  apiRateLimited,
}

/// API异常
class ApiException implements Exception {
  final ApiError type;
  final String message;
  final String? code;

  ApiException({required this.type, required this.message, this.code});

  @override
  String toString() => 'ApiException[$type]: $message';
}

/// 基础API服务
class ApiService {
  // 超时时间（秒）
  static const int timeoutSeconds = 30;

  // 重试次数
  static const int maxRetries = 2;

  /// GET请求（带重试机制）
  static Future<http.Response> get(String url, {int retry = 0}) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 429 && retry < maxRetries) {
        // 限流，等待后重试
        await Future.delayed(Duration(seconds: (retry + 1) * 2));
        return get(url, retry: retry + 1);
      } else {
        throw ApiException(
          type: ApiError.apiRateLimited,
          message: 'API请求失败: ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        type: ApiError.networkError,
        message: '网络错误: $e',
      );
    } on Exception catch (e) {
      if (e.toString().contains('Timeout')) {
        throw ApiException(
          type: ApiError.timeout,
          message: '请求超时',
        );
      }
      rethrow;
    }
  }
}
