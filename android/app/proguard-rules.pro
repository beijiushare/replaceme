# Flutter 基本配置
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 忽略缺失的 Google Play Core 库类
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
