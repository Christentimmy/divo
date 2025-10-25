package com.example.divo

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.divo.linphone/methods"
    private val CALL_STATE_CHANNEL = "com.divo.linphone/call_state"
    private val REGISTRATION_CHANNEL = "com.divo.linphone/registration_state"

    private lateinit var linphoneManager: LinphoneManager
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Start CoreService
        val serviceIntent = Intent(this, LinphoneCoreService::class.java)
        startService(serviceIntent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        linphoneManager = LinphoneManager.getInstance(applicationContext)

        // Method Channel for method calls
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val success = linphoneManager.initialize()
                    result.success(success)
                }
                "login" -> {
                    val username = call.argument<String>("username")
                    val password = call.argument<String>("password")
                    val domain = call.argument<String>("domain")

                    if (username != null && password != null && domain != null) {
                        val success = linphoneManager.login(username, password, domain)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Missing required arguments", null)
                    }
                }
                "makeCall" -> {
                    val address = call.argument<String>("address")
                    if (address != null) {
                        val success = linphoneManager.makeCall(address)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGS", "Missing address", null)
                    }
                }
                "answerCall" -> {
                    val success = linphoneManager.answerCall()
                    result.success(success)
                }
                "acceptCall" -> {
                    val success = linphoneManager.acceptCall()
                    result.success(success)
                }
                "hangUp" -> {
                    val success = linphoneManager.hangUp()
                    result.success(success)
                }
                "toggleMute" -> {
                    val isMuted = linphoneManager.toggleMute()
                    result.success(isMuted)
                }
                "toggleSpeaker" -> {
                    val isSpeakerOn = linphoneManager.toggleSpeaker()
                    result.success(isSpeakerOn)
                }
                "isMicMuted" -> {
                    val isMuted = linphoneManager.isMicMuted()
                    result.success(isMuted)
                }
                "getRegistrationState" -> {
                    val state = linphoneManager.getRegistrationState()
                    result.success(state)
                }
                "debugIncomingCalls" -> {
                    // Force check if we can receive calls
                    val state = linphoneManager.getRegistrationState()
                    result.success("Check logs for incoming call debug info")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Event Channel for call state updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_STATE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    linphoneManager.setCallStateEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    linphoneManager.setCallStateEventSink(null)
                }
            })

        // Event Channel for registration state updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, REGISTRATION_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    linphoneManager.setRegistrationStateEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    linphoneManager.setRegistrationStateEventSink(null)
                }
            })
    }

    override fun onDestroy() {
        methodChannel?.setMethodCallHandler(null)
        super.onDestroy()
    }
}
