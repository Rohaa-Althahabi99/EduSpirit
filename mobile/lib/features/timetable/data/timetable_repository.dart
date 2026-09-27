import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/network/api_client.dart';
import 'timetable_entry_model.dart';

/// نمط "Cache-first on failure": نحاول الشبكة أولًا دائمًا (بيانات حديثة)، ولو فشل
/// الاتصال (لا إنترنت) نرجع لآخر نسخة محفوظة محليًا بدل شاشة خطأ فارغة — هذا هو
/// جوهر Offline Mode المطلوب في التصميم الأصلي، ونفس النمط يُطبَّق على أي مستودع آخر.
class TimetableRepository {
  final ApiClient _apiClient;
  static const _cacheBoxName = 'cache_timetable_weekly';

  TimetableRepository(this._apiClient);

  Future<List<TimetableEntryModel>> getToday() async {
    final response = await _apiClient.dio.get('/timetable/today');
    return (response.data as List)
        .map((e) => TimetableEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TimetableEntryModel>> getWeekly() async {
    try {
      final response = await _apiClient.dio.get('/timetable/weekly');
      final rawList = response.data as List;

      // نخزّن الاستجابة الخام (JSON) محليًا بعد كل نجاح — لتكون جاهزة لو انقطع الإنترنت لاحقًا.
      final box = await Hive.openBox(_cacheBoxName);
      await box.put('data', jsonEncode(rawList));

      return rawList.map((e) => TimetableEntryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      final cached = await _loadFromCache();
      if (cached != null) return cached;
      rethrow; // ما فيه نسخة محفوظة أصلًا ولا اتصال — نرفع الخطأ عاديًا للواجهة
    }
  }

  Future<List<TimetableEntryModel>?> _loadFromCache() async {
    final box = await Hive.openBox(_cacheBoxName);
    final raw = box.get('data') as String?;
    if (raw == null) return null;
    final rawList = jsonDecode(raw) as List;
    return rawList.map((e) => TimetableEntryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> delete(String id) => _apiClient.dio.delete('/timetable/$id');
}
