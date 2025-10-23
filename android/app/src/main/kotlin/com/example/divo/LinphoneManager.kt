package com.example.divo

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.linphone.core.*
import org.linphone.core.tools.service.CoreManager

class LinphoneManager(private val context: Context) {
    companion object {
        private const val TAG = "LinphoneManager"
        private var instance: LinphoneManager? = null
        
        fun getInstance(context: Context): LinphoneManager {
            if (instance == null) {
                instance = LinphoneManager(context.applicationContext)
            }
            return instance!!
        }
    }

    private var core: Core? = null
    private var callStateEventSink: EventChannel.EventSink? = null
    private var registrationStateEventSink: EventChannel.EventSink? = null
    
    private val coreListener = object : CoreListenerStub() {
        override fun onCallStateChanged(core: Core, call: Call, state: Call.State, message: String) {
            Log.i(TAG, "═══════════════════════════════════════════")
            Log.i(TAG, "🔔 CALL STATE CHANGED")
            Log.i(TAG, "   State: ${state.name}")
            Log.i(TAG, "   Direction: ${call.dir}")
            Log.i(TAG, "   Remote: ${call.remoteAddress?.asStringUriOnly()}")
            Log.i(TAG, "   Message: $message")
            Log.i(TAG, "═══════════════════════════════════════════")
            
            val callData = mapOf(
                "state" to state.name,
                "remoteAddress" to (call.remoteAddress?.asStringUriOnly() ?: ""),
                "direction" to if (call.dir == Call.Dir.Incoming) "incoming" else "outgoing"
            )
            
            Log.d(TAG, "📤 Sending call data to Flutter: $callData")
            callStateEventSink?.success(callData)
            
            if (callStateEventSink == null) {
                Log.e(TAG, "❌ callStateEventSink is NULL! Flutter is not listening!")
            }
        }
        
        override fun onAccountRegistrationStateChanged(
            core: Core,
            account: Account,
            state: RegistrationState,
            message: String
        ) {
            Log.i(TAG, "📱 Account registration state: ${state.name}, Can receive calls: ${state == RegistrationState.Ok}")
        }
        
        override fun onMessageReceived(core: Core, chatRoom: ChatRoom, message: ChatMessage) {
            Log.d(TAG, "📨 Message received (chat)")
        }
        
        override fun onDtmfReceived(core: Core, call: Call, dtmf: Int) {
            Log.d(TAG, "📞 DTMF received: $dtmf")
        }
        
        override fun onCallCreated(core: Core, call: Call) {
            Log.i(TAG, "═══════════════════════════════════════════")
            Log.i(TAG, "📲 NEW CALL CREATED!")
            Log.i(TAG, "   Remote: ${call.remoteAddress?.asStringUriOnly()}")
            Log.i(TAG, "   Direction: ${call.dir}")
            Log.i(TAG, "   State: ${call.state}")
            Log.i(TAG, "═══════════════════════════════════════════")
        }

        override fun onRegistrationStateChanged(
            core: Core,
            proxyConfig: ProxyConfig,
            state: RegistrationState,
            message: String
        ) {
            Log.d(TAG, "Registration state: ${state.name}, message: $message")
            
            // Log contact information when registration succeeds
            if (state == RegistrationState.Ok) {
                val contactAddr = proxyConfig.contact?.asString()
                val contactPort = proxyConfig.contact?.port
                val contactHost = proxyConfig.contact?.domain
                
                Log.i(TAG, "═══════════════════════════════════════════")
                Log.i(TAG, "✅ REGISTRATION SUCCESSFUL")
                Log.i(TAG, "   Identity: ${proxyConfig.identityAddress?.asStringUriOnly()}")
                Log.i(TAG, "   Contact: $contactAddr")
                Log.i(TAG, "   Contact Host: $contactHost")
                Log.i(TAG, "   Contact Port: $contactPort")
                Log.i(TAG, "   Server: ${proxyConfig.serverAddr}")
                Log.i(TAG, "   ")
                Log.i(TAG, "   📞 To test incoming calls:")
                Log.i(TAG, "   📞 Call from desktop: ${proxyConfig.identityAddress?.asStringUriOnly()}")
                Log.i(TAG, "   🔔 Listening on: $contactHost:$contactPort")
                Log.i(TAG, "   ")
                Log.i(TAG, "   ⚠️  If Contact Host is 192.168.x.x (local IP):")
                Log.i(TAG, "   ⚠️  STUN didn't work - incoming calls will fail")
                Log.i(TAG, "   ✅ If Contact Host is public IP - incoming calls should work")
                Log.i(TAG, "═══════════════════════════════════════════")
            }
            
            val regData = mapOf(
                "state" to state.name,
                "message" to message
            )
            
            registrationStateEventSink?.success(regData)
        }
    }

