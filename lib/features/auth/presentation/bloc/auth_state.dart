import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái đang kiểm tra auth (splash screen)
class AuthInitial extends AuthState {}

/// Trạng thái đang xử lý (loading)
class AuthLoading extends AuthState {}

/// Trạng thái đã xác thực thành công
class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Trạng thái chưa đăng nhập
class AuthUnauthenticated extends AuthState {}

/// Trạng thái lỗi
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
