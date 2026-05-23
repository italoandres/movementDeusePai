import 'package:equatable/equatable.dart';

/// User Profile Model
/// Represents a user profile from the profiles table
class UserProfile extends Equatable {
  final String id;
  final String nome;
  final String email;
  final bool perfilIsComplete;
  final bool senhaIsSeted;
  final int totalSeals;
  final String? currentChapter;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfilIsComplete,
    required this.senhaIsSeted,
    required this.totalSeals,
    this.currentChapter,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        perfilIsComplete,
        senhaIsSeted,
        totalSeals,
        currentChapter,
        createdAt,
        updatedAt,
      ];

  /// Create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      perfilIsComplete: json['perfil_is_complete'] as bool? ?? false,
      senhaIsSeted: json['senha_is_seted'] as bool? ?? true,
      totalSeals: json['total_seals'] as int? ?? 0,
      currentChapter: json['current_chapter'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil_is_complete': perfilIsComplete,
      'senha_is_seted': senhaIsSeted,
      'total_seals': totalSeals,
      'current_chapter': currentChapter,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method
  UserProfile copyWith({
    String? nome,
    String? email,
    bool? perfilIsComplete,
    bool? senhaIsSeted,
    int? totalSeals,
    String? currentChapter,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      perfilIsComplete: perfilIsComplete ?? this.perfilIsComplete,
      senhaIsSeted: senhaIsSeted ?? this.senhaIsSeted,
      totalSeals: totalSeals ?? this.totalSeals,
      currentChapter: currentChapter ?? this.currentChapter,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
