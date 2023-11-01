package com.android.gl2jni;



import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.InputDevice;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.PointerIcon;
import android.view.Surface;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;

import org.libsdl.app.DummyEdit;
import org.libsdl.app.SDLActivity;

import java.util.Hashtable;

public class SDL_GL2JNI_Activity extends GL2JNIActivity implements View.OnSystemUiVisibilityChangeListener{

    protected SDLSurface mView;

    private static final String TAG = "SDLActivity";


    public void onNativeMouse(int button, int action, float x, float y, boolean relative){
        mView.queueEvent(() -> SDLActivity.onNativeMouse(button, action, x, y, relative));

    }





    /** If shared libraries (e.g. SDL or the native application) could not be loaded. */


    // Main components



    public void initialize() {
        // The static nature of the singleton and Android quirkyness force us to initialize everything here
        // Otherwise, when exiting the app and returning to it, these variables *keep* their pre exit values
        SDLActivity.mSingleton = null;
        mView = null;
        SDLActivity.mTextEdit = null;

        SDLActivity.mCursors = new Hashtable<Integer, PointerIcon>();
        SDLActivity.mLastCursorID = 0;

        SDLActivity.mIsResumedCalled = false;
        SDLActivity.mHasFocus = true;
        SDLActivity.mNextNativeState = SDLActivity.NativeState.INIT;
        SDLActivity.mCurrentNativeState = SDLActivity.NativeState.INIT;
    }

    protected SDLSurface createSDLSurface() {
        return new SDLSurface(getApplication());
    }


