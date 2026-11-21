import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/app_flavor.dart';

/// Prod (store) entrypoint:
/// `flutter run --flavor prod -t lib/main.dart --dart-define-from-file=config/prod.json`.
void main() => bootstrap(AppFlavor.prod);
