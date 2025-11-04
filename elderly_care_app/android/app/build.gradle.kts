plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // ✅ Use the latest NDK version (from plugin requirements)
    ndkVersion = "27.0.12077973"
    namespace = "com.example.elderly_care_app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.elderly_care_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Enable Java 17 and core library desugaring
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
    getByName("release") {
        isMinifyEnabled = false
        isShrinkResources = false
        signingConfig = signingConfigs.getByName("debug")
    }
}



    // ✅ Optional: custom APK naming
    applicationVariants.all {
        outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            output.outputFileName = "elderly-care-app-${versionName}-${buildType.name}.apk"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
