package com.example.spotify_clone

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// audio_service requires the launcher Activity to extend AudioServiceActivity
// (not plain FlutterActivity) so it can attach the correct FlutterEngine for
// the lock-screen / notification media session. Without this, AudioService.init()
// throws "The Activity class declared in your AndroidManifest.xml is wrong..."
// and the Spotify-style notification never appears.
class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "melora/bluetooth"
    private val REQUEST_ENABLE_BT = 4210
    private val REQUEST_BT_PERMISSION = 4211
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enable" -> enableBluetooth(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun getAdapter(): BluetoothAdapter? {
        val manager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        return manager?.adapter
    }

    private fun hasConnectPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        return ContextCompat.checkSelfPermission(
            this,
            android.Manifest.permission.BLUETOOTH_CONNECT
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun enableBluetooth(result: MethodChannel.Result) {
        val adapter = getAdapter()
        if (adapter == null) {
            result.error("NO_BLUETOOTH", "This device doesn't support Bluetooth", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !hasConnectPermission()) {
            pendingResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.BLUETOOTH_CONNECT),
                REQUEST_BT_PERMISSION
            )
            return
        }

        if (adapter.isEnabled) {
            result.success("already_on")
            return
        }

        pendingResult = result
        val enableIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        startActivityForResult(enableIntent, REQUEST_ENABLE_BT)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_BT_PERMISSION) {
            val result = pendingResult
            pendingResult = null
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                result?.let { enableBluetooth(it) }
            } else {
                result?.error("PERMISSION_DENIED", "Bluetooth permission was denied", null)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ENABLE_BT) {
            val result = pendingResult
            pendingResult = null
            if (resultCode == RESULT_OK) {
                result?.success("turned_on")
            } else {
                result?.error("CANCELLED", "Bluetooth was not turned on", null)
            }
        }
    }
}