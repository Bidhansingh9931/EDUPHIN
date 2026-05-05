rootProject.name = "eduphin"

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val path = properties.getProperty("flutter.sdk")
            require(path != null) { "flutter.sdk not set in local.properties" }
            path.trim().replace("\\", "/")
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader")
    id("com.android.application") version "8.9.1" apply false
    id("com.android.library") version "8.9.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.10.0"
}

include(":app")
