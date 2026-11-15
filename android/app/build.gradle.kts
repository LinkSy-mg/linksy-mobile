import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Release signing comes from android/key.properties (never committed).
val keyProps = Properties()
val keyPropsFile = rootProject.file("key.properties")
val hasReleaseKey = keyPropsFile.exists()
if (hasReleaseKey) keyPropsFile.inputStream().use { keyProps.load(it) }

android {
    namespace = "app.linksy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "app.linksy.mg"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasReleaseKey) {
        signingConfigs.create("release") {
            storeFile = file(keyProps.getProperty("storeFile"))
            storePassword = keyProps.getProperty("storePassword")
            keyAlias = keyProps.getProperty("keyAlias")
            keyPassword = keyProps.getProperty("keyPassword")
            // v1 + v2 + v3 so every sideload installer accepts the file.
            enableV1Signing = true
            enableV2Signing = true
            enableV3Signing = true
        }
    }

    packaging {
        // Compress native libraries inside the APK: sideloaded builds care
        // more about download size than install time.
        jniLibs { useLegacyPackaging = true }
    }

    buildTypes {
        release {
            // No fallback to the debug key: a release APK signed with it
            // would be installable (and updatable) by anyone with that key.
            // The guard below fails the build when the release key is missing.
            if (hasReleaseKey) signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

// Refuse to package a release without the release key, instead of silently
// signing it with the debug key. Debug builds and tests are unaffected.
gradle.taskGraph.whenReady {
    val packaging = allTasks.any {
        it.project == project && (it.name == "packageRelease" || it.name == "packageReleaseBundle")
    }
    if (packaging) {
        val missing = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
            .filter { keyProps.getProperty(it).isNullOrBlank() }
        if (!hasReleaseKey || missing.isNotEmpty() || !file(keyProps.getProperty("storeFile")).exists()) {
            throw GradleException(
                "Release build needs the release keystore: create android/key.properties with " +
                    "storeFile, storePassword, keyAlias and keyPassword (see tool/release.sh). " +
                    "Refusing to sign a release with the debug key.",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Decodes the pairing QR code on the phone (no Google services).
    implementation("com.google.zxing:core:3.5.3")
    // Push notifications (Firebase Cloud Messaging), wired natively: no
    // Flutter plugin, no analytics.
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
    implementation("com.google.firebase:firebase-messaging")

    testImplementation("junit:junit:4.13.2")
}
