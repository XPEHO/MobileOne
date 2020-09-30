package fr.xpeho.MobileOne

import io.flutter.app.FlutterApplication
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService.setPluginRegistrant

class Application : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        setPluginRegistrant {
            FirebaseMessagingPlugin.registerWith(it.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
        }
    }

}