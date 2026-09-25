import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'auth_api.dart';

/// Sessão global do app (usuário autenticado via API Spring).
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  final AuthApi _api = AuthApi();

  UserModel? _user;
  bool _ready = false;
  bool _busy = false;
  String? _lastError;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get ready => _ready;
  bool get busy => _busy;
  String? get lastError => _lastError;

  Future<void> bootstrap() async {
    try {
      _user = await _api.me();
    } on AuthApiException {
      _user = null;
    } catch (_) {
      _user = null;
    } finally {
      _ready = true;
      notifyListeners();
    }
  }

  Future<bool> login(String usuario, String senha) async {
    return _run(() async {
      _user = await _api.login(usuario: usuario, senha: senha);
    });
  }

  Future<bool> register({
    required String primeiroNome,
    required String ultimoNome,
    required String email,
    required String dataNascimento,
    required String usuario,
    required String senha,
  }) async {
    return _run(() async {
      _user = await _api.register(
        primeiroNome: primeiroNome,
        ultimoNome: ultimoNome,
        email: email,
        dataNascimento: dataNascimento,
        usuario: usuario,
        senha: senha,
      );
    });
  }

  Future<bool> refreshProfile() async {
    return _run(() async {
      _user = await _api.me();
    }, clearErrorOnStart: false);
  }

  Future<bool> updateProfile({
    required String nome,
    required String email,
    String? novaSenha,
  }) async {
    return _run(() async {
      _user = await _api.updateProfile(
        nome: nome,
        email: email,
        novaSenha: novaSenha,
      );
    });
  }

  Future<void> logout() async {
    _busy = true;
    notifyListeners();
    try {
      await _api.logout();
    } finally {
      _user = null;
      _busy = false;
      _lastError = null;
      notifyListeners();
    }
  }

  Future<bool> _run(
    Future<void> Function() action, {
    bool clearErrorOnStart = true,
  }) async {
    _busy = true;
    if (clearErrorOnStart) _lastError = null;
    notifyListeners();
    try {
      await action();
      _lastError = null;
      return true;
    } on AuthApiException catch (e) {
      _lastError = e.message;
      return false;
    } catch (_) {
      _lastError =
          'Não foi possível conectar ao servidor. Verifique se a API está rodando.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
