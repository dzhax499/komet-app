class EmailMasker {
  /// Menyamarkan email. Contoh: dzhax499@gmail.com -> dz*****@gmail.com
  static String maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;

    final parts = email.split('@');
    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.length <= 2) {
      return '${localPart.substring(0, 1)}***@$domainPart';
    }

    final visiblePart = localPart.substring(0, 2);
    final maskedPart = '*' * (localPart.length - 2);

    return '$visiblePart$maskedPart@$domainPart';
  }
}
