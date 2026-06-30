class JsonUtils {
  const JsonUtils._();

  static int intValue(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String stringValue(dynamic value, {String fallback = ''}) {
    return value?.toString() ?? fallback;
  }

  static DateTime dateValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
