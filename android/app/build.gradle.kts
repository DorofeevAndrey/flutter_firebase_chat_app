plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_firebase_chat_app"
    compileSdk = 34 // Явно указываем вместо flutter.compileSdkVersion

    // Фиксируем версию NDK для совместимости с Firebase
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Обновляем до 17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString() // Обновляем до 17
    }

    defaultConfig {
        applicationId = "com.example.flutter_firebase_chat_app"
        minSdk = 23 // Минимум 23 для Firebase Auth
        targetSdk = 34 // Актуальная версия
        versionCode = 1 // Можно брать из flutter.versionCode
        versionName = "1.0" // Можно брать из flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true // Включаем обфускацию для релиза
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Добавьте при необходимости Firebase-зависимости
    implementation(platform("com.google.firebase:firebase-bom:32.8.1"))
}