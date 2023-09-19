package com.tbgitoo.ultrastardx_android;



import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

import androidx.core.content.ContextCompat;

import org.apache.commons.io.IOUtils;
import org.libsdl.app.SDLActivity;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;


public class MainActivity extends SDLActivity {

    // Used to load the 'ultrastardx_android' library on application startup.
    static {
        System.loadLibrary("main");
    }

    protected File storageRoot;

    private void installFileIfNotExists(String target_fname, int ressource_id)
    {
        File file_target=storageRoot.toPath().resolve(target_fname).toFile();
        if(!file_target.exists()) {
            Log.v("mainActivity","Installing to "+file_target);
            InputStream file_source = getApplicationContext().getResources().openRawResource(ressource_id);
            try {

                Files.copy(
                        file_source,
                        file_target.toPath(),
                        StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException e) {
                throw new RuntimeException(e);
            } finally {

                IOUtils.closeQuietly(file_source);
            }
        }

    }



    // From https://stackoverflow.com/questions/11734084/how-to-unzip-file-that-that-is-not-in-utf8-format-in-java
    protected void unzipinstallZipIfNotExists(String target_folder_name, int ressource_id, String replace_root) {

        Path folder_target_path = storageRoot.toPath().resolve(target_folder_name);
        File folder_target = folder_target_path.toFile();



            if (!folder_target.exists()) {
                folder_target.mkdirs();
                Log.v("mainActivity", "Installing to folder " + folder_target);

                ZipInputStream zipIs = new ZipInputStream(getApplicationContext().getResources().openRawResource(ressource_id));
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






    private static void extractFile(ZipInputStream is, File output_target)
            throws IOException {
        Log.v("extractFile","folder "+output_target.toPath().getParent().toFile());

        FileOutputStream fos = new FileOutputStream(output_target);
        try {
            while(is.available() != 0){
                fos.write(is.read());
            }
        } catch (IOException ioex) {
            fos.close();
        }
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        storageRoot=primaryExternalStorage();
        //installFileIfNotExists("config.ini", R.raw.config);
        //installZipIfNotExists("avatars", R.raw.avatars, "game/avatars/");

        unzipinstallZipIfNotExists("covers", R.raw.covers, "game/covers/");

        super.onCreate(savedInstanceState);

    }
    private File primaryExternalStorage() {
        File[] externalStorageVolumes =
                ContextCompat.getExternalFilesDirs(getApplicationContext(), null);
        return(externalStorageVolumes[0]);
    }

    // Checks if a volume containing external storage is available
// for read and write.
    private boolean isExternalStorageWritable() {
        return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
    }

    // Checks if a volume containing external storage is available to at least read.
    private boolean isExternalStorageReadable() {
        return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED) ||
                Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED_READ_ONLY);
    }




    /**
     * A native method that is implemented by the 'ultrastardx_android' native library,
     * which is packaged with this application.
     */
    public native float numberFromJNI();
}