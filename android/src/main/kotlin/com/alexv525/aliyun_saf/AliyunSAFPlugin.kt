package com.alexv525.aliyun_saf

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.security.device.api.SecurityCode
import net.security.device.api.SecurityDevice

class AliyunSAFPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    private val validContext: Context
        get() = context!!

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull rawResult: Result) {
        val result: Result = MethodResultWrapper(rawResult)
        when (call.method) {
            "init" -> init(call.argument<String>("appKey")!!, result)
            "getSession" -> getSession(result)
            else -> result.notImplemented()
        }
    }

    private fun init(key: String, result: Result) {
        SecurityDevice.getInstance().init(validContext, key, null)
        result.success(null)
    }

    private fun getSession(result: Result) {
        object : Thread() {
            override fun run() {
                val securitySession = SecurityDevice.getInstance().session
                if (null != securitySession) {
                    if (SecurityCode.SC_SUCCESS == securitySession.code) {
                        result.success(securitySession.session)
                    } else {
                        result.error(securitySession.code.toString(), "Session fetch error.", null)
                    }
                } else {
                    result.error("0", "Session is null.", null)
                }
            }
        }.start()
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.alexv525.com/aliyun_saf")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        channel.setMethodCallHandler(null)
    }
}
