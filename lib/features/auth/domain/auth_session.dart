import 'package:taarak/features/auth/domain/app_user.dart';

class AuthSession {
  final AppUser user;
  final String token;

  const AuthSession({required this.user, required this.token});

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    token: json['token'] as String,
  );

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'token': token};
}