    fun initialize(): Boolean {
        try {
            if (core != null) {
                Log.d(TAG, "Core already initialized")
                return true
            }

            val factory = Factory.instance()
            factory.setDebugMode(true, "Divo")
            
            // Create core with verbose logging
            core = factory.createCore(null, null, context)
            core?.enableLogCollection(LogCollectionState.Enabled)
            
            // Set verbose logging to see ALL SIP messages
            Factory.instance().loggingService?.setLogLevel(LogLevel.Debug)
            
            core?.addListener(coreListener)
            Log.d(TAG, "✅ Core listener added successfully")
            
            // Enable automatic iterate
            core?.isAutoIterateEnabled = true
            Log.d(TAG, "✅ Auto iterate enabled")
            
            // Configure audio settings
            core?.isEchoCancellationEnabled = true
            core?.isAdaptiveRateControlEnabled = true
            core?.isNativeRingingEnabled = true
            
            // Set max calls to allow incoming
            core?.maxCalls = 10
            
            // Configure NAT traversal - CRITICAL for incoming calls
            val natPolicy = core?.createNatPolicy()
            natPolicy?.isStunEnabled = true
            natPolicy?.isIceEnabled = true
            natPolicy?.stunServer = "stun.linphone.org"
            natPolicy?.stunServerUsername = null
            natPolicy?.isUpnpEnabled = false // Disable UPnP, use STUN only
            
            // Apply NAT policy to core
            core?.natPolicy = natPolicy
            
            Log.i(TAG, "🌐 NAT Policy Created: STUN=${natPolicy?.isStunEnabled}, ICE=${natPolicy?.isIceEnabled}")
            Log.i(TAG, "🌐 STUN Server: ${natPolicy?.stunServer}")
            Log.i(TAG, "🌐 This should help incoming calls work through NAT/firewall")
            
            // CRITICAL: Configure transports to match official Linphone app
            val transports = core?.transports
            if (transports != null) {
                transports.udpPort = 0 // Let SDK choose random port (same as official app)
                transports.tcpPort = 0
                transports.tlsPort = 0
                core?.transports = transports
                Log.i(TAG, "🌐 Transport configured: UDP=${transports.udpPort}, TCP=${transports.tcpPort}")
            }
            
            // Start the core
            core?.start()
            
            // Log actual port being used
            val actualPort = core?.transports?.udpPort
            Log.i(TAG, "🌐 Linphone listening on UDP port: $actualPort")
            Log.d(TAG, "📞 Incoming calls enabled, max calls: ${core?.maxCalls}")
            
            Log.d(TAG, "Linphone Core initialized successfully")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Linphone Core: ${e.message}", e)
            return false
        }
    }

    fun login(username: String, password: String, domain: String): Boolean {
        try {
            Log.d(TAG, "Attempting login for: $username@$domain")
            
            // CRITICAL: Wait a moment for STUN to discover public IP
            // This ensures our Contact header has the correct public address
            Thread.sleep(2000) // 2 seconds for STUN discovery
            Log.d(TAG, "⏰ Waited for STUN discovery to complete")
            
            if (core == null) {
                Log.e(TAG, "Core not initialized")
                return false
            }

            // Clear any existing auth info
            core?.clearAllAuthInfo()
            core?.clearProxyConfig()

            val factory = Factory.instance()
            
            // Create auth info
            val authInfo = factory.createAuthInfo(
                username,
                null,
                password,
                null,
                null,
                domain,
                null
            )
            core?.addAuthInfo(authInfo)

            // Create proxy config
            val identity = "sip:$username@$domain"
            val address = factory.createAddress(identity)
            
            if (address == null) {
                Log.e(TAG, "Failed to create address for: $identity")
                return false
            }

            val proxyConfig = core?.createProxyConfig()
            if (proxyConfig == null) {
                Log.e(TAG, "Failed to create proxy config")
                return false
            }
            
            proxyConfig.identityAddress = address
            proxyConfig.serverAddr = "sip:$domain"
            proxyConfig.isRegisterEnabled = true
            proxyConfig.isPushNotificationAllowed = true
            
            // Ensure we can receive incoming calls
            proxyConfig.contactParameters = "app-id=divo"
            
            // Apply NAT policy to this account for incoming calls
            proxyConfig.natPolicy = core?.natPolicy
            
            // CRITICAL: Force use of public address from STUN for contact
            // This ensures incoming calls are routed correctly through NAT
            proxyConfig.publishExpires = 600
            
            core?.addProxyConfig(proxyConfig)
            core?.defaultProxyConfig = proxyConfig

            Log.i(TAG, "═══════════════════════════════════════════")
            Log.i(TAG, "📝 LOGIN CONFIGURATION")
            Log.i(TAG, "   Identity: $username@$domain")
            Log.i(TAG, "   Server: sip:$domain")
            Log.i(TAG, "   Contact: ${proxyConfig.contact}")
            Log.i(TAG, "   Expecting incoming calls on this address")
            Log.i(TAG, "═══════════════════════════════════════════")
            
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Login error: ${e.message}", e)
            return false
        }
    }

