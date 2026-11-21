import 'package:integration_test/integration_test_driver.dart';

/// Host side of `flutter drive` for the tests in `integration_test/`, used
/// for profile-mode runs (much smaller APK than `flutter test`'s debug build).
Future<void> main() => integrationDriver();
