import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("keystore.properties not found in android/")
}

android {
    namespace = "com.bidha.eduphin"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.bidha.eduphin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
}


    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
                ?: throw GradleException("storeFile missing in keystore.properties")

            keyAlias = keystoreProperties["keyAlias"]?.toString()
                ?: throw GradleException("keyAlias missing in keystore.properties")

            keyPassword = keystoreProperties["keyPassword"]?.toString()
                ?: throw GradleException("keyPassword missing in keystore.properties")

            storePassword = keystoreProperties["storePassword"]?.toString()
                ?: throw GradleException("storePassword missing in keystore.properties")

            storeFile = rootProject.file("app/$storeFilePath")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
