class RepositoryState<T> {
  const RepositoryState({
    required this.data,
    this.isLoading = false,
    this.isFromCache = false,
    this.errorMessage,
  });

  final T data;
  final bool isLoading;
  final bool isFromCache;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  RepositoryState<T> copyWith({
    T? data,
    bool? isLoading,
    bool? isFromCache,
    String? errorMessage,
  }) {
    return RepositoryState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: errorMessage,
    );
  }
}
