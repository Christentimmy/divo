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
            Log.i(TAG, "   Direction: ${if (call.dir == Call.Dir.Incoming) "INCOMING" else "OUTGOING"}")
            Log.i(TAG, "   State: ${call.state}")
            Log.i(TAG, "   ")
            if (call.dir == Call.Dir.Incoming) {
                Log.i(TAG, "   🎉 INCOMING CALL DETECTED!")
                Log.i(TAG, "   🎉 This is what we've been waiting for!")
            }
            Log.i(TAG, "═══════════════════════════════════════════")
        }

        override fun onRegistrationStateChanged(
            core: Core,
            proxyConfig: ProxyConfig,
            state: RegistrationState,
            message: String
        ) {
            Log.i(TAG, "════════════════════════════════════════════")
            Log.i(TAG, "📡 REGISTRATION STATE CHANGE")
            Log.i(TAG, "   State: ${state.name}")
            Log.i(TAG, "   Message: $message")
            Log.i(TAG, "════════════════════════════════════════════")
            
            // Log contact information when registration succeeds
            if (state == RegistrationState.Ok) {
                val contactAddr = proxyConfig.contact?.asString()
                val contactPort = proxyConfig.contact?.port
                val contactHost = proxyConfig.contact?.domain
                val transportPort = core.transports?.udpPort
                
                Log.i(TAG, "═══════════════════════════════════════════")
                Log.i(TAG, "✅ REGISTRATION SUCCESSFUL")
                Log.i(TAG, "   Identity: ${proxyConfig.identityAddress?.asStringUriOnly()}")
                Log.i(TAG, "   Contact: $contactAddr")
                Log.i(TAG, "   Contact Host: $contactHost")
                Log.i(TAG, "   Contact Port: $contactPort")
                Log.i(TAG, "   Actual UDP Port: $transportPort")
                Log.i(TAG, "   Server: ${proxyConfig.serverAddr}")
                Log.i(TAG, "   ")
                Log.i(TAG, "   📞 To test incoming calls:")
                Log.i(TAG, "   📞 Call from desktop: ${proxyConfig.identityAddress?.asStringUriOnly()}")
                Log.i(TAG, "   ")
                Log.i(TAG, "   🔍 DEBUGGING:")
                Log.i(TAG, "   The SIP server should route calls to: $contactAddr")
                Log.i(TAG, "   But we're actually listening on UDP port: $transportPort")
                Log.i(TAG, "   If CANCEL shows local IP - contact wasn't registered correctly")
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
            // Set MAXIMUM verbose logging to see ALL SIP messages including REGISTER
            Factory.instance().loggingService?.setLogLevel(LogLevel.Message)
            core?.addListener(coreListener)
            
            Log.i(TAG, "═══════════════════════════════════════════")
            Log.i(TAG, "🔍 SIP MESSAGE LOGGING ENABLED")
            Log.i(TAG, "   You will see ALL SIP messages including REGISTER")
            Log.i(TAG, "   Look for 'Contact:' header in REGISTER message")
            Log.i(TAG, "═══════════════════════════════════════════")
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
            
            // Configure NAT traversal (STUN + TURN for relay)
            val natPolicy = core?.createNatPolicy()
            natPolicy?.isStunEnabled = true
            natPolicy?.isIceEnabled = true
            natPolicy?.isTurnEnabled = false  // Disable TURN for now, focus on STUN
            natPolicy?.stunServer = "stun.l.google.com:19302"  // Use Google's STUN - more reliable
            natPolicy?.stunServerUsername = null
            natPolicy?.isUpnpEnabled = false
            
            // Apply NAT policy to core
            core?.natPolicy = natPolicy
            
            Log.i(TAG, "🌐 NAT Policy Created: STUN=${natPolicy?.isStunEnabled}, ICE=${natPolicy?.isIceEnabled}, TURN=${natPolicy?.isTurnEnabled}")
            Log.i(TAG, "🌐 STUN Server: ${natPolicy?.stunServer}")
            Log.i(TAG, "🌐 This should help incoming calls work through NAT/firewall")
            
            // Use TLS for persistent connection - this is the key!
            val transports = Factory.instance().createTransports()
            transports.udpPort = 0      // Disable UDP
            transports.tcpPort = 0      // Disable TCP
            transports.tlsPort = 5061   // Standard TLS SIP port
            core?.transports = transports
            
            Log.i(TAG, "🌐 Transport configured: UDP=0, TCP=0, TLS=5061")
            Log.i(TAG, "🌐 Using TLS for persistent encrypted connection")
            
            // CRITICAL: Enable IPv6 to help with NAT traversal
            core?.isIpv6Enabled = false // Stick to IPv4 only for simplicity
            
            // Start the core
            core?.start()
            
            // CRITICAL: Wait for STUN to discover public IP
            Log.i(TAG, "⏰ Waiting for STUN to discover public IP...")
            Thread.sleep(5000)  // Increased to 5 seconds
            
            // Check STUN configuration
            val stunServer = core?.natPolicy?.stunServer
            Log.i(TAG, "🌐 STUN server configured: $stunServer")
            Log.i(TAG, "🌐 STUN enabled: ${core?.natPolicy?.isStunEnabled}")
            Log.i(TAG, "🌐 ICE enabled: ${core?.natPolicy?.isIceEnabled}")
            
            Log.i(TAG, "⏰ STUN discovery should be complete")
            
            // Verify port is open
            val actualPort = core?.transports?.udpPort
            Log.i(TAG, "🌐 Linphone now listening on UDP port: $actualPort")
            
            if (actualPort == 0 || actualPort == -1) {
                Log.e(TAG, "❌ CRITICAL: UDP port not opened! Incoming calls will NOT work!")
            } else {
                Log.i(TAG, "✅ UDP port successfully opened for incoming calls")
            }
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
            Log.i(TAG, "═══════════════════════════════════════════")
            Log.i(TAG, "🔐 LOGIN ATTEMPT")
            Log.i(TAG, "   Username: $username")
            Log.i(TAG, "   Domain: $domain")
            Log.i(TAG, "═══════════════════════════════════════════")
            
            if (core == null) {
                Log.e(TAG, "❌ Core not initialized")
                return false
            }

            // Clear any existing auth info
            core?.clearAllAuthInfo()
            core?.clearProxyConfig()
            
            Log.d(TAG, "✅ Cleared previous auth info and proxy config")

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
            
            if (authInfo == null) {
                Log.e(TAG, "❌ Failed to create auth info")
                return false
            }
            
            core?.addAuthInfo(authInfo)
            Log.d(TAG, "✅ Auth info added for: $username@$domain")

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
            proxyConfig.serverAddr = "sip:$domain;transport=tls"  // Force TLS
            proxyConfig.isRegisterEnabled = true
            proxyConfig.isPushNotificationAllowed = true
            
            // Apply NAT policy FIRST before any other config
            proxyConfig.natPolicy = core?.natPolicy
            
            // CRITICAL FIX: Use TLS transport for persistent connection
            proxyConfig.edit()
            proxyConfig.setRoute("sip:sip.linphone.org;transport=tls")
            proxyConfig.setContactUriParameters("transport=tls")
            proxyConfig.done()
            
            Log.d(TAG, "🔧 NAT Policy applied: STUN=${core?.natPolicy?.isStunEnabled}, ICE=${core?.natPolicy?.isIceEnabled}")
            Log.d(TAG, "🔧 Route set to force server-side routing")
            
            Log.d(TAG, "✅ Proxy config created with NAT policy")
            Log.d(TAG, "✅ Contact parameters cleared to force public IP discovery")
            
            core?.addProxyConfig(proxyConfig)
            core?.defaultProxyConfig = proxyConfig
            
            Log.d(TAG, "✅ Proxy config added and set as default")

            Log.i(TAG, "═══════════════════════════════════════════")
            Log.i(TAG, "📝 LOGIN CONFIGURATION")
            Log.i(TAG, "   Identity: $username@$domain")
            Log.i(TAG, "   Server: sip:$domain")
            Log.i(TAG, "   Contact: ${proxyConfig.contact}")
            Log.i(TAG, "   NAT Policy: ${proxyConfig.natPolicy != null}")
            Log.i(TAG, "   STUN Server: ${core?.natPolicy?.stunServer}")
            Log.i(TAG, "   Registration initiated...")
            Log.i(TAG, "   Waiting for registration state callback...")
            Log.i(TAG, "═══════════════════════════════════════════")
            
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Login error: ${e.message}", e)
            return false
        }
    }
    
    fun logout(): Boolean {
        try {
            Log.i(TAG, "🚪 Logging out...")
            
            // Unregister all accounts
            val proxyConfig = core?.defaultProxyConfig
            if (proxyConfig != null) {
                proxyConfig.edit()
                proxyConfig.isRegisterEnabled = false
                proxyConfig.done()
            }
            
            // Give time for unregister to complete
            Thread.sleep(1000)
            
            // Clear all configs and auth
            core?.clearAllAuthInfo()
            core?.clearProxyConfig()
            
            Log.i(TAG, "✅ Logout complete")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Logout error: ${e.message}", e)
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
