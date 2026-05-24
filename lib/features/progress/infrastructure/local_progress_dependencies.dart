import 'package:shared_preferences/shared_preferences.dart';

import '../application/get_best_level_result_use_case.dart';
import '../application/get_local_progress_use_case.dart';
import '../application/is_level_unlocked_use_case.dart';
import '../application/local_progress_repository.dart';
import '../application/reset_local_progress_use_case.dart';
import '../application/save_level_completion_use_case.dart';
import 'shared_preferences_local_progress_repository.dart';

class LocalProgressDependencies {
  const LocalProgressDependencies._();

  static Future<LocalProgressRepository> createRepository() async {
    return SharedPreferencesLocalProgressRepository(
      await SharedPreferences.getInstance(),
    );
  }

  static Future<GetLocalProgressUseCase> createGetLocalProgressUseCase() async {
    return GetLocalProgressUseCase(await createRepository());
  }

  static Future<SaveLevelCompletionUseCase>
  createSaveLevelCompletionUseCase() async {
    return SaveLevelCompletionUseCase(await createRepository());
  }

  static Future<IsLevelUnlockedUseCase> createIsLevelUnlockedUseCase() async {
    return IsLevelUnlockedUseCase(await createRepository());
  }

  static Future<GetBestLevelResultUseCase>
  createGetBestLevelResultUseCase() async {
    return GetBestLevelResultUseCase(await createRepository());
  }

  static Future<ResetLocalProgressUseCase>
  createResetLocalProgressUseCase() async {
    return ResetLocalProgressUseCase(await createRepository());
  }
}
