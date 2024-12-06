package com.tbgitoo.ultrastardx_android;

import android.content.Context;
import android.util.Log;


public class USDX_JniHandler {


    public static String getPrivateStorageRoot()
    {
        return USDX_FileHandler.getPrivateStorageRoot();
    }


    public static int getPrivateStorageRootStrLen()
    {
        return USDX_FileHandler.getPrivateStorageRoot().length();
    }


    /*
     * Print out status to logcat
     */

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

    static public String getBuildVersion() {
        return "a";
    }



    /*
     * Return Java memory info
     */

}