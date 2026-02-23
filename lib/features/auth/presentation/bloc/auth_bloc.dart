import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RegisterEvent>(_onRegister);
  }

  void _onCheckAuthSession(
    CheckAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Simulate check session
    await Future.delayed(const Duration(seconds: 2));
    emit(Unauthenticated());
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.phone, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    emit(Unauthenticated());
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        phone: event.phone,
        password: event.password,
        role: event.role,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
