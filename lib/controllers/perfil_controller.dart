import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_session.dart';

/// Controla dados e preferências do perfil do usuário.
class PerfilController extends ChangeNotifier {
  PerfilController({AuthSession? session})
      : _session = session ?? AuthSession.instance {
    _session.addListener(_onSessionChanged);
    _syncFromSession();
  }

  final AuthSession _session;
  UserModel _user = UserModel.visitante();
  bool _loading = false;
  String? _error;

  UserModel get user => _user;
  bool get loading => _loading || _session.busy;
  String? get error => _error ?? _session.lastError;

  void _onSessionChanged() {
    _syncFromSession();
    notifyListeners();
  }

  void _syncFromSession() {
    final remote = _session.user;
    if (remote != null) {
      _user = remote.copyWith(
        bio: _user.bio,
        temaEscuro: _user.temaEscuro,
        animacoesAtivas: _user.animacoesAtivas,
      );
    }
  }

  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final ok = await _session.refreshProfile();
    if (!ok) {
      _error = _session.lastError ?? 'Nao foi possivel carregar o perfil.';
    }
    _syncFromSession();
    _loading = false;
    notifyListeners();
  }

  void setTemaEscuro(bool value) {
    _user = _user.copyWith(temaEscuro: value);
    notifyListeners();
  }

  void setAnimacoesAtivas(bool value) {
    _user = _user.copyWith(animacoesAtivas: value);
    notifyListeners();
  }

  Future<bool> salvar({
    required String nome,
    required String email,
    required String bio,
    String? novaSenha,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final ok = await _session.updateProfile(
      nome: nome,
      email: email,
      novaSenha: novaSenha,
    );

    if (ok) {
      _syncFromSession();
      _user = _user.copyWith(bio: bio);
    } else {
      _error = _session.lastError ?? 'Falha ao salvar perfil.';
    }

    _loading = false;
    notifyListeners();
    return ok;
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }
}