    @Override protected void onCreate(Bundle icicle) {

        Log.v(TAG, "Device: " + Build.DEVICE);
        Log.v(TAG, "Model: " + Build.MODEL);
        Log.v(TAG, "onCreate()");

        SDLActivity.initialize();

        // So we can call stuff from static callbacks
        SDLActivity.mSingleton = this;


        mView = createSDLSurface();
        setContentView(mView);
        SDLActivity.setContentView(mView);

        SDLActivity.nativeSetupJNI();

        // Get our current screen orientation and pass it down.
        SDLActivity.nativeSetNaturalOrientation(getNaturalOrientation());
        SDLActivity.mCurrentRotation = getCurrentRotation();
        SDLActivity.onNativeRotationChanged(SDLActivity.mCurrentRotation);

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

                SDL_GL2JNI_Activity.this.getWindow().getDecorView().setSystemUiVisibility(flags);
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

    public SDL_GL2JNI_Activity() {
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
        int result = SDLActivity.SDL_ORIENTATION_UNKNOWN;

            Configuration config = getResources().getConfiguration();
            Display display = getWindowManager().getDefaultDisplay();
            int rotation = display.getRotation();
            if (((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) &&
                    config.orientation == Configuration.ORIENTATION_LANDSCAPE) ||
                    ((rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270) &&
                            config.orientation == Configuration.ORIENTATION_PORTRAIT)) {
                result = SDLActivity.SDL_ORIENTATION_LANDSCAPE;
            } else {
                result = SDLActivity.SDL_ORIENTATION_PORTRAIT;
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

    // Used to get us onto the activity's main thread
    public void pressBackButton() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!isFinishing()) {
                    superOnBackPressed();
                }
            }
        });
    }

    // Used to access the system back behavior.
    public void superOnBackPressed() {
        super.onBackPressed();
    }

    // Messages from the SDLMain thread
    public static final int COMMAND_CHANGE_TITLE = 1;
    public static final int COMMAND_CHANGE_WINDOW_STYLE = 2;
    public static final int COMMAND_TEXTEDIT_HIDE = 3;
    public static final int COMMAND_SET_KEEP_SCREEN_ON = 5;

    protected static final int COMMAND_USER = 0x8000;

    /**
     * This can be overridden
     */
    public void setOrientationBis(int w, int h, boolean resizable, String hint)
    {
        int orientation_landscape = -1;
        int orientation_portrait = -1;

        /* If set, hint "explicitly controls which UI orientations are allowed". */
        if (hint.contains("LandscapeRight") && hint.contains("LandscapeLeft")) {
            orientation_landscape = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE;
        } else if (hint.contains("LandscapeLeft")) {
            orientation_landscape = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
        } else if (hint.contains("LandscapeRight")) {
            orientation_landscape = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
        }

        /* exact match to 'Portrait' to distinguish with PortraitUpsideDown */
        boolean contains_Portrait = hint.contains("Portrait ") || hint.endsWith("Portrait");

        if (contains_Portrait && hint.contains("PortraitUpsideDown")) {
            orientation_portrait = ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
        } else if (contains_Portrait) {
            orientation_portrait = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
        } else if (hint.contains("PortraitUpsideDown")) {
            orientation_portrait = ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
        }

        boolean is_landscape_allowed = (orientation_landscape != -1);
        boolean is_portrait_allowed = (orientation_portrait != -1);
        int req; /* Requested orientation */

        /* No valid hint, nothing is explicitly allowed */
        if (!is_portrait_allowed && !is_landscape_allowed) {
            if (resizable) {
                /* All orientations are allowed */
                req = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
            } else {
                /* Fixed window and nothing specified. Get orientation from w/h of created window */
                req = (w > h ? ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE : ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
            }
        } else {
            /* At least one orientation is allowed */
            if (resizable) {
                if (is_portrait_allowed && is_landscape_allowed) {
                    /* hint allows both landscape and portrait, promote to full sensor */
                    req = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
                } else {
                    /* Use the only one allowed "orientation" */
                    req = (is_landscape_allowed ? orientation_landscape : orientation_portrait);
                }
            } else {
                /* Fixed window and both orientations are allowed. Choose one. */
                if (is_portrait_allowed && is_landscape_allowed) {
                    req = (w > h ? orientation_landscape : orientation_portrait);
                } else {
                    /* Use the only one allowed "orientation" */
                    req = (is_landscape_allowed ? orientation_landscape : orientation_portrait);
                }
            }
        }

        Log.v(TAG, "setOrientation() requestedOrientation=" + req + " width=" + w +" height="+ h +" resizable=" + resizable + " hint=" + hint);
        setRequestedOrientation(req);
    }

    /**
     * A Handler class for Messages from native SDL applications.
     * It uses current Activities as target (e.g. for the title).
     * static to prevent implicit references to enclosing object.
     */
    protected static class SDLCommandHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            Context context = SDLActivity.getContext();
            if (context == null) {
                Log.e(TAG, "error handling message, getContext() returned null");
                return;
            }
            switch (msg.arg1) {
                case COMMAND_CHANGE_TITLE:
                    if (context instanceof Activity) {
                        ((Activity) context).setTitle((String)msg.obj);
                    } else {
                        Log.e(TAG, "error handling message, getContext() returned no Activity");
                    }
                    break;
                case COMMAND_CHANGE_WINDOW_STYLE:
                    if (Build.VERSION.SDK_INT >= 19 /* Android 4.4 (KITKAT) */) {
                        if (context instanceof Activity) {
                            Window window = ((Activity) context).getWindow();
                            if (window != null) {
                                if ((msg.obj instanceof Integer) && ((Integer) msg.obj != 0)) {
                                    int flags = View.SYSTEM_UI_FLAG_FULLSCREEN |
                                            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
                                            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY |
                                            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                                            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
                                            View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.INVISIBLE;
                                    window.getDecorView().setSystemUiVisibility(flags);
                                    window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
                                    window.clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
                                    mFullscreenModeActive = true;
                                } else {
                                    int flags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_VISIBLE;
                                    window.getDecorView().setSystemUiVisibility(flags);
                                    window.addFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
                                    window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
                                    mFullscreenModeActive = false;
                                }
                            }
                        } else {
                            Log.e(TAG, "error handling message, getContext() returned no Activity");
                        }
                    }
                    break;
                case COMMAND_TEXTEDIT_HIDE:
                    if (SDLActivity.mTextEdit != null) {


                        InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(SDLActivity.mTextEdit.getWindowToken(), 0);



                        SDLActivity.mScreenKeyboardShown = false;

                        SDLActivity.getContentView().requestFocus();
                    }
                    break;
                case COMMAND_SET_KEEP_SCREEN_ON:
                {
                    if (context instanceof Activity) {
                        Window window = ((Activity) context).getWindow();
                        if (window != null) {
                            if ((msg.obj instanceof Integer) && ((Integer) msg.obj != 0)) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                            }
                        }
                    }
                    break;
                }
                default:
                    if ((context instanceof SDL_GL2JNI_Activity) && !((SDL_GL2JNI_Activity) context).onUnhandledMessage(msg.arg1, msg.obj)) {
                        Log.e(TAG, "error handling message, command is " + msg.arg1);
                    }
            }
        }
    }

    /**
     * This method is called by SDL if SDL did not handle a message itself.
     * This happens if a received message contains an unsupported command.
     * Method can be overwritten to handle Messages in a different class.
     * @param command the command of the message.
     * @param param the parameter of the message. May be null.
     * @return if the message was handled in overridden method.
     */
    protected boolean onUnhandledMessage(int command, Object param) {
        return false;
    }


    // Handler for the messages
    public Handler commandHandler = new SDLCommandHandler();


    // Send a message from the SDLMain thread
    public boolean sendCommand(int command, Object data) {
        Message msg = commandHandler.obtainMessage();
        msg.arg1 = command;
        msg.obj = data;
        boolean result = commandHandler.sendMessage(msg);

        if (Build.VERSION.SDK_INT >= 19 /* Android 4.4 (KITKAT) */) {
            if (command == COMMAND_CHANGE_WINDOW_STYLE) {
                // Ensure we don't return until the resize has actually happened,
                // or 500ms have passed.

                boolean bShouldWait = false;

                if (data instanceof Integer) {
                    // Let's figure out if we're already laid out fullscreen or not.
                    Display display = ((WindowManager) getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
                    DisplayMetrics realMetrics = new DisplayMetrics();
                    display.getRealMetrics(realMetrics);

                    boolean bFullscreenLayout = ((realMetrics.widthPixels == SDLActivity.getContentView().getWidth()) &&
                            (realMetrics.heightPixels == SDLActivity.getContentView().getHeight()));

                    if ((Integer) data == 1) {
                        // If we aren't laid out fullscreen or actively in fullscreen mode already, we're going
                        // to change size and should wait for surfaceChanged() before we return, so the size
                        // is right back in native code.  If we're already laid out fullscreen, though, we're
                        // not going to change size even if we change decor modes, so we shouldn't wait for
                        // surfaceChanged() -- which may not even happen -- and should return immediately.
                        bShouldWait = !bFullscreenLayout;
                    } else {
                        // If we're laid out fullscreen (even if the status bar and nav bar are present),
                        // or are actively in fullscreen, we're going to change size and should wait for
                        // surfaceChanged before we return, so the size is right back in native code.
                        bShouldWait = bFullscreenLayout;
                    }
                }

                if (bShouldWait && (SDLActivity.getContext() != null)) {
                    // We'll wait for the surfaceChanged() method, which will notify us
                    // when called.  That way, we know our current size is really the
                    // size we need, instead of grabbing a size that's still got
                    // the navigation and/or status bars before they're hidden.
                    //
                    // We'll wait for up to half a second, because some devices
                    // take a surprisingly long time for the surface resize, but
                    // then we'll just give up and return.
                    //
                    synchronized (SDLActivity.getContext()) {
                        try {
                            SDLActivity.getContext().wait(500);
                        } catch (InterruptedException ie) {
                            ie.printStackTrace();
                        }
                    }
                }
            }
        }

        return result;
    }


}


/* This is a fake invisible editor view that receives the input and defines the
 * pan&scan region
 */







