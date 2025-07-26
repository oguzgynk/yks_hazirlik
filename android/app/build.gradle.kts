// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// local.properties dosyasından değerleri okuma
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

// key.properties dosyasından değerleri okuma
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { input ->
        keystoreProperties.load(input)
    }
}

val flutterVersionCode: String = localProperties.getProperty("flutter.versionCode") ?: "2"
val flutterVersionName: String = localProperties.getProperty("flutter.versionName") ?: "1.0.1"

android {
    namespace = "com.yks.hazirlik.app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.yks.hazirlik.app"
        minSdk = 21
        targetSdk = 35
        multiDexEnabled = true
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName

        resourceConfigurations.addAll(listOf("tr", "en"))
        vectorDrawables.useSupportLibrary = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets.getByName("main").java.srcDirs("src/main/kotlin")

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
        getByName("profile") {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }

    lint {
        disable.add("InvalidPackage")
        checkReleaseBuilds = false
        abortOnError = false
    }

    // dexOptions yerine bu kullanılıyor
    androidComponents {
        onVariants { variant ->
            variant.packaging.jniLibs.pickFirsts.addAll(
                listOf("**/libc++_shared.so", "**/libjsc.so")
            )
        }
    }
}

flutter {
    source = "../../"
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")
    
    // Google Play Core - Güncellenmiş versiyon
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:app-update-ktx:2.1.0")
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.play:feature-delivery-ktx:2.1.0")

    // Google Play Services
    implementation("com.google.android.gms:play-services-ads:22.6.0")
    implementation("com.android.billingclient:billing:6.1.0")

    // AndroidX
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    implementation("androidx.multidex:multidex:2.0.1")

    // Material Design
    implementation("com.google.android.material:material:1.11.0")

    // Network
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // Image loading
    implementation("com.github.bumptech.glide:glide:4.16.0")
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}