import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 错误边界组件
/// 捕获子组件错误，显示错误信息并提供重试按钮
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final String? defaultErrorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.defaultErrorMessage,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当子组件更新时，重置错误状态
    if (mounted) {
      setState(() {
        _hasError = false;
        _error = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      _handleError(details.exception, details.stack);
    };
  }

  void _handleError(dynamic error, StackTrace? stack) {
    setState(() {
      _hasError = true;
      _error = error;
    });
    debugPrint('ErrorBoundary caught error: $error\n$stack');
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorView();
    }
    return widget.child;
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ).animate().shake(duration: 500.ms),
            const SizedBox(height: 16),
            Text(
              '出错了',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.defaultErrorMessage ?? '未知错误',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _error = null;
                });
                widget.onRetry?.call();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 全局错误捕获
class GlobalErrorObserver extends StatefulWidget {
  final Widget child;

  const GlobalErrorObserver({super.key, required this.child});

  @override
  State<GlobalErrorObserver> createState() => _GlobalErrorObserverState();
}

class _GlobalErrorObserverState extends State<GlobalErrorObserver> {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: widget.child,
      defaultErrorMessage: '应用遇到错误，请重启应用',
    );
  }
}
