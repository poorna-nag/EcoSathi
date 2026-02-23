import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthSessionEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;
  const LoginEvent({required this.phone, required this.password});

  @override
  List<Object> get props => [phone, password];
}

class LogoutEvent extends AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String name;
  final String phone;
  final String password;
  final UserRole role;

  const RegisterEvent({
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [name, phone, password, role];
}
