plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.mindcare_app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.mindcare_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Java 17 kullan
        targetCompatibility = JavaVersion.VERSION_17  // Java 17 kullan
    }

    kotlinOptions {
        jvmTarget = "17"  // Kotlin için Java 17
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:32.8.1"))  // Sürümü düşürdüm
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}