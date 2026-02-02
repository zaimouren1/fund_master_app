import 'package:equatable/equatable.dart';

/// 基础失败类
abstract class Failure with Equatable {
  final String message;
  final dynamic originalError;
  
  const Failure(this.message, {this.originalError});
  
  @override
  List<Object?> get props => [message, originalError];
}

/// 服务器错误
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.originalError});
}

/// 网络错误
class NetworkFailure extends Failure {
  const NetworkFailure() : super('网络连接失败，请检查网络设置');
}

/// 超时错误
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('请求超时，请稍后重试');
}

/// 缓存错误
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// 认证错误
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// 业务逻辑错误
class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}

/// 参数错误
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 错误码映射
extension FailureMapper on dynamic {
  Failure toFailure() {
    if (this is DioException) {
      final error = this as DioException;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutFailure();
        case DioExceptionType.connectionError:
          return const NetworkFailure();
        default:
          return ServerFailure(error.message ?? '服务器错误');
      }
    }
    return ServerFailure(toString());
  }
}
