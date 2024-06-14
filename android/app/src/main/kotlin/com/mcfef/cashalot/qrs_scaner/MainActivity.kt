package com.mcfef.cashalot.qrs_scaner


import android.os.Bundle
import android.os.PersistableBundle
import androidx.annotation.NonNull
import androidx.core.app.NotificationManagerCompat
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val AUDIO_MANAGER_METHOD_CHANNEL= "com.application.scanner/audio_manager"
    private val AUDIO_MANAGER_EVENT_CHANNEL= "com.application.scanner/audio_manager_event"
    lateinit private var audioManager: QRAudioManager

    companion object {
        var audioManagerSink: EventChannel.EventSink? = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_MANAGER_METHOD_CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "PLAY_SCANNER_SOUND") {
                audioManager.playBeepSound()
            } else if (call.method == "PLAY_ERROR_SOUND") {
                audioManager.playErrorSound()
            } else if (call.method == "CHECK_PERMISSIONS") {
                println("Check permission")
            }
        }



        super.configureFlutterEngine(flutterEngine)

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        audioManager = QRAudioManager(context)
    }
}
