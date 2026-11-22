import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/platform/platform_providers.dart';
import 'package:gi_home/src/features/appliance/application/core_client_providers.dart';
import 'package:gi_home/src/features/auth/application/auth_session_notifier.dart';
import 'package:gi_home/src/features/devices/data/device_command_source.dart';
import 'package:gi_home/src/features/devices/data/device_read_source.dart';
import 'package:gi_home/src/features/devices/data/devices_repository.dart';
import 'package:gi_home/src/features/devices/data/rooms_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_repositories.g.dart';

/// Device endpoints of the saved appliance. Only read once signed in, i.e.
/// when a client exists.
@Riverpod(keepAlive: true)
DeviceReadSource deviceReadSource(Ref ref) {
  final client = ref.watch(giCoreClientProvider);
  if (client == null) return const _Detached();
  return GiCoreDeviceReadSource(client);
}

/// Device write endpoints of the saved appliance (plan §12). Only read once
/// signed in, i.e. when a client exists.
@Riverpod(keepAlive: true)
DeviceCommandSource deviceCommandSource(Ref ref) {
  final client = ref.watch(giCoreClientProvider);
  if (client == null) return const _Detached();
  return GiCoreDeviceCommandSource(client);
}

/// Shared device cache. A new appliance gets a new repository; a different
/// (or no) user clears it, so nothing outlives the session (plan §8.3).
@Riverpod(keepAlive: true)
DevicesRepository devicesRepository(Ref ref) {
  final repository = DevicesRepository(
    ref.watch(deviceReadSourceProvider),
    clock: ref.watch(clockProvider),
  );
  ref.listen(
    currentUserProvider.select((user) => user?.id),
    (_, _) => repository.clear(),
  );
  return repository;
}

/// Shared room cache, cleared like [devicesRepository].
@Riverpod(keepAlive: true)
RoomsRepository roomsRepository(Ref ref) {
  final repository = RoomsRepository(
    ref.watch(deviceReadSourceProvider),
    clock: ref.watch(clockProvider),
  );
  ref.listen(
    currentUserProvider.select((user) => user?.id),
    (_, _) => repository.clear(),
  );
  return repository;
}

/// The sources while there is no client: for the frame between leaving demo
/// mode (or forgetting the appliance) and the router's redirect, screens
/// still mounted rebuild. Failing each call, not the provider, lets them
/// show an error state for that frame instead of throwing during build.
/// Nothing is ever sent.
final class _Detached implements DeviceReadSource, DeviceCommandSource {
  const new();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      Future<Never>.error(StateError('No appliance profile'));
}
