-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
  public void onPayment*(...);
}
## Firebase
#-keep class com.google.firebase.** { *; }
#-keep class com.google.android.gms.** { *; }
#-dontwarn com.google.firebase.**
# Firebase Auth

-keep class com.google.firebase.auth.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
# Play Integrity API
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.integrity.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.api.** { *; }
-keepattributes Signature
-keepattributes *Annotation*