import 'package:logger/logger.dart';

/// App-wide logging facade. Everything (sync, risk scoring, audit-relevant
/// actions) should log through here rather than calling `print`, so output
/// format/verbosity/destination stays controllable in one place.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warning(String message) => _logger.w(message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
