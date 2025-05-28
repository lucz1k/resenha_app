# Flutter e Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.example.resenha_app.** { *; }

# Permitir a depuração (opcional)
-dontwarn io.flutter.embedding.**

# Garante que classes com anotações específicas não sejam minificadas
-keepattributes *Annotation*

# Impede a remoção de classes usadas via reflexão
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclassmembers class * {
    public <init>(android.content.Context);
}

# Evita warnings comuns
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn sun.misc.**
-dontwarn java.lang.invoke.*

# Para speech_to_text e possíveis libs nativas
-dontwarn com.google.**

# SharedPreferences / HTTP / Dotenv geralmente não precisam regras extras
