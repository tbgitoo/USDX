package com.android.gl2jni;

import static java.security.AccessController.getContext;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.util.Log;
import android.view.Display;
import android.view.InputDevice;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.PointerIcon;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.InputConnection;
import android.widget.EditText;

import java.util.Hashtable;

public class SDLSimpleActivity extends GL2JNIActivity implements View.OnSystemUiVisibilityChangeListener{

    protected SDLSurface mView;

    private static final String TAG = "SDL";
    private static final int SDL_MAJOR_VERSION = 3;
    private static final int SDL_MINOR_VERSION = 0;
    private static final int SDL_MICRO_VERSION = 0;


    public static boolean mIsResumedCalled, mHasFocus;

    // Cursor types
    // private static final int SDL_SYSTEM_CURSOR_NONE = -1;
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

    protected static final int SDL_ORIENTATION_UNKNOWN = 0;
    protected static final int SDL_ORIENTATION_LANDSCAPE = 1;
    protected static final int SDL_ORIENTATION_LANDSCAPE_FLIPPED = 2;
    protected static final int SDL_ORIENTATION_PORTRAIT = 3;
    protected static final int SDL_ORIENTATION_PORTRAIT_FLIPPED = 4;

    protected static int mCurrentRotation;


    public static  void onNativeKeyboardFocusLost(){
        SDLJNILib.onNativeKeyboardFocusLost();
    }
    public static  void nativeSetNaturalOrientation(int orientation){
        SDLJNILib.nativeSetNaturalOrientation(orientation);
    }

    public static  void onNativeRotationChanged(int rotation){
        SDLJNILib.onNativeRotationChanged(rotation);
    }

    public void onNativeMouse(int button, int action, float x, float y, boolean relative){
        mView.queueEvent(() -> SDLJNILib.onNativeMouse(button, action, x, y, relative));



    }


    // Handle the state of the native layer
    public enum NativeState {
        INIT, RESUMED, PAUSED
    }

    public static NativeState mNextNativeState;
    public static NativeState mCurrentNativeState;

    /** If shared libraries (e.g. SDL or the native application) could not be loaded. */


    // Main components
    protected static SDLSimpleActivity mSingleton;
    protected static SDLSurface mSurface;
    protected static DummyEdit mTextEdit;



    protected static Hashtable<Integer, PointerIcon> mCursors;
    protected static int mLastCursorID;





    public static void initialize() {
        // The static nature of the singleton and Android quirkyness force us to initialize everything here
        // Otherwise, when exiting the app and returning to it, these variables *keep* their pre exit values
        mSingleton = null;
        mSurface = null;
        mTextEdit = null;

        mCursors = new Hashtable<Integer, PointerIcon>();
        mLastCursorID = 0;

        mIsResumedCalled = false;
        mHasFocus = true;
        mNextNativeState = NativeState.INIT;
        mCurrentNativeState = NativeState.INIT;
    }

    protected SDLSurface createSDLSurface(Context context) {
        return new SDLSurface(context);
    }


    @Override protected void onCreate(Bundle icicle) {

        Log.v(TAG, "Device: " + Build.DEVICE);
        Log.v(TAG, "Model: " + Build.MODEL);
        Log.v(TAG, "onCreate()");



        // So we can call stuff from static callbacks
        mSingleton = this;


        mView = new SDLSurface(getApplication());
        setContentView(mView);

        // Get our current screen orientation and pass it down.
        SDLSimpleActivity.nativeSetNaturalOrientation(getNaturalOrientation());
        mCurrentRotation = getCurrentRotation();
        SDLSimpleActivity.onNativeRotationChanged(mCurrentRotation);


        super.onCreate(icicle);




    }





    public static boolean handleKeyEvent(View v, int keyCode, KeyEvent event, Object o) {
        return true;
    }



    private final Runnable rehideSystemUi = new Runnable() {
        @Override
        public void run() {
            if (Build.VERSION.SDK_INT >= 19 /* Android 4.4 (KITKAT) */) {
                int flags = View.SYSTEM_UI_FLAG_FULLSCREEN |
                        View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
                        View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY |
                        View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                        View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
                        View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.INVISIBLE;

                SDLSimpleActivity.this.getWindow().getDecorView().setSystemUiVisibility(flags);
            }
        }
    };


