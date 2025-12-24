# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# React Native rules
-keep class com.facebook.react.** { *; }
-dontwarn com.facebook.react.**

# Hermes engine rules
-keep class com.facebook.hermes.** { *; }
-dontwarn com.facebook.hermes.**

# JavaScriptCore rules
-keep class com.facebook.javascriptcore.** { *; }
-dontwarn com.facebook.javascriptcore.**

# OkHttp rules
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Okio rules
-keep class okio.** { *; }
-dontwarn okio.**

# Flipper rules (if used)
# -keep class com.facebook.flipper.** { *; }
# -dontwarn com.facebook.flipper.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that implement ReactPackage
-keep class * implements com.facebook.react.ReactPackage {
    *;
}

# Keep all MainActivity classes
-keepclassmembers class * extends com.facebook.react.ReactActivity {
    public void onConfigurationChanged(android.content.res.Configuration);
}

# Keep all ViewManager classes
-keepclassmembers class * extends com.facebook.react.uimanager.ViewManager {
    public <init>(com.facebook.react.bridge.ReactApplicationContext);
}

# Keep all Module classes
-keepclassmembers class * extends com.facebook.react.bridge.BaseJavaModule {
    public <init>(com.facebook.react.bridge.ReactApplicationContext);
}

# Keep all ReactContextBaseJavaModule classes
-keepclassmembers class * extends com.facebook.react.bridge.ReactContextBaseJavaModule {
    <init>(...);
}

# Keep all classes annotated with @ReactMethod
-keepclassmembers class * {
    @com.facebook.react.bridge.ReactMethod <methods>;
}

# Keep all JavaScript modules
-keepclassmembers class * {
    native <methods>;
}

# Keep all enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep all parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep all Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep all classes with @ReactProp annotation
-keepclassmembers class * {
    @com.facebook.react.uimanager.annotations.ReactProp <methods>;
    @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>;
}

# Keep all classes with @ReactModule annotation
-keepclassmembers class * {
    @com.facebook.react.bridge.ReactModule <fields>;
}
