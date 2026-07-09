// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { none, patient, doctor, admin }
enum AuthStatus { unauthenticated, authenticated, verificationPending }

class AuthState {
  final UserRole role;
  final AuthStatus status;
  final String? userName;
  final String? userEmail;
  final bool isFirstTimeUser;
  final String? userId;

  const AuthState({
    this.role = UserRole.none,
    this.status = AuthStatus.unauthenticated,
    this.userName,
    this.userEmail,
    this.isFirstTimeUser = true,
    this.userId,
  });

  AuthState copyWith({
    UserRole? role,
    AuthStatus? status,
    String? userName,
    String? userEmail,
    bool? isFirstTimeUser,
    String? userId,
  }) {
    return AuthState(
      role: role ?? this.role,
      status: status ?? this.status,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void selectRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  void loginAsPatient({required String name, required String email, required String userId, bool isFirst = false}) {
    state = state.copyWith(
      role: UserRole.patient,
      status: AuthStatus.authenticated,
      userName: name,
      userEmail: email,
      userId: userId,
      isFirstTimeUser: isFirst,
    );
  }

  void loginAsDoctor({required String name, required String email, required String userId, bool pendingVerification = false}) {
    state = state.copyWith(
      role: UserRole.doctor,
      status: pendingVerification ? AuthStatus.verificationPending : AuthStatus.authenticated,
      userName: name,
      userEmail: email,
      userId: userId,
    );
  }

  void loginAsAdmin({required String email}) {
    state = state.copyWith(
      role: UserRole.admin,
      status: AuthStatus.authenticated,
      userEmail: email,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(),
);
