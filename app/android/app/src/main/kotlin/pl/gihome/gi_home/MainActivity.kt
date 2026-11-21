package pl.gihome.gi_home

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Serves the app's method channel (lib/src/core/platform/gi_platform_channel.dart):
 * the API level, the app's system settings page and the runtime request for
 * NEARBY_WIFI_DEVICES (local network protection, plan §9.4).
 */
class MainActivity : FlutterActivity() {
    private var pendingPermission: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                    "openAppSettings" -> result.success(openAppSettings())
                    "requestNearbyWifiDevices" -> requestNearbyWifiDevices(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun openAppSettings(): Boolean {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.fromParts("package", packageName, null),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(intent)
            true
        } catch (e: android.content.ActivityNotFoundException) {
            false
        }
    }

    private fun requestNearbyWifiDevices(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(GRANTED)
            return
        }
        val permission = Manifest.permission.NEARBY_WIFI_DEVICES
        if (checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
            result.success(GRANTED)
            return
        }
        if (pendingPermission != null) {
            result.error("busy", "A permission request is already showing", null)
            return
        }
        pendingPermission = result
        requestPermissions(arrayOf(permission), NEARBY_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NEARBY_REQUEST_CODE) return
        val result = pendingPermission ?: return
        pendingPermission = null
        val answer = when {
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED -> GRANTED
            // Without a rationale to show, the system will not ask again.
            grantResults.isNotEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                !shouldShowRequestPermissionRationale(Manifest.permission.NEARBY_WIFI_DEVICES) ->
                "permanentlyDenied"
            else -> "denied"
        }
        result.success(answer)
    }

    private companion object {
        const val CHANNEL = "pl.gihome.gi_home/platform"
        const val NEARBY_REQUEST_CODE = 4033
        const val GRANTED = "granted"
    }
}
