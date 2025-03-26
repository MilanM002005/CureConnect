// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    id("com.android.application") version "8.3.1" apply false
    // Removed: id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }  // Add Flutter repo
    }
    dependencies {
        // START: FlutterFire Configuration
        classpath("com.google.gms:google-services:4.3.15")
        // END: FlutterFire Configuration
        classpath("com.android.tools.build:gradle:8.3.1")
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}