    @Override
    public void onSystemUiVisibilityChange(int visibility) {
        if (GL2JNIActivity.mFullscreenModeActive && ((visibility & View.SYSTEM_UI_FLAG_FULLSCREEN) == 0 || (visibility & View.SYSTEM_UI_FLAG_HIDE_NAVIGATION) == 0)) {

            Handler handler = getWindow().getDecorView().getHandler();
            if (handler != null) {
                handler.removeCallbacks(rehideSystemUi); // Prevent a hide loop.
                handler.postDelayed(rehideSystemUi, 2000);
            }

        }
    }

    public SDLSimpleActivity() {
        mView = null;
    }






    // Events
    @Override
    protected void onPause() {
        Log.v(TAG, "onPause()");
        super.onPause();
        mView.onPause();

    }

    @Override
    protected void onResume() {
        Log.v(TAG, "onResume()");
        super.onResume();
        mView.onResume();


    }

    @Override
    protected void onStop() {
        Log.v(TAG, "onStop()");
        super.onStop();

    }

    @Override
    protected void onStart() {
        Log.v(TAG, "onStart()");
        super.onStart();

    }

    public int getNaturalOrientation() {
        int result = SDL_ORIENTATION_UNKNOWN;

            Configuration config = getResources().getConfiguration();
            Display display = getWindowManager().getDefaultDisplay();
            int rotation = display.getRotation();
            if (((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) &&
                    config.orientation == Configuration.ORIENTATION_LANDSCAPE) ||
                    ((rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270) &&
                            config.orientation == Configuration.ORIENTATION_PORTRAIT)) {
                result = SDL_ORIENTATION_LANDSCAPE;
            } else {
                result = SDL_ORIENTATION_PORTRAIT;
            }

        return result;
    }

    public int getCurrentRotation() {
        int result = 0;


            Display display = getWindowManager().getDefaultDisplay();
            switch (display.getRotation()) {
                case Surface.ROTATION_0:
                    result = 0;
                    break;
                case Surface.ROTATION_90:
                    result = 90;
                    break;
                case Surface.ROTATION_180:
                    result = 180;
                    break;
                case Surface.ROTATION_270:
                    result = 270;
                    break;
            }

        return result;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {

        float x, y;
        int action;





        if ((event.getSource() & (InputDevice.SOURCE_CLASS_POINTER  )) > 0) {

            action = event.getActionMasked();

            switch (action) {
                case MotionEvent.ACTION_SCROLL:
                    x = event.getAxisValue(MotionEvent.AXIS_HSCROLL, 0);
                    y = event.getAxisValue(MotionEvent.AXIS_VSCROLL, 0);
                    onNativeMouse(0, action, x, y, false);
                    return true;

                case MotionEvent.ACTION_HOVER_MOVE:

                    x = event.getX(0);
                    y = event.getY(0);

                    onNativeMouse(0, action, x, y, false);
                    return true;

                case MotionEvent.ACTION_UP:
                    x = event.getX(0);
                    y = event.getY(0);

                    onNativeMouse(1, action, x, y, false);
                    return true;



                default:
                    break;
            }
        }


        return false;


    }








}


/* This is a fake invisible editor view that receives the input and defines the
 * pan&scan region
 */
class DummyEdit extends View implements View.OnKeyListener {
    InputConnection ic;

    public DummyEdit(Context context) {
        super(context);
        setFocusableInTouchMode(true);
        setFocusable(true);
        setOnKeyListener(this);
    }

    @Override
    public boolean onCheckIsTextEditor() {
        return true;
    }

    @Override
    public boolean onKey(View v, int keyCode, KeyEvent event) {
        return SDLSimpleActivity.handleKeyEvent(v, keyCode, event, ic);
    }

    //
    @Override
    public boolean onKeyPreIme (int keyCode, KeyEvent event) {
        // As seen on StackOverflow: http://stackoverflow.com/questions/7634346/keyboard-hide-event
        // FIXME: Discussion at http://bugzilla.libsdl.org/show_bug.cgi?id=1639
        // FIXME: This is not a 100% effective solution to the problem of detecting if the keyboard is showing or not
        // FIXME: A more effective solution would be to assume our Layout to be RelativeLayout or LinearLayout
        // FIXME: And determine the keyboard presence doing this: http://stackoverflow.com/questions/2150078/how-to-check-visibility-of-software-keyboard-in-android
        // FIXME: An even more effective way would be if Android provided this out of the box, but where would the fun be in that :)
        if (event.getAction()==KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
            if (SDLSimpleActivity.mTextEdit != null && SDLSimpleActivity.mTextEdit.getVisibility() == View.VISIBLE) {
                SDLSimpleActivity.onNativeKeyboardFocusLost();
            }
        }
        return super.onKeyPreIme(keyCode, event);
    }


}






