package com.tbgitoo.ultrastardx_android;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

import com.tbgitoo.ultrastardx_android.databinding.ActivityMainBinding;

public class MainActivity extends AppCompatActivity {

    // Used to load the 'ultrastardx_android' library on application startup.
    static {
        System.loadLibrary("ultrastardx_android");
    }

    private ActivityMainBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Example of a call to a native method
        TextView tv = binding.sampleText;
        tv.setText(String.format("%f",numberFromJNI()));
    }

    /**
     * A native method that is implemented by the 'ultrastardx_android' native library,
     * which is packaged with this application.
     */
    public native float numberFromJNI();
}