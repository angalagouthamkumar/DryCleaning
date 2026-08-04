import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentNotifier extends StateNotifier<Map<String, String>> {
  ContentNotifier() : super({}) {
    loadCachedContent();
  }

  static const String _cacheKey = 'customer_app_content_cache';

  Future<void> loadCachedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final Map<String, String> map = {};
        decoded.forEach((k, v) {
          map[k] = v.toString();
        });
        state = map;
        ContentService._instance.updateMap(map);
        debugPrint('ContentNotifier restored ${map.length} keys from SharedPreferences cache');
      }
    } catch (e) {
      debugPrint('Error loading cached content: $e');
    }
  }

  Future<void> fetchLiveContent(Dio dio) async {
    try {
      final response = await dio.get('/content');
      if (response.data != null && response.data['success'] == true) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data['data'] ?? {});
        final Map<String, String> newMap = {};
        data.forEach((key, value) {
          newMap[key] = value.toString();
        });

        state = newMap;
        ContentService._instance.updateMap(newMap);

        // Cache to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(newMap));
        debugPrint('ContentNotifier updated and cached ${newMap.length} content keys from backend');
      }
    } catch (e) {
      debugPrint('ContentNotifier fetch error: $e');
    }
  }
}

final contentStateProvider = StateNotifierProvider<ContentNotifier, Map<String, String>>((ref) {
  return ContentNotifier();
});

class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  final Map<String, String> _contentMap = {};
  bool _isFetched = false;

  void updateMap(Map<String, String> newMap) {
    _contentMap.clear();
    _contentMap.addAll(newMap);
    _isFetched = true;
  }

  /// Initialize and fetch live content dictionary from backend API
  Future<void> fetchContent(Dio dio) async {
    try {
      final response = await dio.get('/content');
      if (response.data != null && response.data['success'] == true) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data['data'] ?? {});
        final Map<String, String> newMap = {};
        data.forEach((key, value) {
          newMap[key] = value.toString();
        });
        updateMap(newMap);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ContentNotifier._cacheKey, jsonEncode(newMap));
        debugPrint('ContentService loaded ${newMap.length} content keys from backend');
      }
    } catch (e) {
      debugPrint('ContentService fetch error: $e');
    }
  }

  /// Get text for content key, falling back to defaultText if not found
  static String t(String key, String defaultText) {
    final Map<String, String> map = _instance._contentMap;
    if (map.containsKey(key) && map[key]!.isNotEmpty) {
      return map[key]!;
    }
    return defaultText;
  }

  bool get isFetched => _isFetched;
  Map<String, String> get contentMap => Map.unmodifiable(_contentMap);
}
