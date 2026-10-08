/// Generic Result pattern for robust, predictable API and Data handling.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => null,
      };

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, int? statusCode) onFailure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Failure<T>(message: final m, statusCode: final code) => onFailure(m, code),
    };
  }
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final Object? originalException;

  const Failure({
    required this.message,
    this.statusCode,
    this.originalException,
  });
}
