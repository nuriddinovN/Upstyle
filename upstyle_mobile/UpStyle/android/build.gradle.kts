buildscript {
    val kotlin_version by extra("2.2.0")

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.google.gms:google-services:4.3.14")
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${name}")
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

