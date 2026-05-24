import '../domain/local_progress.dart';
import 'local_progress_repository.dart';

class GetLocalProgressUseCase {
  const GetLocalProgressUseCase(this._repository);

  final LocalProgressRepository _repository;

  Future<LocalProgress> call() {
    return _repository.getProgress();
  }
}
