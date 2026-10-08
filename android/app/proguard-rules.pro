# google_mlkit_text_recognition ships optional per-script recognizer classes
# (Chinese/Devanagari/Japanese/Korean) that aren't referenced directly from
# Dart-generated code, so R8 can't see them and fails with "missing classes".
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }
