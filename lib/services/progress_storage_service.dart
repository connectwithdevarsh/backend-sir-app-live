import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ProgressStorageService provides persistent local storage for practical & unit completion tracking.
/// Uses SharedPreferences with safety fallbacks so it never blocks web startup.
class ProgressStorageService {
  static const String _keyPrefix = 'aipelab_practical_';
  static SharedPreferences? _prefs;

  /// Global notifier to trigger UI updates immediately when progress changes
  static final ValueNotifier<int> progressChangeNotifier = ValueNotifier<int>(0);

  /// Initializes SharedPreferences instance at app startup safely.
  static Future<void> initialize() async {
    if (_prefs != null) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('ProgressStorageService initialize notice: $e');
    }
  }

  static Future<SharedPreferences?> _getPrefs() async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs;
  }

  static String _getCompletedKey(int practicalId) => '$_keyPrefix${practicalId}_completed';
  static String _getTimestampKey(int practicalId) => '$_keyPrefix${practicalId}_completed_at';
  static String _getUnitCompletedKey(int unitId) => '$_keyPrefix${unitId}_unit_completed';

  // --- PRACTICAL COMPLETION METHODS ---

  /// Returns whether a specific practical is completed.
  static Future<bool> isPracticalCompleted(int practicalId) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.getBool(_getCompletedKey(practicalId)) ?? false;
  }

  /// Synchronously checks practical completion state.
  static bool isPracticalCompletedSync(int practicalId) {
    if (_prefs == null) return false;
    return _prefs!.getBool(_getCompletedKey(practicalId)) ?? false;
  }

  /// Gets the saved ISO 8601 completion timestamp for a practical.
  static Future<DateTime?> getCompletionTimestamp(int practicalId) async {
    final prefs = await _getPrefs();
    if (prefs == null) return null;
    final raw = prefs.getString(_getTimestampKey(practicalId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously gets completion timestamp.
  static DateTime? getCompletionTimestampSync(int practicalId) {
    if (_prefs == null) return null;
    final raw = _prefs!.getString(_getTimestampKey(practicalId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Marks a practical as completed persistently and saves device timestamp.
  static Future<void> markPracticalCompleted(int practicalId) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      final nowIso = DateTime.now().toIso8601String();
      await prefs.setBool(_getCompletedKey(practicalId), true);
      await prefs.setString(_getTimestampKey(practicalId), nowIso);
    }
    progressChangeNotifier.value++;
  }

  /// Marks a practical as incomplete persistently.
  static Future<void> markPracticalIncomplete(int practicalId) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.setBool(_getCompletedKey(practicalId), false);
      await prefs.remove(_getTimestampKey(practicalId));
    }
    progressChangeNotifier.value++;
  }

  /// Toggles the completion state for a practical.
  static Future<void> togglePracticalCompletion(int practicalId) async {
    final current = await isPracticalCompleted(practicalId);
    if (current) {
      await markPracticalIncomplete(practicalId);
    } else {
      await markPracticalCompleted(practicalId);
    }
  }

  /// Gets list of all completed practical IDs (1 to 12).
  static Future<List<int>> getCompletedPracticals() async {
    final prefs = await _getPrefs();
    if (prefs == null) return [];
    final List<int> completedList = [];
    for (int i = 1; i <= 12; i++) {
      if (prefs.getBool(_getCompletedKey(i)) == true) {
        completedList.add(i);
      }
    }
    return completedList;
  }

  /// Synchronously returns total completed practicals count.
  static int getCompletedCountSync() {
    if (_prefs == null) return 0;
    int count = 0;
    for (int i = 1; i <= 12; i++) {
      if (_prefs!.getBool(_getCompletedKey(i)) == true) {
        count++;
      }
    }
    return count;
  }

  /// Calculates overall completion percentage (0.0 to 100.0).
  static double getProgressPercentageSync() {
    final count = getCompletedCountSync();
    return (count / 12.0) * 100.0;
  }

  // --- COURSE SYLLABUS UNIT COMPLETION METHODS ---

  /// Synchronously checks if GTU Syllabus Unit (1 to 5) is marked completed.
  static bool isUnitCompletedSync(int unitId) {
    if (_prefs == null) return false;
    return _prefs!.getBool(_getUnitCompletedKey(unitId)) ?? false;
  }

  /// Asynchronously checks if GTU Syllabus Unit (1 to 5) is marked completed.
  static Future<bool> isUnitCompleted(int unitId) async {
    final prefs = await _getPrefs();
    if (prefs == null) return false;
    return prefs.getBool(_getUnitCompletedKey(unitId)) ?? false;
  }

  /// Marks a GTU Syllabus Unit as completed persistently.
  static Future<void> markUnitCompleted(int unitId) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.setBool(_getUnitCompletedKey(unitId), true);
    }
    progressChangeNotifier.value++;
  }

  /// Marks a GTU Syllabus Unit as incomplete persistently.
  static Future<void> markUnitIncomplete(int unitId) async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.setBool(_getUnitCompletedKey(unitId), false);
    }
    progressChangeNotifier.value++;
  }

  /// Toggles completion state for GTU Syllabus Unit.
  static Future<void> toggleUnitCompletion(int unitId) async {
    final current = await isUnitCompleted(unitId);
    if (current) {
      await markUnitIncomplete(unitId);
    } else {
      await markUnitCompleted(unitId);
    }
  }

  /// Synchronously returns total completed units count (0 to 5).
  static int getCompletedUnitsCountSync() {
    if (_prefs == null) return 0;
    int count = 0;
    for (int i = 1; i <= 5; i++) {
      if (_prefs!.getBool(_getUnitCompletedKey(i)) == true) {
        count++;
      }
    }
    return count;
  }

  /// Clears all saved practical & unit progress.
  static Future<void> clearAllProgress() async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      for (int i = 1; i <= 12; i++) {
        await prefs.setBool(_getCompletedKey(i), false);
        await prefs.remove(_getTimestampKey(i));
      }
      for (int i = 1; i <= 5; i++) {
        await prefs.setBool(_getUnitCompletedKey(i), false);
      }
    }
    progressChangeNotifier.value++;
  }
}
