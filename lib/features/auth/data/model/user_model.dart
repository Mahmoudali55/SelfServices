import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String empName;
  final String empNameE;
  final String dCode;
  final String dName;
  final String empCode;
  final String empState;

  const User({
    required this.empName,
    required this.empNameE,
    required this.dCode,
    required this.dName,
    required this.empCode,
    required this.empState,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    empName: json['EMP_NAME'] as String? ?? '',
    empNameE: json['EMP_NAME_E'] as String? ?? '',
    dCode: json['D_CODE'] as String? ?? '',
    dName: json['D_NAME'] as String? ?? '',
    empCode: json['EMP_CODE'] as String? ?? '',
    empState: json['EmpState'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'EMP_NAME': empName,
    'EMP_NAME_E': empNameE,
    'D_CODE': dCode,
    'D_NAME': dName,
    'EMP_CODE': empCode,
    'EmpState': empState,
  };

  @override
  List<Object?> get props => [empName, empNameE, dCode, dName, empCode, empState];
}

class AuthResponseModel extends Equatable {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final User user;
  final String issued;
  final String expires;

  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.issued,
    required this.expires,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 0,
      issued: json['.issued'] as String? ?? '',
      expires: json['.expires'] as String? ?? '',
      user: User.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'expires_in': expiresIn,
    '.issued': issued,
    '.expires': expires,
    ...user.toJson(),
  };

  @override
  List<Object?> get props => [accessToken, tokenType, expiresIn, issued, expires, user];
}
