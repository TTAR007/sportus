// --- Either<L, R> ---

sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left(:final value) => onLeft(value),
      Right(:final value) => onRight(value),
    };
  }

  R getOrElse(R Function(L left) orElse) {
    return fold(orElse, (r) => r);
  }
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;
}

// --- AppException ---

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  factory AppException.firebase(String code, String? details) =
      FirebaseAppException;

  factory AppException.activityFull() = ActivityFullException;

  factory AppException.alreadyJoined() = AlreadyJoinedException;

  factory AppException.notFound() = NotFoundException;

  factory AppException.unauthorized() = UnauthorizedException;

  factory AppException.validation(String message) = ValidationException;

  @override
  String toString() => message;
}

final class FirebaseAppException extends AppException {
  const FirebaseAppException(this.code, this.details)
      : super('Firebase error: $code');

  final String code;
  final String? details;
}

final class ActivityFullException extends AppException {
  const ActivityFullException() : super('This activity is already full.');
}

final class AlreadyJoinedException extends AppException {
  const AlreadyJoinedException()
      : super('You have already joined this activity.');
}

final class NotFoundException extends AppException {
  const NotFoundException() : super('Activity not found.');
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('You are not authorized to perform this action.');
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}
