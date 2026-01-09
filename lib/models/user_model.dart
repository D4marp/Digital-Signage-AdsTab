class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'admin' or 'superadmin'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? '',
      role: json['role'] ?? 'admin',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'display_name': displayName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

