/// Pure-Dart client for the existing, unchangeable GI Core API (`/api/v1`).
///
/// Entry points: [GiCoreClient] (typed calls + session), [ApplianceProbe]
/// (connect screen), [GiEndpoints] (catalog and role gating) and
/// [ApiFailure] (every error the client reports).
library;

import 'package:gi_core_api/gi_core_api.dart'
    show ApiFailure, ApplianceProbe, GiCoreClient, GiEndpoints;

export 'src/auth/auth_session_manager.dart'
    show ApplianceRenamed, AuthSessionManager;
export 'src/auth/auth_state.dart';
export 'src/auth/monotonic_clock.dart';
export 'src/auth/refresh_cookie.dart';
export 'src/auth/token_vault.dart';
export 'src/catalog/endpoint.dart';
export 'src/catalog/endpoints.dart';
export 'src/failures/api_error_envelope.dart';
export 'src/failures/api_failure.dart';
export 'src/failures/error_codes.dart';
export 'src/failures/failure_mapping.dart'
    show
        LocalNetworkDeniedDetector,
        defaultLocalNetworkDeniedDetector,
        failureFromResponse,
        mapDioException;
export 'src/failures/failure_observer.dart' show ApiFailureObserver;
export 'src/gi_core_client.dart';
export 'src/http/client_info.dart';
export 'src/http/concurrency_limiter.dart';
export 'src/http/conditional_get.dart';
export 'src/http/interceptors.dart'
    show AccessTokenSource, HttpLogSink, RedactingLogInterceptor;
export 'src/http/response_decoding.dart' show DecodeMode, unknownJsonFields;
export 'src/http/transport_policy.dart';
export 'src/models/account_models.dart';
export 'src/models/auth_models.dart';
export 'src/models/device_commands.dart';
export 'src/models/device_detail.dart';
export 'src/models/device_list_item.dart';
export 'src/models/entity_value.dart';
export 'src/models/enums.dart';
export 'src/models/environment_models.dart';
export 'src/models/heating_schedule.dart';
export 'src/models/history.dart';
export 'src/models/local_wall_time.dart';
export 'src/models/password_policy.dart';
export 'src/models/room.dart';
export 'src/models/system_models.dart';
export 'src/models/user_models.dart';
export 'src/probe/appliance_address.dart';
export 'src/probe/appliance_probe.dart';
export 'src/probe/capability_probe.dart';
