import 'dart:async';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Repository giả lập cho môi trường không có Firebase
/// Sử dụng khi chưa cấu hình google-services.json
class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  final _authStateController = StreamController<AppUser?>.broadcast();

  // Danh sách user giả lập (email -> {password, displayName})
  final Map<String, Map<String, String>> _mockUsers = {
    'demo@beesaving.com': {
      'password': '123456',
      'displayName': 'Demo User',
    },
  };

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final userData = _mockUsers[email.toLowerCase()];
    if (userData == null) {
      throw 'Không tìm thấy tài khoản với email này.';
    }
    if (userData['password'] != password) {
      throw 'Mật khẩu không đúng. Vui lòng thử lại.';
    }

    _currentUser = AppUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: userData['displayName'],
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_mockUsers.containsKey(email.toLowerCase())) {
      throw 'Email này đã được sử dụng cho tài khoản khác.';
    }
    if (password.length < 6) {
      throw 'Mật khẩu quá yếu. Vui lòng dùng ít nhất 6 ký tự.';
    }

    _mockUsers[email.toLowerCase()] = {
      'password': password,
      'displayName': displayName,
    };

    _currentUser = AppUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: displayName,
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  AppUser? getCurrentUser() => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  void dispose() {
    _authStateController.close();
  }
}
