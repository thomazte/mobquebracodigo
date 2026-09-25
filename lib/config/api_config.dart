/// URL base da API Spring (mesmo backend da versão web).
///
/// Default: VPS de produção/dev compartilhada.
/// Override opcional (ex.: API local):
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8150`
class ApiConfig {
  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  /// Host público da VPS (porta 8150).
  static const String vpsUrl = 'http://137.131.137.227:8150';

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) {
      return _fromEnv.replaceAll(RegExp(r'/$'), '');
    }
    return vpsUrl;
  }
}
