plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "top.beijiu.replaceme"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "top.beijiu.replaceme"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 配置支持的架构
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    // 签名配置
    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEY_ALIAS") ?: "default"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "password"
            storePassword = System.getenv("STORE_PASSWORD") ?: "password"
            if (System.getenv("SIGNING_KEY") != null) {
                val keystoreFile = File("${project.buildDir}/keystore.jks")
                keystoreFile.parentFile?.mkdirs()
                keystoreFile.writeBytes(Base64.getDecoder().decode(System.getenv("SIGNING_KEY")))
                storeFile = keystoreFile
            }
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
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // 使用 split APK，为不同架构生成不同的 APK
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a")
            isUniversalApk = true // 同时生成全架构的 APK
        }
    }
}

flutter {
    source = "../.."
}