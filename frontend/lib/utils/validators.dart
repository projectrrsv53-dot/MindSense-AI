// utils/validators.dart

class AppValidators {

  // =====================================================
  // EMAIL VALIDATION
  // =====================================================

  static String? validateEmail(
      String? value,
      ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(
      value.trim(),
    )) {

      return 'Enter a valid email address';
    }

    return null;
  }

  // =====================================================
  // PASSWORD VALIDATION
  // =====================================================

  static String? validatePassword(
      String? value,
      ) {

    if (value == null ||
        value.isEmpty) {

      return 'Password is required';
    }

    if (value.length < 8) {

      return 'Password must be at least 8 characters';
    }

    // at least one uppercase
    if (!RegExp(r'[A-Z]').hasMatch(value)) {

      return 'Password must contain an uppercase letter';
    }

    // at least one lowercase
    if (!RegExp(r'[a-z]').hasMatch(value)) {

      return 'Password must contain a lowercase letter';
    }

    // at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {

      return 'Password must contain a number';
    }

    // at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {

      return 'Password must contain a special character';
    }

    return null;
  }

  // =====================================================
  // NAME VALIDATION
  // =====================================================

  static String? validateName(
      String? value,
      ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'Name is required';
    }

    if (value.trim().length < 3) {

      return 'Name must be at least 3 characters';
    }

    return null;
  }

  // =====================================================
  // LICENSE VALIDATION
  // =====================================================

  static String? validateLicense(
      String? value,
      ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'License ID is required';
    }

    if (value.trim().length < 5) {

      return 'Enter valid license ID';
    }

    return null;
  }

  // =====================================================
  // AGE VALIDATION
  // =====================================================

  static String? validateAge(
      String? value,
      ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'Age is required';
    }

    final age = int.tryParse(value);

    if (age == null) {

      return 'Enter valid age';
    }

    if (age < 10 || age > 99) {

      return 'Enter realistic age';
    }

    return null;
  }

  // =====================================================
  // REQUIRED FIELD
  // =====================================================

  static String? requiredField(
      String? value,
      {
        String fieldName = 'Field',
      }
      ) {

    if (value == null ||
        value.trim().isEmpty) {

      return '$fieldName is required';
    }

    return null;
  }

  // =====================================================
// PHONE VALIDATION
// =====================================================

  static String? validatePhone(
      String? value,
      ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'Phone number is required';
    }

    final cleaned =
    value.trim();

    // only digits
    if (!RegExp(r'^[0-9]+$')
        .hasMatch(cleaned)) {

      return 'Phone number must contain only digits';
    }

    // exactly 10 digits
    if (cleaned.length != 10) {

      return 'Phone number must be 10 digits';
    }

    // Indian mobile numbers start from 6-9
    if (!RegExp(r'^[6-9]')
        .hasMatch(cleaned)) {

      return 'Enter valid phone number';
    }

    return null;
  }
}

