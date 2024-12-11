package com.tbgitoo.ultrastardx_android;

import android.content.Context;
import android.util.Log;

import androidx.core.graphics.TypefaceCompatUtil;

import com.tbgitoo.sdl2_native.R;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class USDX_FileHandler {

    protected static Context mContext=null;

    private static String privateStorageRoot ="";
    private static String externalStorageRoot="";

    protected static void installFileIfNotExists(String target_fname, int ressource_id)  {

        File file_target= (new File(externalStorageRoot)).toPath().resolve(target_fname).toFile();
        if(!file_target.exists()) {
            Log.v("USDX_FileHandler","Installing to "+file_target);
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

    // From https://stackoverflow.com/questions/11734084/how-to-unzip-file-that-that-is-not-in-utf8-format-in-java
    protected static void unzipinstallZipIfNotExists(String target_folder_name, int ressource_id, String replace_root) {

        Path folder_target_path = (new File(externalStorageRoot)).toPath().resolve(target_folder_name);
        File folder_target = folder_target_path.toFile();



        if (!folder_target.exists()) {
            folder_target.mkdirs();
            Log.v("mainActivity", "Installing to folder " + folder_target);

            ZipInputStream zipIs = new ZipInputStream(mContext.getResources().openRawResource(ressource_id));
            ZipEntry zEntry;

            while (true) {
                try {
                    if (!((zEntry = zipIs.getNextEntry()) != null)) break;
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }

                String localName = zEntry.getName().replace(replace_root, "");

                if (!localName.equals("")) {
                    if (zEntry.isDirectory()) {
                        folder_target_path.resolve(localName).toFile().mkdirs();
                    } else {
                        Log.v("mainActivity", localName);
                        byte[] tmp = new byte[4 * 1024];
                        FileOutputStream fos = null;
                        try {
                            fos = new FileOutputStream(folder_target_path.resolve(localName).toFile());
                        } catch (FileNotFoundException e) {
                            throw new RuntimeException(e);
                        }
                        int size = 0;
                        try{
                            while ((size = zipIs.read(tmp)) != -1) {
                                fos.write(tmp, 0, size);
                            }
                            fos.flush();
                            fos.close();}
                        catch (IOException e)
                        {
                            System.out.println("Probably java bug file not found due to encoding");
                        }
                    }
                }


            }
            try {
                zipIs.close();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

    }

    public static void install_USDX_game_files() {

        installFileIfNotExists("config.ini", R.raw.config);
        unzipinstallZipIfNotExists("avatars", R.raw.avatars, "game/avatars/");
        unzipinstallZipIfNotExists("covers", R.raw.covers, "game/covers/");
        unzipinstallZipIfNotExists("fonts", R.raw.fonts, "game/fonts/");
        unzipinstallZipIfNotExists("languages", R.raw.languages, "game/languages/");
        unzipinstallZipIfNotExists("plugins", R.raw.plugins, "game/plugins/");
        unzipinstallZipIfNotExists("resources", R.raw.resources, "game/resources/");
        unzipinstallZipIfNotExists("soundfonts", R.raw.soundfonts, "game/soundfonts/");
        unzipinstallZipIfNotExists("sounds", R.raw.sounds, "game/sounds/");
        unzipinstallZipIfNotExists("themes", R.raw.themes, "game/themes/");
        unzipinstallZipIfNotExists("visuals", R.raw.visuals, "game/visuals/");
        installFileIfNotExists("license_ffmpeg.txt", R.raw.license_ffmpeg);
        installFileIfNotExists("license_freetype.txt", R.raw.license_freetype);
        installFileIfNotExists("license_libdav1d.txt", R.raw.license_libdav1d);
        installFileIfNotExists("license_libjpeg_turbo.txt", R.raw.license_libjpeg_turbo);
        installFileIfNotExists("license_lua.txt", R.raw.license_lua);
        installFileIfNotExists("license_png.txt", R.raw.license_png);
        installFileIfNotExists("license_portaudio.txt", R.raw.license_portaudio);
        installFileIfNotExists("license_sdl2.txt", R.raw.license_sdl2);
        installFileIfNotExists("license_sqlite.txt", R.raw.license_sqlite);
        installFileIfNotExists("license_tiff.txt", R.raw.license_tiff);
        installFileIfNotExists("license_webp.txt", R.raw.license_webp);
        installFileIfNotExists("license_zlib.txt", R.raw.license_zlib);
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

    protected static void setExternalStorageRoot(String newStorageRoot)
    {
        externalStorageRoot =newStorageRoot;


    }

    public static void setStorageExternalDefault()
    {

        File[] externalStorageVolumes =
                mContext.getExternalFilesDirs(null);
        setExternalStorageRoot(externalStorageVolumes[0].getAbsolutePath());

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
