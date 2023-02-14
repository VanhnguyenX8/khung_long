#Flutter Wrapper
#-keep class io.flutter.app.** { *; }
#-keep class io.flutter.plugin.**  { *; }
#-keep class io.flutter.util.**  { *; }
#-keep class io.flutter.view.**  { *; }
#-keep class io.flutter.**  { *; }
#-keep class io.flutter.plugins.**  { *; }

#// You can specify any path and filename.
#-printconfiguration <your-path>/full-r8-config.txt
#-keep class net.sqlcipher.**  { *; } # sqflite_sqlcipher
#-keepattributes SourceFile,LineNumberTable        # Keep file names and line numbers.
#-keep public class * extends java.lang.Exception  # Optional: Keep custom exceptions.
