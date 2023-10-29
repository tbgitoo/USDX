package com.android.gl2jni;

public class SDLJNILib extends GL2JNILib {
    public static native void onNativeKeyboardFocusLost();
    public static native void nativeSetNaturalOrientation(int orientation);

    public static native void onNativeRotationChanged(int rotation);

    public static native void onNativeMouse(int button, int action, float x, float y, boolean relative);

}
