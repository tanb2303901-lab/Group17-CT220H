import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện kiểm tra trạng thái auth khi khởi động
class AuthCheckRequested extends AuthEvent {}

/// Sự kiện đăng nhập
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sự kiện đăng ký tài khoản mới
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Sự kiện đăng xuất
class SignOutRequested extends AuthEvent {}
