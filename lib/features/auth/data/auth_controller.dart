import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncData(null));

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authRepository.signUpWithEmail(
        email,
        password,
        fullName ?? 'User',
        phone,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authRepository.signInWithEmail(email, password),
    );
  }

  Future<void> signInWithPhone({required String phone}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authRepository.signInWithPhone(phone),
    );
  }

  Future<void> verifyOTP({required String phone, required String token}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authRepository.verifyOTP(phone, token),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.resetPassword(email));
  }

  Future<void> updateBusinessProfile(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.updateBusinessProfile(data));
  }
}
