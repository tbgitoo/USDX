package com.tbgitoo.ultrastardx_android;

import android.content.Context;
import android.util.Log;

import androidx.core.graphics.TypefaceCompatUtil;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class USDX_FileHandler {

    protected static Context mContext=null;

    private static String privateStorageRoot ="";
    private static String externalStorageRoot="";

    private void installFileIfNotExists(String target_fname, int ressource_id)  {

        File file_target= (new File(externalStorageRoot)).toPath().resolve(target_fname).toFile();
        if(!file_target.exists()) {
            Log.v("mainActivity","Installing to "+file_target);
            InputStream file_source = mContext.getResources().openRawResource(ressource_id);
            try {

                Files.copy(
                        file_source,
                        file_target.toPath(),
                        StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

            try {
                file_source.close();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

    }

    protected static void setPrivateStorageRoot(String newStorageRoot)
    {
        privateStorageRoot =newStorageRoot;
    }

    public static void setStoragePrivateDefault()
    {
        if(mContext!=null)
        {
            setPrivateStorageRoot(mContext.getFilesDir().getAbsolutePath());
        }
    }

    // Access to the default internal storage of the app on the
    // internal storage medium
    public static String getPrivateStorageRoot()
    {
        return privateStorageRoot;
    }

    // Access to the default external storage of the app on
    // the external storage medium (sd card and others)
    public static String getExternalStorageRoot()
    {
        return externalStorageRoot;
    }

    public static void setStorageExternalDefault()
    {

        File[] externalStorageVolumes =
                mContext.getExternalFilesDirs(null);
        externalStorageRoot=externalStorageVolumes[0].getAbsolutePath();
    }

    public static void initStorageLocationsDefault()
    {
        setStorageExternalDefault();
        setStoragePrivateDefault();
    }



    // This function stores the current activity
    public static void setContext(Context context) {
        mContext = context;
    }

    public static Context getContext() {
        return mContext;
    }



}
