import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> setObject(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getObject(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

class StorageServiceImpl implements StorageService {
  late SharedPreferences _prefs;

  // 싱글톤 구현을 위한 생성자
  StorageServiceImpl() {
    _init();
  }

  // 초기화
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 문자열 저장
  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // 문자열 로드
  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  // 불리언 저장
  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // 불리언 로드
  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  // 정수 저장
  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  // 정수 로드
  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  // 문자열 리스트 저장
  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  // 문자열 리스트 로드
  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  // 객체 저장 (JSON 변환)
  @override
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _prefs.setString(key, jsonString);
  }

  // 객체 로드 (JSON 파싱)
  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // 특정 키 삭제
  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // 모든 데이터 삭제
  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  // 키 존재 여부 확인
  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }
}
