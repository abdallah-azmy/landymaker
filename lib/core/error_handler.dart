import 'logger.dart';

class ErrorHandler {
  static void logError(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    Logger.error(message, error, stackTrace);
  }

  static String getHumanReadableError(dynamic error) {
    if (error is String) return error;

    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('socketexception')) {
      return "مشكلة في الاتصال بالإنترنت. يرجى المحاولة مرة أخرى.";
    }

    if (errorStr.contains('unexpected null value')) {
      return "حدث خطأ غير متوقع في معالجة الملف. يرجى تجربة ملف آخر.";
    }

    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return "لا تملك الصلاحية للقيام بهذا الإجراء.";
    }

    if (errorStr.contains('user_id') && errorStr.contains('null')) {
      return "جلسة العمل انتهت، يرجى تسجيل الدخول مرة أخرى.";
    }

    return "حدث خطأ ما: ${error.toString()}";
  }
}
