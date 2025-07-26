import 'dart:convert';

class AuthResponseModel {
  final User user;
  final String token;

  AuthResponseModel({
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromJson(String str) =>
      AuthResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AuthResponseModel.fromMap(Map<String, dynamic> json) =>
      AuthResponseModel(
        user: User.fromMap(json["user"]),
        token: json["token"] ?? '',
      );

  Map<String, dynamic> toMap() => {
    "user": user.toMap(),
    "token": token,
  };
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    phone: json["phone"] ?? '',
    roles: json["roles"] ?? '',
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"]) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: json["updated_at"] != null
        ? DateTime.tryParse(json["updated_at"]) ?? DateTime.now()
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "roles": roles,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
