# Flutter release R8 rules.
# R8 tree-shakes and minifies the release build; these rules keep the
# Flutter engine, embedding and plugin classes that are loaded reflectively.

# Keep the Flutter embedding and engine.
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Keep all plugin registrants and their packages.
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep local_auth and other plugins that may be invoked via reflection.
-keep class io.flutter.plugins.localauth.** { *; }

# Keep generic signatures and annotation metadata.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Strip verbose logging from the release build.
-assumenosideeffects class android.util.Log {
    public static int d(...);
    public static int v(...);
}
