enum UserRole { student, owner }

class UserModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? university;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.university,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      university: json['university'],
      role: json['role'] == 'owner' ? UserRole.owner : UserRole.student,
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'university': university,
      'role': role == UserRole.owner ? 'owner' : 'student',
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
