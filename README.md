# barcode_ml_scanner

Scanner for barcode and QR code with Google ML Kit

## Get started

In build.gradle set:

```aidl
compileSdkVersion 21
```

## WARNING

Not production ready

## Optimize apk size

Without optimization, the fash apk file will weigh about 160MB. If we apply the optimizations described below, then about 50MB

In android/app/build.gradle in sections android.buildTypes.release and android.buildTypes.release add this:

```aidl
            aaptOptions {
                ignoreAssetsPattern '!mlkit_pose:!mlkit_label_default_model:'
            }
```

Then, in section android add this:

```aidl
    packagingOptions {
        exclude 'lib/**/libtranslate_jni.so'
        exclude 'lib/**/libdigitalink.so'
        exclude 'lib/**/libxeno_native.so'
        exclude 'lib/**/libmlkitcommonpipeline.so'
    //  exclude 'lib/**/libbarhopper_v2.so' → required for barcode detection
        exclude 'lib/**/libclassifier_jni.so'
        exclude 'lib/**/libface_detector_v2_jni.so'
        exclude 'lib/**/libtensorflowlite_jni.so'
        exclude 'lib/**/liblanguage_id_jni.so'
    }
```

For example:

```aidl
android {
    compileSdkVersion 30

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.awcoding.barcode_ml_scanner_example"
        minSdkVersion 21
        targetSdkVersion 30
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            aaptOptions {
                ignoreAssetsPattern '!mlkit_pose:!mlkit_label_default_model:'
            }
        }
        debug {
            signingConfig signingConfigs.debug
            aaptOptions {
                ignoreAssetsPattern '!mlkit_pose:!mlkit_label_default_model:'
            }
        }
    }

    packagingOptions {
        exclude 'lib/**/libtranslate_jni.so'
        exclude 'lib/**/libdigitalink.so'
        exclude 'lib/**/libxeno_native.so'
        exclude 'lib/**/libmlkitcommonpipeline.so'
//        exclude 'lib/**/libbarhopper_v2.so' → required for barcode detection
        exclude 'lib/**/libclassifier_jni.so'
        exclude 'lib/**/libface_detector_v2_jni.so'
        exclude 'lib/**/libtensorflowlite_jni.so'
        exclude 'lib/**/liblanguage_id_jni.so'
    }
}
```
