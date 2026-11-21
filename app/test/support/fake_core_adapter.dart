// The in-process GI Core now lives in lib (the dev flavor's mock uses it);
// these names keep the widget tests' vocabulary.
import 'package:gi_home/src/core/dev/mock_core_adapter.dart';

export 'package:gi_home/src/core/dev/mock_core_adapter.dart';

/// The in-process GI Core of the widget tests.
typedef FakeCoreAdapter = MockCoreAdapter;
typedef FakeHandler = MockHandler;

/// A syntactically valid refresh cookie (test value, not a real token).
final String testSetCookie = mockSetCookie;
