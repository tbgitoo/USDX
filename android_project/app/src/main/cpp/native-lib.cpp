#include <jni.h>
#include <usdx.h>


extern "C" JNIEXPORT jfloat JNICALL
Java_com_tbgitoo_ultrastardx_1android_MainActivity_numberFromJNI(
        JNIEnv* env,
        jobject /* this */) {

    return fuunc4C();
}