package com.tbgitoo.ultrastardx_android;

import android.os.Build;
import android.util.Log;

import androidx.annotation.Keep;

public class JniHandler {

    /*
     * Storage root for the external files
     */
    private static String storageRoot="";

    public static void setStorageRoot(String newStorageRoot)
    {
        storageRoot=newStorageRoot;
    }

    @Keep
    public static String getStorageRoot()
    {
        return storageRoot;
    }
    @Keep
    public static int getStorageRootStrLen()
    {
        return getStorageRoot().length();
    }


    /*
     * Print out status to logcat
     */
    @Keep
    private static void updateStatus(String msg) {
        if (msg.toLowerCase().contains("error")) {
            Log.e("JniHandler", "Native Err: " + msg);
        } else {
            Log.i("JniHandler", "Native Msg: " + msg);
        }
    }

    /*
     * Return OS build version: a static function
     */
    @Keep
    static public String getBuildVersion() {
        return "a";
    }

    /*
     * Return Java memory info
     */

}

