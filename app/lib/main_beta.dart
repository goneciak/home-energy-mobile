import 'package:gi_home/src/app/bootstrap.dart';
import 'package:gi_home/src/core/config/app_flavor.dart';

/// Beta entrypoint:
/// `flutter run --flavor beta -t lib/main_beta.dart --dart-define-from-file=config/beta.json`.
void main() => bootstrap(AppFlavor.beta);
