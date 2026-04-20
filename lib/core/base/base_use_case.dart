// lib/core/base/base_use_case.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Abstract base class untuk semua UseCase di seluruh fitur KOMET.
// SWEBOK v3: Memastikan setiap use case memiliki satu tanggung jawab (SRP).

import '../error/failures.dart';

/// Tipe return umum untuk use case — eliminasi boilerplate Either.
/// Gunakan [KometResult<T>] sebagai return type use case Anda.
typedef KometResult<T> = Future<({T? data, Failure? failure})>;

/// Kembalikan sukses dengan data.
({T? data, Failure? failure}) kometSuccess<T>(T data) =>
    (data: data, failure: null);

/// Kembalikan kegagalan.
({T? data, Failure? failure}) kometFailure<T>(Failure failure) =>
    (data: null, failure: failure);

/// Base class untuk use case yang membutuhkan parameter.
///
/// ```dart
/// class LoadStoryUseCase extends UseCase<StoryProjectData, LoadStoryParams> {
///   @override
///   KometResult<StoryProjectData> call(LoadStoryParams params) async { ... }
/// }
/// ```
abstract class UseCase<Type, Params> {
  KometResult<Type> call(Params params);
}

/// Base class untuk use case yang tidak membutuhkan parameter.
///
/// ```dart
/// class GetCurrentUserUseCase extends UseCaseNoParams<UserModel> {
///   @override
///   KometResult<UserModel> call() async { ... }
/// }
/// ```
abstract class UseCaseNoParams<Type> {
  KometResult<Type> call();
}

/// Placeholder untuk use case yang memang tidak butuh parameter.
/// Gunakan sebagai [Params] untuk [UseCase] jika tidak ada input.
class NoParams {
  const NoParams();
}
