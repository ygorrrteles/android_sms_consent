// Copyright (c) 2021 The Khalti Authors. All rights reserved.

package com.khalti.android_sms_consent

import android.content.Context
import android.app.Activity
import android.content.*
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Status
import io.flutter.plugin.common.MethodChannel

class SMSConsentBroadcastReceiver(private val activity: Activity, private val channel: MethodChannel) : BroadcastReceiver() {
    companion object {
        const val SMS_CONSENT_REQUEST_CODE = 0x6543
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (SmsRetriever.SMS_RETRIEVED_ACTION == intent.action) {
            val extras = intent.extras
            val smsRetrieverStatus = extras?.get(SmsRetriever.EXTRA_STATUS) as Status

            when (smsRetrieverStatus.statusCode) {
                CommonStatusCodes.SUCCESS -> {
                    val consentIntent = extras.getParcelable<Intent>(SmsRetriever.EXTRA_CONSENT_INTENT)
                    try {
                        activity.startActivityForResult(consentIntent, SMS_CONSENT_REQUEST_CODE)
                    } catch (e: ActivityNotFoundException) {
                        /*no-op*/
                    }
                }
                CommonStatusCodes.TIMEOUT -> onTimeout()
            }
        }
    }

    private fun onTimeout() {
        channel.invokeMethod("onTimeout", null)
        stop()
    }

    fun start(phone: String?) {
        SmsRetriever.getClient(activity).startSmsUserConsent(phone)

        val intentFilter = IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION)
        activity.registerReceiver(this, intentFilter, SmsRetriever.SEND_PERMISSION, null, Context.RECEIVER_EXPORTED)
    }

    fun stop() {
        try {
            activity.unregisterReceiver(this)
        } catch (e: Exception) {
            /*no-op*/
        }
    }
}