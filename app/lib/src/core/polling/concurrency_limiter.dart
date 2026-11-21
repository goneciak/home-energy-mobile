/// The async semaphore lives in `gi_core_api`, which also uses it for the
/// per-appliance cap of 4 requests in flight (plan §11). The app uses it for
/// smaller groups of pollers, such as the Home heating cards (at most 3).
library;

export 'package:gi_core_api/gi_core_api.dart' show ConcurrencyLimiter;
