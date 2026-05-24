abstract interface class RemoteLevelRepository {
  Future<Map<int, String>> getLevelIdsByNumber();
}
