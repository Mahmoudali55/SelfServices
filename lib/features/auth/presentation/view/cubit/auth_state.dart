part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final StatusState<AuthResponseModel> loginStatus;
  final StatusState<EmpLoginModel> empLoginStatus;

  const AuthState({
    this.loginStatus = const StatusState.initial(),
    this.empLoginStatus = const StatusState.initial(),
  });

  AuthState copyWith({
    StatusState<AuthResponseModel>? loginStatus,
    StatusState<EmpLoginModel>? empLoginStatus,
  }) {
    return AuthState(
      loginStatus: loginStatus ?? this.loginStatus,
      empLoginStatus: empLoginStatus ?? this.empLoginStatus,
    );
  }

  @override
  List<Object?> get props => [loginStatus, empLoginStatus];
}
