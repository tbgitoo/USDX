package org.libsdl.app;

import static android.content.Context.UI_MODE_SERVICE;

import static com.android.gl2jni.SDL_GL2JNI_Activity.COMMAND_CHANGE_TITLE;
import static com.android.gl2jni.SDL_GL2JNI_Activity.COMMAND_CHANGE_WINDOW_STYLE;

import android.app.Activity;
import android.app.UiModeManager;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.text.Editable;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.InputDevice;
import android.view.KeyEvent;
import android.view.PointerIcon;
import android.view.Surface;
import android.view.View;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.Toast;


import com.android.gl2jni.SDLJNILib;
import com.android.gl2jni.SDLSurface;
import com.android.gl2jni.SDL_GL2JNI_Activity;

import java.util.Hashtable;

public class SDLActivity {

    static {
        System.loadLibrary("test");
        System.loadLibrary("SDL3");
    }

    private static final String TAG = "SDLActivity";
    private static final int SDL_MAJOR_VERSION = 3;
    private static final int SDL_MINOR_VERSION = 0;
    private static final int SDL_MICRO_VERSION = 0;

    private static final int SDL_SYSTEM_CURSOR_ARROW = 0;
    private static final int SDL_SYSTEM_CURSOR_IBEAM = 1;
    private static final int SDL_SYSTEM_CURSOR_WAIT = 2;
    private static final int SDL_SYSTEM_CURSOR_CROSSHAIR = 3;
    private static final int SDL_SYSTEM_CURSOR_WAITARROW = 4;
    private static final int SDL_SYSTEM_CURSOR_SIZENWSE = 5;
    private static final int SDL_SYSTEM_CURSOR_SIZENESW = 6;
    private static final int SDL_SYSTEM_CURSOR_SIZEWE = 7;
    private static final int SDL_SYSTEM_CURSOR_SIZENS = 8;
    private static final int SDL_SYSTEM_CURSOR_SIZEALL = 9;
    private static final int SDL_SYSTEM_CURSOR_NO = 10;
    private static final int SDL_SYSTEM_CURSOR_HAND = 11;

    public static final int SDL_ORIENTATION_UNKNOWN = 0;
    public static final int SDL_ORIENTATION_LANDSCAPE = 1;
    public static final int SDL_ORIENTATION_LANDSCAPE_FLIPPED = 2;
    public static final int SDL_ORIENTATION_PORTRAIT = 3;
    public static final int SDL_ORIENTATION_PORTRAIT_FLIPPED = 4;

    public static int mCurrentRotation;

    public static boolean mIsResumedCalled, mHasFocus;

    protected static SDLClipboardHandler mClipboardHandler;


    // C functions we call
    public static native String nativeGetVersion();
    public static native int nativeSetupJNI();
    public static native int nativeRunMain(String library, String function, Object arguments);
    public static native void nativeLowMemory();
    public static native void nativeSendQuit();
    public static native void nativeQuit();
    public static native void nativePause();
    public static native void nativeResume();
    public static native void nativeFocusChanged(boolean hasFocus);
    public static native void onNativeDropFile(String filename);
    public static native void nativeSetScreenResolution(int surfaceWidth, int surfaceHeight, int deviceWidth, int deviceHeight, float density, float rate);
    public static native void onNativeResize();
    public static native void onNativeKeyDown(int keycode);
    public static native void onNativeKeyUp(int keycode);
    public static native boolean onNativeSoftReturnKey();
    public static native void onNativeKeyboardFocusLost();
    public static native void onNativeMouse(int button, int action, float x, float y, boolean relative);
    public static native void onNativeTouch(int touchDevId, int pointerFingerId,
                                            int action, float x,
                                            float y, float p);
    public static native void onNativeAccel(float x, float y, float z);
    public static native void onNativeClipboardChanged();
    public static native void onNativeSurfaceCreated();
    public static native void onNativeSurfaceChanged();
    public static native void onNativeSurfaceDestroyed();
    public static native String nativeGetHint(String name);
    public static native boolean nativeGetHintBoolean(String name, boolean default_value);
    public static native void nativeSetenv(String name, String value);
    public static native void nativeSetNaturalOrientation(int orientation);
    public static native void onNativeRotationChanged(int rotation);
    public static native void nativeAddTouch(int touchId, String name);
    public static native void nativePermissionResult(int requestCode, boolean result);
    public static native void onNativeLocaleChanged();
    public static native void onNativeDarkModeChanged(boolean enabled);
    public static native boolean nativeAllowRecreateActivity();
    public static native int nativeCheckSDLThreadCounter();

