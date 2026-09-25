import 'dart:convert';

import '../models/user_model.dart';
import 'api_client.dart';

class AuthApiException implements Exception {
  final String message;
  final int? statusCode;

  const AuthApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<UserModel> login({
    required String usuario,
    required String senha,
  }) async {
    final response = await _client.post('/auth/login', body: {
      'usuario': usuario.trim(),
      'senha': senha,
    });
    _throwIfError(response, fallback: 'Falha no login');
    // Após login, busca perfil completo
    return me();
  }

  Future<UserModel> register({
    required String primeiroNome,
    required String ultimoNome,
    required String email,
    required String dataNascimento,
    required String usuario,
    required String senha,
  }) async {
    final response = await _client.post('/auth/register', body: {
      'primeiroNome': primeiroNome.trim(),
      'ultimoNome': ultimoNome.trim(),
      'email': email.trim(),
      'dataNascimento': dataNascimento.trim(),
      'usuario': usuario.trim(),
      'senha': senha,
    });
    _throwIfError(response, fallback: 'Falha no cadastro');
    return me();
  }

  Future<UserModel> me() async {
    final response = await _client.get('/auth/me');
    if (response.statusCode == 401) {
      throw const AuthApiException('não autenticado', statusCode: 401);
    }
    _throwIfError(response, fallback: 'Falha ao carregar perfil');
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromAuthMe(map);
  }

  Future<UserModel> updateProfile({
    required String nome,
    required String email,
    String? novaSenha,
  }) async {
    final body = <String, dynamic>{
      'nome': nome.trim(),
      'email': email.trim(),
    };
    if (novaSenha != null && novaSenha.isNotEmpty) {
      body['novaSenha'] = novaSenha;
    }
    final response = await _client.patch('/auth/me', body: body);
    _throwIfError(response, fallback: 'Falha ao salvar perfil');
    return me();
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {
      // Endpoint pode não existir em algumas builds; limpa local mesmo assim.
    }
    await _client.clearSession();
  }

  void _throwIfError(dynamic response, {required String fallback}) {
    final status = response.statusCode as int;
    if (status >= 200 && status < 300) return;

    String message = fallback;
    try {
      final map = jsonDecode(response.body as String) as Map<String, dynamic>;
      final err = map['error'] ?? map['message'] ?? map['detail'];
      if (err is String && err.isNotEmpty) {
        message = err;
      } else if (err != null) {
        message = err.toString();
      }
    } catch (_) {}

    throw AuthApiException(message, statusCode: status);
  }
}
