/// Architecture preparation for local-first database (SQLite / Drift)
abstract class AppDatabase {
  Future<void> initialize();
  Future<void> clearAllData();
}

/// Stub implementation of AppDatabase for Phase 1
class LocalDatabaseStub implements AppDatabase {
  @override
  Future<void> initialize() async {
    // Database initialization will be implemented in database phase (Drift/SQLite)
  }

  @override
  Future<void> clearAllData() async {
    // Clear data stub
  }
}