    public static SDL_GL2JNI_Activity mSingleton;

    public static DummyEdit mTextEdit;

    public static SDLSurface mView;

    public static Hashtable<Integer, PointerIcon> mCursors;
    public static int mLastCursorID;

    public static boolean mScreenKeyboardShown;

    public static Context getContext() {
        return mSingleton;
    }

    public static boolean isDeXMode() {
        if (Build.VERSION.SDK_INT < 24 /* Android 7.0 (N) */) {
            return false;
        }
        try {
            final Configuration config = getContext().getResources().getConfiguration();
            final Class<?> configClass = config.getClass();
            return configClass.getField("SEM_DESKTOP_MODE_ENABLED").getInt(configClass)
                    == configClass.getField("semDesktopModeEnabled").getInt(config);
        } catch(Exception ignored) {
            return false;
        }
    }

    public static SDLSurface getContentView() {
return mView;
    }

    public static void setContentView(SDLSurface theView) {
        mView=theView;
    }

    // Handle the state of the native layer
    public enum NativeState {
        INIT, RESUMED, PAUSED
    }

    public static SDLActivity.NativeState mNextNativeState;
    public static SDLActivity.NativeState mCurrentNativeState;

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean clipboardHasText() {
        return mClipboardHandler.clipboardHasText();
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static String clipboardGetText() {
        return mClipboardHandler.clipboardGetText();
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static void clipboardSetText(String string) {
        mClipboardHandler.clipboardSetText(string);
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static int createCustomCursor(int[] colors, int width, int height, int hotSpotX, int hotSpotY) {
        Bitmap bitmap = Bitmap.createBitmap(colors, width, height, Bitmap.Config.ARGB_8888);
        ++mLastCursorID;

        if (Build.VERSION.SDK_INT >= 24 /* Android 7.0 (N) */) {
            try {
                mCursors.put(mLastCursorID, PointerIcon.create(bitmap, hotSpotX, hotSpotY));
            } catch (Exception e) {
                return 0;
            }
        } else {
            return 0;
        }
        return mLastCursorID;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static void destroyCustomCursor(int cursorID) {
        if (Build.VERSION.SDK_INT >= 24 /* Android 7.0 (N) */) {
            try {
                mCursors.remove(cursorID);
            } catch (Exception e) {
            }
        }
        return;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean setCustomCursor(int cursorID) {

        if (Build.VERSION.SDK_INT >= 24 /* Android 7.0 (N) */) {
            try {
                getContentView().setPointerIcon(mCursors.get(cursorID));
            } catch (Exception e) {
                return false;
            }
        } else {
            return false;
        }
        return true;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean setSystemCursor(int cursorID) {
        int cursor_type = 0; //PointerIcon.TYPE_NULL;
        switch (cursorID) {
            case SDL_SYSTEM_CURSOR_ARROW:
                cursor_type = 1000; //PointerIcon.TYPE_ARROW;
                break;
            case SDL_SYSTEM_CURSOR_IBEAM:
                cursor_type = 1008; //PointerIcon.TYPE_TEXT;
                break;
            case SDL_SYSTEM_CURSOR_WAIT:
                cursor_type = 1004; //PointerIcon.TYPE_WAIT;
                break;
            case SDL_SYSTEM_CURSOR_CROSSHAIR:
                cursor_type = 1007; //PointerIcon.TYPE_CROSSHAIR;
                break;
            case SDL_SYSTEM_CURSOR_WAITARROW:
                cursor_type = 1004; //PointerIcon.TYPE_WAIT;
                break;
            case SDL_SYSTEM_CURSOR_SIZENWSE:
                cursor_type = 1017; //PointerIcon.TYPE_TOP_LEFT_DIAGONAL_DOUBLE_ARROW;
                break;
            case SDL_SYSTEM_CURSOR_SIZENESW:
                cursor_type = 1016; //PointerIcon.TYPE_TOP_RIGHT_DIAGONAL_DOUBLE_ARROW;
                break;
            case SDL_SYSTEM_CURSOR_SIZEWE:
                cursor_type = 1014; //PointerIcon.TYPE_HORIZONTAL_DOUBLE_ARROW;
                break;
            case SDL_SYSTEM_CURSOR_SIZENS:
                cursor_type = 1015; //PointerIcon.TYPE_VERTICAL_DOUBLE_ARROW;
                break;
            case SDL_SYSTEM_CURSOR_SIZEALL:
                cursor_type = 1020; //PointerIcon.TYPE_GRAB;
                break;
            case SDL_SYSTEM_CURSOR_NO:
                cursor_type = 1012; //PointerIcon.TYPE_NO_DROP;
                break;
            case SDL_SYSTEM_CURSOR_HAND:
                cursor_type = 1002; //PointerIcon.TYPE_HAND;
                break;
        }
        if (Build.VERSION.SDK_INT >= 24 /* Android 7.0 (N) */) {
            try {
                getContentView().setPointerIcon(PointerIcon.getSystemIcon(getContext(), cursor_type));
            } catch (Exception e) {
                return false;
            }
        }
        return true;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static void requestPermission(String permission, int requestCode) {
        if (Build.VERSION.SDK_INT < 23 /* Android 6.0 (M) */) {
            nativePermissionResult(requestCode, true);
            return;
        }

        Activity activity = (Activity)getContext();
        if (activity.checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
            activity.requestPermissions(new String[]{permission}, requestCode);
        } else {
            nativePermissionResult(requestCode, true);
        }
    }


    /**
     * This method is called by SDL using JNI.
     */
    public static int openURL(String url)
    {
        try {
            Intent i = new Intent(Intent.ACTION_VIEW);
            i.setData(Uri.parse(url));

            int flags = Intent.FLAG_ACTIVITY_NO_HISTORY | Intent.FLAG_ACTIVITY_MULTIPLE_TASK;
            if (Build.VERSION.SDK_INT >= 21 /* Android 5.0 (LOLLIPOP) */) {
                flags |= Intent.FLAG_ACTIVITY_NEW_DOCUMENT;
            } else {
                flags |= Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET;
            }
            i.addFlags(flags);

            mSingleton.startActivity(i);
        } catch (Exception ex) {
            return -1;
        }
        return 0;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static int showToast(String message, int duration, int gravity, int xOffset, int yOffset)
    {
        if(null == mSingleton) {
            return - 1;
        }

        try
        {
            class OneShotTask implements Runnable {
                String mMessage;
                int mDuration;
                int mGravity;
                int mXOffset;
                int mYOffset;

                OneShotTask(String message, int duration, int gravity, int xOffset, int yOffset) {
                    mMessage  = message;
                    mDuration = duration;
                    mGravity  = gravity;
                    mXOffset  = xOffset;
                    mYOffset  = yOffset;
                }

                public void run() {
                    try
                    {
                        Toast toast = Toast.makeText(mSingleton, mMessage, mDuration);
                        if (mGravity >= 0) {
                            toast.setGravity(mGravity, mXOffset, mYOffset);
                        }
                        toast.show();
                    } catch(Exception ex) {
                        Log.e(TAG, ex.getMessage());
                    }
                }
            }
            mSingleton.runOnUiThread(new OneShotTask(message, duration, gravity, xOffset, yOffset));
        } catch(Exception ex) {
            return -1;
        }
        return 0;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean getManifestEnvironmentVariables() {
        try {
            if (getContext() == null) {
                return false;
            }

            ApplicationInfo applicationInfo = getContext().getPackageManager().getApplicationInfo(getContext().getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = applicationInfo.metaData;
            if (bundle == null) {
                return false;
            }
            String prefix = "SDL_ENV.";
            final int trimLength = prefix.length();
            for (String key : bundle.keySet()) {
                if (key.startsWith(prefix)) {
                    String name = key.substring(trimLength);
                    String value = bundle.get(key).toString();
                    nativeSetenv(name, value);
                }
            }
            /* environment variables set! */
            return true;
        } catch (Exception e) {
            Log.v(TAG, "exception " + e.toString());
        }
        return false;
    }

    public static Surface getNativeSurface() {
        if (getContentView() == null) {
            return null;
        }
        return getContentView().getNativeSurface();
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static void initTouch() {
        int[] ids = InputDevice.getDeviceIds();

        for (int id : ids) {
            InputDevice device = InputDevice.getDevice(id);
            /* Allow SOURCE_TOUCHSCREEN and also Virtual InputDevices because they can send TOUCHSCREEN events */
            if (device != null && ((device.getSources() & InputDevice.SOURCE_TOUCHSCREEN) == InputDevice.SOURCE_TOUCHSCREEN
                    || device.isVirtual())) {

                int touchDevId = device.getId();
                /*
                 * Prevent id to be -1, since it's used in SDL internal for synthetic events
                 * Appears when using Android emulator, eg:
                 *  adb shell input mouse tap 100 100
                 *  adb shell input touchscreen tap 100 100
                 */
                if (touchDevId < 0) {
                    touchDevId -= 1;
                }
                nativeAddTouch(touchDevId, device.getName());
            }
        }
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean isAndroidTV() {
        UiModeManager uiModeManager = (UiModeManager) getContext().getSystemService(UI_MODE_SERVICE);
        if (uiModeManager.getCurrentModeType() == Configuration.UI_MODE_TYPE_TELEVISION) {
            return true;
        }
        if (Build.MANUFACTURER.equals("MINIX") && Build.MODEL.equals("NEO-U1")) {
            return true;
        }
        if (Build.MANUFACTURER.equals("Amlogic") && Build.MODEL.equals("X96-W")) {
            return true;
        }
        return Build.MANUFACTURER.equals("Amlogic") && Build.MODEL.startsWith("TV");
    }

    public static double getDiagonal()
    {
        DisplayMetrics metrics = new DisplayMetrics();
        Activity activity = (Activity)getContext();
        if (activity == null) {
            return 0.0;
        }
        activity.getWindowManager().getDefaultDisplay().getMetrics(metrics);

        double dWidthInches = metrics.widthPixels / (double)metrics.xdpi;
        double dHeightInches = metrics.heightPixels / (double)metrics.ydpi;

        return Math.sqrt((dWidthInches * dWidthInches) + (dHeightInches * dHeightInches));
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean isTablet() {
        // If our diagonal size is seven inches or greater, we consider ourselves a tablet.
        return (getDiagonal() >= 7.0);
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean isChromebook() {
        if (getContext() == null) {
            return false;
        }
        return getContext().getPackageManager().hasSystemFeature("org.chromium.arc.device_management");
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean isScreenKeyboardShown()
    {
        if (mTextEdit == null) {
            return false;
        }

        if (!mScreenKeyboardShown) {
            return false;
        }

        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        return imm.isAcceptingText();

    }

    public static void initialize() {
        // The static nature of the singleton and Android quirkyness force us to initialize everything here
        // Otherwise, when exiting the app and returning to it, these variables *keep* their pre exit values
        mSingleton = null;
        mView = null;
        mTextEdit = null;

        mClipboardHandler = null;
        mCursors = new Hashtable<Integer, PointerIcon>();
        mLastCursorID = 0;
        //mSDLThread = null; For now, no extra thread
        mIsResumedCalled = false;
        mHasFocus = true;
        mNextNativeState = NativeState.INIT;
        mCurrentNativeState = NativeState.INIT;
    }

    // Called by JNI from SDL.
    public static void manualBackButton() {
        mSingleton.pressBackButton();
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static void minimizeWindow() {

        if (mSingleton == null) {
            return;
        }

        Intent startMain = new Intent(Intent.ACTION_MAIN);
        startMain.addCategory(Intent.CATEGORY_HOME);
        startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mSingleton.startActivity(startMain);
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean sendMessage(int command, int param) {
        if (mSingleton == null) {
            return false;
        }
        return mSingleton.sendCommand(command, param);
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean setActivityTitle(String title) {
        // Called from SDLMain() thread and can't directly affect the view
        return mSingleton.sendCommand(COMMAND_CHANGE_TITLE, title);
    }

    /**
     * This method is called by SDL using JNI.
     * This is a static method for JNI convenience, it calls a non-static method
     * so that is can be overridden
     */
    public static void setOrientation(int w, int h, boolean resizable, String hint)
    {
        if (mSingleton != null) {
            mSingleton.setOrientationBis(w, h, resizable, hint);
        }
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean setRelativeMouseEnabled(boolean enabled)
    {
        if (enabled && !supportsRelativeMouse()) {
            return false;
        }

        return SDLActivity.getMotionListener().setRelativeMouseEnabled(enabled);
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean supportsRelativeMouse()
    {
        // DeX mode in Samsung Experience 9.0 and earlier doesn't support relative mice properly under
        // Android 7 APIs, and simply returns no data under Android 8 APIs.
        //
        // This is fixed in Samsung Experience 9.5, which corresponds to Android 8.1.0, and
        // thus SDK version 27.  If we are in DeX mode and not API 27 or higher, as a result,
        // we should stick to relative mode.
        //
        if (Build.VERSION.SDK_INT < 27 /* Android 8.1 (O_MR1) */ && isDeXMode()) {
            return false;
        }

        return SDLActivity.getMotionListener().supportsRelativeMouse();
    }

    protected static SDLGenericMotionListener_API12 mMotionListener;

    protected static SDLGenericMotionListener_API12 getMotionListener() {
        if (mMotionListener == null) {
            if (Build.VERSION.SDK_INT >= 26 /* Android 8.0 (O) */) {
                mMotionListener = new SDLGenericMotionListener_API26();
            } else if (Build.VERSION.SDK_INT >= 24 /* Android 7.0 (N) */) {
                mMotionListener = new SDLGenericMotionListener_API24();
            } else {
                mMotionListener = new SDLGenericMotionListener_API12();
            }
        }

        return mMotionListener;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static void setWindowStyle(boolean fullscreen) {
        // Called from SDLMain() thread and can't directly affect the view
        mSingleton.sendCommand(COMMAND_CHANGE_WINDOW_STYLE, fullscreen ? 1 : 0);
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean shouldMinimizeOnFocusLoss() {
/*
        if (Build.VERSION.SDK_INT >= 24) {
            if (mSingleton == null) {
                return true;
            }

            if (mSingleton.isInMultiWindowMode()) {
                return false;
            }

            if (mSingleton.isInPictureInPictureMode()) {
                return false;
            }
        }

        return true;
*/
        return false;
    }

    /**
     * This method is called by SDL using JNI.
     */
    public static boolean showTextInput(int x, int y, int w, int h) {
        // Transfer the task to the main thread as a Runnable
        return mSingleton.commandHandler.post(new ShowTextInputTask(x, y, w, h));
    }

    static class ShowTextInputTask implements Runnable {
        /*
         * This is used to regulate the pan&scan method to have some offset from
         * the bottom edge of the input region and the top edge of an input
         * method (soft keyboard)
         */
        static final int HEIGHT_PADDING = 15;

        public int x, y, w, h;

        public ShowTextInputTask(int x, int y, int w, int h) {
            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;

            /* Minimum size of 1 pixel, so it takes focus. */
            if (this.w <= 0) {
                this.w = 1;
            }
            if (this.h + HEIGHT_PADDING <= 0) {
                this.h = 1 - HEIGHT_PADDING;
            }
        }

        @Override
        public void run() {


            if (mTextEdit == null) {
                mTextEdit = new DummyEdit(getContext());


            }

            mTextEdit.setVisibility(View.VISIBLE);
            mTextEdit.requestFocus();

            InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.showSoftInput(mTextEdit, 0);

            mScreenKeyboardShown = true;
        }
    }

    /**
     * This method is called by SDL using JNI.
     */


} // End class SDLActivity





class SDLInputConnection extends BaseInputConnection {

        protected EditText mEditText;
        protected String mCommittedText = "";

        public SDLInputConnection(View targetView, boolean fullEditor) {
            super(targetView, fullEditor);
            mEditText = new EditText(SDLActivity.mSingleton);
        }

        @Override
        public Editable getEditable() {
            return mEditText.getEditableText();
        }

        @Override
        public boolean sendKeyEvent(KeyEvent event) {
            /*
             * This used to handle the keycodes from soft keyboard (and IME-translated input from hardkeyboard)
             * However, as of Ice Cream Sandwich and later, almost all soft keyboard doesn't generate key presses
             * and so we need to generate them ourselves in commitText.  To avoid duplicates on the handful of keys
             * that still do, we empty this out.
             */

            /*
             * Return DOES still generate a key event, however.  So rather than using it as the 'click a button' key
             * as we do with physical keyboards, let's just use it to hide the keyboard.
             */

            if (event.getKeyCode() == KeyEvent.KEYCODE_ENTER) {
                if (SDLActivity.onNativeSoftReturnKey()) {
                    return true;
                }
            }

            return super.sendKeyEvent(event);
        }

        @Override
        public boolean commitText(CharSequence text, int newCursorPosition) {
            if (!super.commitText(text, newCursorPosition)) {
                return false;
            }
            updateText();
            return true;
        }

        @Override
        public boolean setComposingText(CharSequence text, int newCursorPosition) {
            if (!super.setComposingText(text, newCursorPosition)) {
                return false;
            }
            updateText();
            return true;
        }

        @Override
        public boolean deleteSurroundingText(int beforeLength, int afterLength) {
            if (Build.VERSION.SDK_INT <= 29 /* Android 10.0 (Q) */) {
                // Workaround to capture backspace key. Ref: http://stackoverflow.com/questions>/14560344/android-backspace-in-webview-baseinputconnection
                // and https://bugzilla.libsdl.org/show_bug.cgi?id=2265
                if (beforeLength > 0 && afterLength == 0) {
                    // backspace(s)
                    while (beforeLength-- > 0) {
                        nativeGenerateScancodeForUnichar('\b');
                    }
                    return true;
                }
            }

            if (!super.deleteSurroundingText(beforeLength, afterLength)) {
                return false;
            }
            updateText();
            return true;
        }

        protected void updateText() {
            final Editable content = getEditable();
            if (content == null) {
                return;
            }

            String text = content.toString();
            int compareLength = Math.min(text.length(), mCommittedText.length());
            int matchLength, offset;

            /* Backspace over characters that are no longer in the string */
            for (matchLength = 0; matchLength < compareLength; ) {
                int codePoint = mCommittedText.codePointAt(matchLength);
                if (codePoint != text.codePointAt(matchLength)) {
                    break;
                }
                matchLength += Character.charCount(codePoint);
            }
            /* FIXME: This doesn't handle graphemes, like '🌬️' */
            for (offset = matchLength; offset < mCommittedText.length(); ) {
                int codePoint = mCommittedText.codePointAt(offset);
                nativeGenerateScancodeForUnichar('\b');
                offset += Character.charCount(codePoint);
            }

            if (matchLength < text.length()) {
                String pendingText = text.subSequence(matchLength, text.length()).toString();
                for (offset = 0; offset < pendingText.length(); ) {
                    int codePoint = pendingText.codePointAt(offset);
                    if (codePoint == '\n') {
                        if (SDLActivity.onNativeSoftReturnKey()) {
                            return;
                        }
                    }
                    /* Higher code points don't generate simulated scancodes */
                    if (codePoint < 128) {
                        nativeGenerateScancodeForUnichar((char)codePoint);
                    }
                    offset += Character.charCount(codePoint);
                }
                SDLInputConnection.nativeCommitText(pendingText, 0);
            }
            mCommittedText = text;
        }

        public static native void nativeCommitText(String text, int newCursorPosition);

        public static native void nativeGenerateScancodeForUnichar(char c);
    }

    class SDLClipboardHandler implements
            ClipboardManager.OnPrimaryClipChangedListener {

        protected ClipboardManager mClipMgr;

        SDLClipboardHandler() {
            mClipMgr = (ClipboardManager) SDLActivity.mSingleton.getSystemService(Context.CLIPBOARD_SERVICE);
            mClipMgr.addPrimaryClipChangedListener(this);
        }

        public boolean clipboardHasText() {
            return mClipMgr.hasPrimaryClip();
        }

        public String clipboardGetText() {
            ClipData clip = mClipMgr.getPrimaryClip();
            if (clip != null) {
                ClipData.Item item = clip.getItemAt(0);
                if (item != null) {
                    CharSequence text = item.getText();
                    if (text != null) {
                        return text.toString();
                    }
                }
            }
            return null;
        }

        public void clipboardSetText(String string) {
            mClipMgr.removePrimaryClipChangedListener(this);
            ClipData clip = ClipData.newPlainText(null, string);
            mClipMgr.setPrimaryClip(clip);
            mClipMgr.addPrimaryClipChangedListener(this);
        }

        @Override
        public void onPrimaryClipChanged() {
            SDLActivity.onNativeClipboardChanged();
        }
    }



