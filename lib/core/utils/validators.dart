abstract final class Validators {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required.';
    }
    if (value.length > 80) {
      return 'Title must be at most 80 characters.';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required.';
    }
    if (value.length > 200) {
      return 'Location must be at most 200 characters.';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }
    if (value.length > 500) {
      return 'Description must be at most 500 characters.';
    }
    return null;
  }

  static String? validateMaxParticipants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Max participants is required.';
    }
    final n = int.tryParse(value.trim());
    if (n == null) {
      return 'Enter a valid number.';
    }
    if (n < 2) {
      return 'Minimum is 2 participants.';
    }
    if (n > 100) {
      return 'Maximum is 100 participants.';
    }
    return null;
  }

  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Date and time is required.';
    }
    if (!value.isAfter(DateTime.now())) {
      return 'Date must be in the future.';
    }
    return null;
  }
}
