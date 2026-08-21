allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Enforce Java 17 target for Kotlin and Java compilation globally
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")

    // FORCE the downgrade across ALL subprojects and plugins globally
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.15.0")
            force("androidx.core:core-ktx:1.15.0")
            force("androidx.browser:browser:1.8.0")
        }
    }
}

tasks.register<Delete>("clean") {
    description = "Deletes the build directory"
    delete(rootProject.layout.buildDirectory)
}