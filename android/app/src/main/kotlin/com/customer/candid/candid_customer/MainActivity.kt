package com.customer.candid.candid_customer

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle
import android.util.Log
import com.google.firebase.FirebaseApp
//import com.google.firebase.appcheck.FirebaseAppCheck
//import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
//import com.google.firebase.appcheck.ktx.appCheck
import com.google.firebase.ktx.Firebase
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger

class MainActivity : FlutterFragmentActivity() {
    //    private val APP_CHECK = "com.customer.candid.candid_customer/appCheck"
//    private lateinit var channel: MethodChannel
//    private lateinit var firebaseAppCheck: FirebaseAppCheck;
    override fun onCreate(savedInstanceState: Bundle?) {
        Log.e("MainActivity", "onCreate")
        FirebaseApp.initializeApp(/*context=*/this)
//        firebaseAppCheck = Firebase.appCheck;
////        firebaseAppCheck.installAppCheckProviderFactory(
////            PlayIntegrityAppCheckProviderFactory.getInstance()
////        )
//        firebaseAppCheck.installAppCheckProviderFactory(
//            PlayIntegrityAppCheckProviderFactory.getInstance(),
//        )
        super.onCreate(savedInstanceState)
    }

//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_CHECK);
//        channel.setMethodCallHandler { call, result ->
//            if (call.method.equals("getAppCheckToken")) {
//                firebaseAppCheck.limitedUseAppCheckToken.addOnSuccessListener { appCheckToken ->
//                    result.success(appCheckToken.token);
//                }.addOnFailureListener { err ->
//                    result.error("1", err.localizedMessage, err)
//                }
//            } else {
//                result.notImplemented();
//            }
//        }
//    }
}
