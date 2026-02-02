import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// 加载覆盖层
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 骨架屏加载组件
class SkeletonLoader extends StatelessWidget {
  final Widget child;

  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}

/// 骨架屏列表
class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  const SkeletonListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonLoader(
        child: itemBuilder(index),
      ),
    );
  }
}

/// 骨架屏卡片
class SkeletonCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 状态视图组件
class StateView extends StatelessWidget {
  final ViewState state;
  final Widget Function(BuildContext) successBuilder;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final String? emptyMessage;
  final String? errorMessage;

  const StateView({
    super.key,
    required this.state,
    required this.successBuilder,
    this.onRetry,
    this.loadingMessage,
    this.emptyMessage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return _buildLoading(context);
      case ViewState.success:
        return successBuilder(context);
      case ViewState.empty:
        return _buildEmpty(context);
      case ViewState.error:
        return _buildError(context);
    }
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (loadingMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? '暂无数据',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? '加载失败',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 视图状态枚举
enum ViewState {
  loading,
  success,
  empty,
  error,
}

/// 状态控制器
class StateController<T> with ChangeNotifier {
  ViewState _state = ViewState.loading;
  T? _data;
  dynamic _error;
  String? _message;

  ViewState get state => _state;
  T? get data => _data;
  dynamic get error => _error;
  String? get message => _message;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isEmpty => _state == ViewState.empty;
  bool get isError => _state == ViewState.error;

  void setLoading({String? message}) {
    _state = ViewState.loading;
    _message = message;
    notifyListeners();
  }

  void setSuccess(T data, {String? message}) {
    _data = data;
    _state = data == null || (data is List && data.isEmpty) 
        ? ViewState.empty 
        : ViewState.success;
    _message = message;
    _error = null;
    notifyListeners();
  }

  void setError(dynamic error, {String? message}) {
    _state = ViewState.error;
    _error = error;
    _message = message ?? error?.toString() ?? '加载失败';
    notifyListeners();
  }

  void reset() {
    _state = ViewState.loading;
    _data = null;
    _error = null;
    _message = null;
    notifyListeners();
  }
}
