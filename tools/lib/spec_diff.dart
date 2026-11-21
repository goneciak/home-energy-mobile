/// Spec drift check (plan §17.5): the live GI Core OpenAPI spec against the
/// committed snapshot, filtered to the client's endpoint catalog.
library;

export 'src/repo.dart';
export 'src/spec_diff/client_shapes.dart';
export 'src/spec_diff/openapi.dart';
export 'src/spec_diff/spec_diff.dart';
export 'src/spec_diff/spec_io.dart';
