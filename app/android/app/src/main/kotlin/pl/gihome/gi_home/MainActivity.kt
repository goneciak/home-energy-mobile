package pl.gihome.gi_home

import android.Manifest
import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Serves the app's method channel (lib/src/core/platform/gi_platform_channel.dart):
 * the API level, the app's system settings page and the runtime request for
 * NEARBY_WIFI_DEVICES (local network protection, plan §9.4); and the
 * `gi_home/secure` channel (lib/src/core/platform/secure_display.dart):
 * FLAG_SECURE while a secret is shown and a sensitive, self-clearing clip.
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        if (call.argument<Boolean>("secure") == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    "copySensitive" -> result.success(
                        copySensitive(
                            call.argument<String>("text") ?: "",
                            call.argument<Number>("clearAfterMs")?.toLong() ?: 60_000L,
                        ),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    /** Copies [text] marked sensitive; clears it after [clearAfterMs] if unchanged. */
    private fun copySensitive(text: String, clearAfterMs: Long): Boolean {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            ?: return false
        val clip = ClipData.newPlainText("", text)
        clip.description.extras = PersistableBundle().apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
            } else {
                putBoolean("android.content.extra.IS_SENSITIVE", true)
            }
        }
        clipboard.setPrimaryClip(clip)
        Handler(Looper.getMainLooper()).postDelayed({
            val current = clipboard.primaryClip?.getItemAt(0)?.text?.toString()
            if (current == text) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    clipboard.clearPrimaryClip()
                } else {
                    clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
                }
            }
        }, clearAfterMs)
        return true
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
        const val SECURE_CHANNEL = "gi_home/secure"
        const val NEARBY_REQUEST_CODE = 4033
        const val GRANTED = "granted"
    }
}
