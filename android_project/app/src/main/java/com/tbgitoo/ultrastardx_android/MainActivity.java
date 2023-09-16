package com.tbgitoo.ultrastardx_android;



import android.os.Bundle;
import android.widget.TextView;

import com.tbgitoo.ultrastardx_android.databinding.ActivityMainBinding;
import org.libsdl.app.SDLActivity;


public class MainActivity extends SDLActivity {

    // Used to load the 'ultrastardx_android' library on application startup.
    static {
        System.loadLibrary("ultrastardx_android");
    }



    /**
     * A native method that is implemented by the 'ultrastardx_android' native library,
     * which is packaged with this application.
     */
    public native float numberFromJNI();
}