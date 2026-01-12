import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  Future<void> login(String email, String password) async {
    await _ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _ref.read(authRepositoryProvider).signUpWithEmailAndPassword(email, password);
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).signOut();
  }
}
