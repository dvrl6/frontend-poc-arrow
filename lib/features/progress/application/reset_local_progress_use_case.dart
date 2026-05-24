import 'local_progress_repository.dart';

class ResetLocalProgressUseCase {
  const ResetLocalProgressUseCase(this._repository);

  final LocalProgressRepository _repository;

  Future<void> call() {
    return _repository.resetProgress();
  }
}
