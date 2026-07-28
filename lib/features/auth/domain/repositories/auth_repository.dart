import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Đăng nhập bằng email và mật khẩu
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Đăng xuất
  Future<void> signOut();

  /// Lấy user hiện tại (null nếu chưa đăng nhập)
  AppUser? getCurrentUser();

  /// Stream thay đổi trạng thái auth
  Stream<AppUser?> get authStateChanges;
}
