class PasswordRecoveryRequest {
  final String email;

  PasswordRecoveryRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}

class PasswordResetRequest {
  final String newPassword;
  final String token;

  PasswordResetRequest({
    required this.newPassword,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'nuevaContraseña': newPassword,
        'token': token,
      };
}
