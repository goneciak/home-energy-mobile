import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/app_flavor.dart';

/// Dev entrypoint:
/// `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json`.
void main() => bootstrap(AppFlavor.dev);
