import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing with the Play upload key (plan §19.4). The values come from
// environment variables (CI, Codemagic, fastlane) or, locally, from
// android/key.properties (gitignored, like the keystore itself):
//
//   GI_UPLOAD_KEYSTORE_PATH      key.properties: storeFile
//   GI_UPLOAD_KEYSTORE_PASSWORD  key.properties: storePassword
//   GI_UPLOAD_KEY_ALIAS          key.properties: keyAlias
//   GI_UPLOAD_KEY_PASSWORD       key.properties: keyPassword
//
// An environment variable wins over key.properties. Without a complete set,
// release builds fall back to the debug key (with a warning) so local
// `flutter build appbundle` / `flutter run --release` keep working; such a
// bundle cannot be uploaded to Play. Release jobs set
// GI_REQUIRE_RELEASE_SIGNING=true, and then a missing value fails the build.
val keystoreProperties =
    Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.isFile) file.inputStream().use { load(it) }
    }

fun signingValue(env: String, property: String): String? =
    System.getenv(env)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(property)?.takeIf { it.isNotBlank() }

val uploadSigning =
    linkedMapOf(
        "GI_UPLOAD_KEYSTORE_PATH" to signingValue("GI_UPLOAD_KEYSTORE_PATH", "storeFile"),
        "GI_UPLOAD_KEYSTORE_PASSWORD" to signingValue("GI_UPLOAD_KEYSTORE_PASSWORD", "storePassword"),
        "GI_UPLOAD_KEY_ALIAS" to signingValue("GI_UPLOAD_KEY_ALIAS", "keyAlias"),
        "GI_UPLOAD_KEY_PASSWORD" to signingValue("GI_UPLOAD_KEY_PASSWORD", "keyPassword"),
    )
val uploadKeystoreFile = uploadSigning["GI_UPLOAD_KEYSTORE_PATH"]?.let { file(it) }
val missingUploadSigning =
    uploadSigning.filterValues { it == null }.keys.toMutableList().apply {
        if (uploadKeystoreFile != null && !uploadKeystoreFile.isFile) {
            add("GI_UPLOAD_KEYSTORE_PATH (no file at $uploadKeystoreFile)")
        }
    }
val hasUploadKey = missingUploadSigning.isEmpty()
val requireReleaseSigning = System.getenv("GI_REQUIRE_RELEASE_SIGNING") == "true"

if (requireReleaseSigning && !hasUploadKey) {
    throw GradleException(
        "GI_REQUIRE_RELEASE_SIGNING=true but the release upload key is incomplete. " +
            "Missing: ${missingUploadSigning.joinToString()}. Set these environment " +
            "variables (CI secrets, see README \"CI/CD\") or android/key.properties.",
    )
}

android {
    namespace = "pl.gihome.gi_home"
    // Plan §0 and §9.4: compile and target API 36, set explicitly so a
    // Flutter upgrade cannot move them.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Base ID only: the final bundle IDs per flavor wait for the owner's
        // decision (plan §23, D5). Flavors add a suffix so all three can be
        // installed side by side.
        applicationId = "pl.gihome.gi_home"
        // Android 8.0+ (plan §23, D13).
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // The flavors' launcher labels (@string/app_name) are resValues, which
    // the Android Gradle plugin no longer enables by default.
    buildFeatures {
        resValues = true
    }

    // Plan §19.2. Each flavor is paired with lib/main_<flavor>.dart (prod:
    // lib/main.dart) and config/<flavor>.json via --dart-define-from-file.
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "GI Home Dev")
        }
        create("beta") {
            dimension = "env"
            applicationIdSuffix = ".beta"
            resValue("string", "app_name", "GI Home Beta")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "GI Home")
        }
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                storeFile = uploadKeystoreFile
                storePassword = uploadSigning["GI_UPLOAD_KEYSTORE_PASSWORD"]
                keyAlias = uploadSigning["GI_UPLOAD_KEY_ALIAS"]
                keyPassword = uploadSigning["GI_UPLOAD_KEY_PASSWORD"]
            }
        }
    }

    buildTypes {
        release {
            // The upload key when configured, else the debug key for local
            // builds only (see the top of this file).
            signingConfig =
                if (hasUploadKey) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
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

if (!hasUploadKey) {
    // Only when a release artifact is part of the build (also when its tasks
    // are up to date), not on every Gradle run. `quiet`, because Flutter runs
    // Gradle with -q and would hide a plain warning.
    val missing = missingUploadSigning.joinToString()
    val releasePackaging = Regex("""package\w+Release|sign\w+ReleaseBundle""")
    gradle.taskGraph.whenReady {
        if (allTasks.any { it.project == project && releasePackaging.matches(it.name) }) {
            logger.quiet(
                "WARNING: release build signed with the DEBUG key (missing: $missing). " +
                    "Fine for local testing; Play rejects it. See plan §19.4 and " +
                    "README \"CI/CD\".",
            )
        }
    }
}
