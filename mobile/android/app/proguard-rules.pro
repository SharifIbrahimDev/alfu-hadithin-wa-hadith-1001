# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Flutter and plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Play Store split / deferred components
-dontwarn com.google.android.play.core.**

# Serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
