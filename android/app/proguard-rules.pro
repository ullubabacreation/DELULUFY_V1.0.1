# Flutter & audio player safe rules
-keep class io.flutter.** { *; }
-keep class com.delusion.** { *; }
-keep class com.google.** { *; }
-keep class androidx.** { *; }

# Keep audio playback functionality
-keep class com.google.android.exoplayer2.** { *; }

# Prevent removal of anything related to reflection (for plugins)
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-dontwarn com.google.**
