# Odalisque v0.13.0 Production Security - ProGuard Rules

## Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Gson/JSON parsing
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.examples.android.model.** { <fields>; }

## HTTP and networking
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Preserve line numbers for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

## Security: Remove logging in production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

## flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

## Preserve BuildConfig
-keep class **.BuildConfig { *; }

## Keep MainActivity
-keep class **.MainActivity { *; }

## Crypto and security classes
-keep class javax.crypto.** { *; }
-keep class javax.security.** { *; }
-keep class java.security.** { *; }
-dontwarn javax.crypto.**
-dontwarn javax.security.**
-dontwarn java.security.**

## Keep classes used via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

## Optimization settings for security
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

## Additional obfuscation for security
-repackageclasses ''
-allowaccessmodification

## Keep crash reporting classes
-keepattributes *Annotation*
-keep public class * extends java.lang.Exception
