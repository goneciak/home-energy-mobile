/// Settings of the simulator. Every timing defaults to the generic firmware
/// image and can be compressed for tests.
class SimConfig {
  const new({
    this.coreUrl,
    this.port = 80,
    this.controlPort = 8081,
    this.ip = '127.0.0.1',
    this.hostname = 'gi-edge-sim',
    this.legacyDeviceId = 'gi-edge-sim-01',
    this.physicalMac = '02:47:49:ed:6e:01',
    this.stateFile,
    this.heartbeatInterval = const Duration(seconds: 15),
    this.telemetryInterval = const Duration(seconds: 5),
    this.pollInterval = const Duration(seconds: 5),
    this.tickInterval = const Duration(seconds: 1),
    this.verificationWindow = const Duration(seconds: 20),
    this.stoppingDuration = const Duration(seconds: 3),
    this.estimateDelay = const Duration(seconds: 180),
    this.bootGrace = const Duration(seconds: 60),
    this.selfHealRetry = const Duration(seconds: 30),
    this.requestTimeout = const Duration(seconds: 10),
    this.thermalSpeed = 1.0,
    this.noise = 0.05,
    this.requiredValidReads = 3,
  });

  factory fromEnv(Map<String, String> env, {String? ip}) {
    int number(String key, int fallback) =>
        int.tryParse(env[key] ?? '') ?? fallback;
    Duration seconds(String key, Duration fallback) {
      final value = double.tryParse(env[key] ?? '');
      return value == null
          ? fallback
          : Duration(milliseconds: (value * 1000).round());
    }

    const defaults = SimConfig();
    final core = env['CORE_URL'];
    return SimConfig(
      coreUrl: core == null || core.isEmpty ? null : core,
      port: number('PORT', defaults.port),
      controlPort: number('CONTROL_PORT', defaults.controlPort),
      ip: ip ?? defaults.ip,
      hostname: env['SIM_HOSTNAME'] ?? defaults.hostname,
      physicalMac: env['PHYSICAL_MAC'] ?? defaults.physicalMac,
      stateFile: env['STATE_FILE'],
      heartbeatInterval: seconds('SIM_HEARTBEAT_S', defaults.heartbeatInterval),
      telemetryInterval: seconds('SIM_TELEMETRY_S', defaults.telemetryInterval),
      pollInterval: seconds('SIM_POLL_S', defaults.pollInterval),
      verificationWindow: seconds(
        'SIM_VERIFICATION_S',
        defaults.verificationWindow,
      ),
      thermalSpeed:
          double.tryParse(env['SIM_THERMAL_SPEED'] ?? '') ??
          defaults.thermalSpeed,
      noise: double.tryParse(env['SIM_NOISE'] ?? '') ?? defaults.noise,
    );
  }

  /// Where the simulator reaches GI Core. When set it wins over the
  /// `core_url` of a `/gi-provision` push, which in the contract stack names
  /// the wrong port.
  final String? coreUrl;
  final int port;
  final int controlPort;
  final String ip;
  final String hostname;

  /// The id of the legacy manifest (`^[a-zA-Z0-9_-]+$`), not the Core UUID.
  final String legacyDeviceId;
  final String physicalMac;
  final String? stateFile;
  final Duration heartbeatInterval;
  final Duration telemetryInterval;
  final Duration pollInterval;
  final Duration tickInterval;
  final Duration verificationWindow;
  final Duration stoppingDuration;
  final Duration estimateDelay;

  /// 401 answers are not counted for this long after boot (firmware: 60 s).
  final Duration bootGrace;
  final Duration selfHealRetry;
  final Duration requestTimeout;
  final double thermalSpeed;
  final double noise;
  final int requiredValidReads;
}
