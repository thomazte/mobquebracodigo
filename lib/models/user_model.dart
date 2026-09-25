class UserModel {
  final int? id;
  final String nome;
  final String email;
  final String primeiroNome;
  final String ultimoNome;
  final String dataNascimento;
  final String bio;
  final bool temaEscuro;
  final bool animacoesAtivas;

  const UserModel({
    this.id,
    required this.nome,
    required this.email,
    this.primeiroNome = '',
    this.ultimoNome = '',
    this.dataNascimento = '',
    this.bio = '',
    this.temaEscuro = true,
    this.animacoesAtivas = true,
  });

  factory UserModel.fromAuthMe(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      nome: '${json['username'] ?? ''}',
      email: '${json['email'] ?? ''}',
      primeiroNome: '${json['primeiroNome'] ?? ''}',
      ultimoNome: '${json['ultimoNome'] ?? ''}',
      dataNascimento: '${json['dataNascimento'] ?? ''}',
    );
  }

  factory UserModel.visitante() {
    return const UserModel(
      nome: 'Visitante',
      email: 'visitante@quebracodigo.app',
      bio: 'Aprendendo logica e programacao com jogos interativos.',
    );
  }

  String get displayName {
    final full = '$primeiroNome $ultimoNome'.trim();
    if (full.isNotEmpty) return full;
    return nome;
  }

  UserModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? primeiroNome,
    String? ultimoNome,
    String? dataNascimento,
    String? bio,
    bool? temaEscuro,
    bool? animacoesAtivas,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      primeiroNome: primeiroNome ?? this.primeiroNome,
      ultimoNome: ultimoNome ?? this.ultimoNome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      bio: bio ?? this.bio,
      temaEscuro: temaEscuro ?? this.temaEscuro,
      animacoesAtivas: animacoesAtivas ?? this.animacoesAtivas,
    );
  }
}
