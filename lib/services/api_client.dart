import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Cliente HTTP que mantém cookies de sessão Spring (JSESSIONID).
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _cookieKey = 'qc_session_cookies';

  final Map<String, String> _cookies = {};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cookieKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _cookies
          ..clear()
          ..addAll(map.map((k, v) => MapEntry(k, v.toString())));
      } catch (_) {
        await prefs.remove(_cookieKey);
      }
    }
    _loaded = true;
  }

  Future<void> clearSession() async {
    _cookies.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, jsonEncode(_cookies));
  }

  void _captureCookies(http.Response response) {
    final values = <String>[];
    final multi = response.headersSplitValues['set-cookie'];
    if (multi != null && multi.isNotEmpty) {
      values.addAll(multi);
    } else {
      final single = response.headers['set-cookie'];
      if (single != null && single.isNotEmpty) values.add(single);
    }

    var changed = false;
    for (final header in values) {
      final first = header.split(';').first.trim();
      final eq = first.indexOf('=');
      if (eq <= 0) continue;
      final name = first.substring(0, eq).trim();
      final value = first.substring(eq + 1).trim();
      if (name.isEmpty) continue;
      // Cookie de remoção (Max-Age=0) vem com valor vazio
      if (value.isEmpty) {
        if (_cookies.remove(name) != null) changed = true;
      } else {
        _cookies[name] = value;
        changed = true;
      }
    }
    if (changed) {
      // ignore: discarded_futures
      _persist();
    }
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?extra,
    };
    if (_cookies.isNotEmpty) {
      headers['Cookie'] =
          _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<http.Response> get(String path) async {
    await ensureLoaded();
    final response = await http
        .get(_uri(path), headers: _headers())
        .timeout(const Duration(seconds: 20));
    _captureCookies(response);
    return response;
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    await ensureLoaded();
    final response = await http
        .post(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    _captureCookies(response);
    return response;
  }

  Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    await ensureLoaded();
    final response = await http
        .patch(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    _captureCookies(response);
    return response;
  }
}