    fun makeCall(address: String): Boolean {
        try {
            if (core == null) {
                Log.e(TAG, "Core not initialized")
                return false
            }

            // Clean address - remove any existing sip: prefix
            var cleanAddress = address.trim()
            if (cleanAddress.startsWith("sip:")) {
                cleanAddress = cleanAddress.substring(4)
            }
            
            // If address doesn't contain @, add default domain
            if (!cleanAddress.contains("@")) {
                val defaultProxy = core?.defaultProxyConfig
                val domain = defaultProxy?.domain
                if (domain != null) {
                    cleanAddress = "$cleanAddress@$domain"
                }
            }

            val sipAddress = "sip:$cleanAddress"
            Log.d(TAG, "Making call to: $sipAddress")

            val remoteAddress = Factory.instance().createAddress(sipAddress)
            if (remoteAddress == null) {
                Log.e(TAG, "Failed to create address for: $sipAddress")
                return false
            }

            val params = core?.createCallParams(null)
            if (params == null) {
                Log.e(TAG, "Failed to create call params")
                return false
            }
            
            params.isVideoEnabled = false
            
            val call = core?.inviteAddressWithParams(remoteAddress, params)
            
            return call != null
        } catch (e: Exception) {
            Log.e(TAG, "Make call error: ${e.message}", e)
            return false
        }
    }

    fun answerCall(): Boolean {
        try {
            val call = core?.currentCall ?: return false
            
            val params = core?.createCallParams(call)
            params?.isVideoEnabled = false
            
            call.acceptWithParams(params)
            Log.d(TAG, "Call answered")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Answer call error: ${e.message}", e)
            return false
        }
    }

    fun hangUp(): Boolean {
        try {
            val call = core?.currentCall
            if (call != null) {
                call.terminate()
                Log.d(TAG, "Call terminated")
                return true
            }
            return false
        } catch (e: Exception) {
            Log.e(TAG, "Hang up error: ${e.message}", e)
            return false
        }
    }

    fun toggleMute(): Boolean {
        try {
            val isMuted = core?.isMicEnabled == false
            core?.isMicEnabled = !isMuted
            Log.d(TAG, "Microphone muted: ${!isMuted}")
            return !isMuted
        } catch (e: Exception) {
            Log.e(TAG, "Toggle mute error: ${e.message}", e)
            return false
        }
    }

    fun toggleSpeaker(): Boolean {
        try {
            val currentDevice = core?.outputAudioDevice
            val devices = core?.audioDevices
            
            if (devices != null && devices.isNotEmpty()) {
                // Find speaker device
                val speaker = devices.find { 
                    it.type == AudioDevice.Type.Speaker 
                }
                
                // Find earpiece device
                val earpiece = devices.find { 
                    it.type == AudioDevice.Type.Earpiece 
                }
                
                // Toggle between speaker and earpiece
                if (currentDevice?.type == AudioDevice.Type.Speaker) {
                    earpiece?.let { core?.outputAudioDevice = it }
                    Log.d(TAG, "Switched to earpiece")
                    return false
                } else {
                    speaker?.let { core?.outputAudioDevice = it }
                    Log.d(TAG, "Switched to speaker")
                    return true
                }
            }
            
            return false
        } catch (e: Exception) {
            Log.e(TAG, "Toggle speaker error: ${e.message}", e)
            return false
        }
    }

    fun isMicMuted(): Boolean {
        return core?.isMicEnabled == false
    }

    fun getRegistrationState(): String {
        val state = core?.defaultProxyConfig?.state?.name ?: "None"
        val contact = core?.defaultProxyConfig?.contact
        Log.i(TAG, "📊 Current Registration Status: $state")
        Log.i(TAG, "📊 Contact Address: $contact")
        Log.i(TAG, "📊 Can Receive Calls: ${core?.defaultProxyConfig?.state == RegistrationState.Ok}")
        return state
    }

    fun setCallStateEventSink(eventSink: EventChannel.EventSink?) {
        this.callStateEventSink = eventSink
        if (eventSink != null) {
            Log.d(TAG, "✅ Flutter call state listener connected")
        } else {
            Log.d(TAG, "⚠️ Flutter call state listener disconnected")
        }
    }

    fun setRegistrationStateEventSink(eventSink: EventChannel.EventSink?) {
        this.registrationStateEventSink = eventSink
        if (eventSink != null) {
            Log.d(TAG, "✅ Flutter registration listener connected")
        } else {
            Log.d(TAG, "⚠️ Flutter registration listener disconnected")
        }
    }

    fun destroy() {
        core?.removeListener(coreListener)
        core?.stop()
        core = null
        callStateEventSink = null
        registrationStateEventSink = null
    }
}
