
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static SharedPreferences? _prefs;
  static SharedPreferences get prefs => _prefs!;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic helpers
  static int getInt(String key, {int defaultValue = 0}) =>
      prefs.getInt(key) ?? defaultValue;
  static Future<bool> setInt(String key, int value) =>
      prefs.setInt(key, value);

  static double getDouble(String key, {double defaultValue = 0}) =>
      prefs.getDouble(key) ?? defaultValue;
  static Future<bool> setDouble(String key, double value) =>
      prefs.setDouble(key, value);

  static String getString(String key, {String defaultValue = ''}) =>
      prefs.getString(key) ?? defaultValue;
  static Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);

  static List<String> getStringList(String key, {List<String> defaultValue = const []}) =>
      prefs.getStringList(key) ?? defaultValue;
  static Future<bool> setStringList(String key, List<String> value) =>
      prefs.setStringList(key, value);

  // Keys
  static const waterGoalKey = 'water_goal_ml'; // int
  static const waterDateKey = 'water_date'; // yyyy-MM-dd
  static const waterTodayKey = 'water_today_ml'; // int

  static const lmpDateKey = 'lmp_date'; // последняя менструация yyyy-MM-dd

  static const weightListKey = 'weight_entries'; // список JSON-строк

  static String kickKeyForDate(String date) => 'kick_$date'; // count:int
  static String kickListKeyForDate(String date) => 'kick_list_$date'; // times:list

  static const contractionsKey = 'contractions_entries'; // список JSON-строк

  static const remindersKey = 'reminders_list'; // список JSON-строк {id,title,type,time/iso,enabled}
}
