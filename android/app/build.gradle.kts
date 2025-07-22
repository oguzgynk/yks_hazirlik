// android/app/build.gradle.kts
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Kotlin Android plugin'i
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle plugin'i
}

// local.properties dosyasından değerleri okuma
// Bu kısım genellikle projenin ana build.gradle.kts dosyasında (android/build.gradle.kts) olur,
// ancak Flutter'ın app/build.gradle.kts içinde de çalışması için burada tanımlanmıştır.
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

val flutterVersionCode: String = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName: String = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    // Uygulamanızın benzersiz paket adı
    namespace = "com.yks.hazirlik.app" // <<<<< DOĞRU. Bu, AndroidManifest'teki package ile eşleşmeli.
    compileSdk = 35 // SDK 35'e yükseltiyoruz - DOĞRU.
    ndkVersion = "27.0.12077973" // Flutter'ın kullandığı NDK versiyonu - DOĞRU.

    defaultConfig {
        // Uygulamanızın kimliği
        applicationId = "com.yks.hazirlik.app" // <<<<< DOĞRU. Bu da AndroidManifest'teki package ile eşleşmeli.
        minSdk = 21 // Minimum desteklenen Android SDK versiyonu - DOĞRU.
        targetSdk = 34 // Hedeflenen Android SDK versiyonu - GÜNCELLEME TAVSİYESİ: compileSdk ile aynı (35) yapabilirsiniz. Hata değil, uyarıları azaltır.
        multiDexEnabled = true // DOĞRU. Multidex etkinleştirilmiş.
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName

        // Çoklu dil desteği (eğer kullanılıyorsa)
        resourceConfigurations.addAll(listOf("tr", "en")) // DOĞRU.

        // Vector drawable desteği
        vectorDrawables.useSupportLibrary = true // DOĞRU.

        // Manifest placeholders (eğer kullanılıyorsa, AdMob gibi)
        // BURASI ÇOK ÖNEMLİ!
        // AndroidManifest.xml'den 'android:name' özelliğini kaldırdığımız için,
        // bu 'applicationName' placeholder'ları artık doğrudan bir etkiye sahip değil.
        // Eğer 'YKSApp' veya 'YKSAppDebug' adında özel bir Application sınıfı OLUŞTURMADIYSANIZ,
        // bu placeholder'lar kafa karışıklığına yol açabilir ve önceki ClassNotFoundException'a katkıda bulunmuş olabilir.
        // Güvenli tarafta kalmak için bu satırı yorum satırı yapmanızı veya kaldırmanızı ÖNERİRİM.
        // Eğer özel bir Application sınıfınız varsa, bu satır kalmalı ve o sınıfın doğru olduğundan emin olmalıyız.
        // Şimdilik, varsayılan Flutter davranışına güvenmek için YORUM SATIRI yapalım.
        // manifestPlaceholders["applicationName"] = "@string/app_name"
    }

    // Java/Kotlin uyumluluk ayarları
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true // DOĞRU. Desugaring etkinleştirilmiş.
    }

    kotlinOptions {
        jvmTarget = "1.8" // DOĞRU.
    }

    // Kaynak dizinleri (Kotlin için)
    sourceSets.getByName("main").java.srcDirs("src/main/kotlin") // DOĞRU. Kotlin kaynaklarını belirtir.

    // İmzalama yapılandırmaları (Uygulamanızı yayınlarken önemlidir)
    signingConfigs {
        create("release") {
            keyAlias = localProperties.getProperty("keyAlias") ?: "yks-key"
            keyPassword = localProperties.getProperty("keyPassword") ?: "yks123456"
            storeFile = localProperties.getProperty("storeFile")?.let { file(it) } ?: null
            storePassword = localProperties.getProperty("storePassword") ?: "yks123456"
        }
    }

    // Derleme tipleri (debug, release, profile)
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
            // BURASI ÇOK ÖNEMLİ!
            // Aynı şekilde, eğer 'YKSApp' adında özel bir Application sınıfı OLUŞTURMADIYSANIZ,
            // bu satırı yorum satırı yapın veya kaldırın.
            // manifestPlaceholders["applicationName"] = "YKSApp"
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            // BURASI ÇOK ÖNEMLİ!
            // Aynı şekilde, eğer 'YKSAppDebug' adında özel bir Application sınıfı OLUŞTURMADIYSANIZ,
            // bu satırı yorum satırı yapın veya kaldırın.
            // manifestPlaceholders["applicationName"] = "YKSAppDebug"
        }
        getByName("profile") { // DOĞRU.
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

    // App Bundle konfigürasyonu
    bundle {
        language {
            enableSplit = false // DOĞRU.
        }
        density {
            enableSplit = true // DOĞRU.
        }
        abi {
            enableSplit = true // DOĞRU.
        }
    }

    // Lint ayarları
    lint {
        disable.add("InvalidPackage")
        checkReleaseBuilds = false
        abortOnError = false
    }

    // Dex ayarları
    dexOptions {
        javaMaxHeapSize = "4g" // DOĞRU. Bellek sorunları için iyi bir ayar.
    }

    // Paketleme ayarları
    packagingOptions {
        pickFirsts += listOf("**/libc++_shared.so", "**/libjsc.so") // DOĞRU.
    }
}

// Flutter uzantısı (kaynak kodu yolu)
flutter {
    source = "../../"// DOĞRU. Bu, Flutter projesinin kök dizinini gösterir.
}

// Uygulama bağımlılıkları
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7") // DOĞRU.

    // Google Play Services (örneğin AdMob için)
    implementation("com.google.android.gms:play-services-ads:22.6.0") // DOĞRU.
    implementation("com.android.billingclient:billing:6.1.0") // DOĞRU.

    // Firebase (eğer kullanıyorsanız, yorum satırlarını kaldırın ve versiyonları kontrol edin)
    // implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    // implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-messaging")

    // AndroidX desteği
    implementation("androidx.core:core-ktx:1.12.0") // DOĞRU.
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0") // DOĞRU.
    implementation("androidx.work:work-runtime-ktx:2.9.0") // DOĞRU.
    implementation("androidx.multidex:multidex:2.0.1") // DOĞRU. Multidex bağımlılığı eklenmiş.

    // Material Design
    implementation("com.google.android.material:material:1.11.0") // DOĞRU.

    // Network
    implementation("com.squareup.okhttp3:okhttp:4.12.0") // DOĞRU.

    // Image loading
    implementation("com.github.bumptech.glide:glide:4.16.0") // DOĞRU.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // DOĞRU. Desugaring kütüphanesi eklenmiş.
}