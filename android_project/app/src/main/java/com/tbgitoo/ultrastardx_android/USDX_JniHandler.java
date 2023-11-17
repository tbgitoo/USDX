package com.tbgitoo.ultrastardx_android;

        import android.util.Log;


public class USDX_JniHandler {

    /*
     * Storage root for the external files
     */
    private static String storageRoot="";

    public static void setStorageRoot(String newStorageRoot)
    {
        storageRoot=newStorageRoot;
    }


    public static String getStorageRoot()
    {
        return storageRoot;
    }

    public static int getStorageRootStrLen()
    {
        return getStorageRoot().length();
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

