# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.**

# Firebase
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }

# JNI
-keep class com.sun.jna.** { *; }
-dontwarn com.sun.jna.**

# General
-dontwarn javax.annotation.**
-dontwarn javax.inject.**
-dontwarn sun.misc.Unsafe
