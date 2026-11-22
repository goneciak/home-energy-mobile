/// Simulated phones for measuring the request load the app puts on GI Core:
/// the app's own polling cadences replayed against a contract stack (or an
/// in-process fake with `--dry-run`), with a report on the request rate and,
/// when docker is available, the CPU of the GI Core container.
library;

export 'src/load/cold_start.dart';
export 'src/load/container_sampler.dart';
export 'src/load/fake_core_server.dart';
export 'src/load/load_report.dart';
export 'src/load/load_stats.dart';
export 'src/load/phone_simulator.dart';
