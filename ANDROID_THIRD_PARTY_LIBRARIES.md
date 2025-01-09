For making the Android version, the shared libraries are required in an Android specific .so format (that is ELF-formatted, with instructions sets specific to the Android architectures x86, x86_64, armeabi, arm64). These shared object libraries are similar to the linux-type .so librairies, but sometimes more difficult to get by.

The necessary collection of these libraries is provided here in dists/android/external, according to the Android architectures.

These .so files are generally compiled from available open-source third-party libraries. Here some notes on their compilation:


SDL2: If you want to compile these, use the ndk compilers. For a starting example of how to do that, see  https://github.com/AlexanderAgd/SDL2-Android/

For compilation, it is also advantageous to set appropriate environment variables. For example:

Set the following in your your .bash profile
PATH=$PATH:~/Library/Android/sdk/ndk/25.2.9519653
PATH=$PATH:~/Library/Android/sdk/tools
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/25.2.9519653

If you want to use the script at https://github.com/AlexanderAgd/SDL2-Android/, the command would be something like

./build_SDL2.sh  --api=29 --arch=armeabi-v7a 
./build_SDL2.sh  --api=29 --arch=arm64-v8a
./build_SDL2.sh  --api=29 --arch=x86
./build_SDL2.sh  --api=29 --arch=x86_64



It works also directly with the official SDL2 version:  git clone --branch SDL2 https://github.com/libsdl-org/SDL

Set the following in your your .bash profile
PATH=$PATH:~/Library/Android/sdk/ndk/25.2.9519653
PATH=$PATH:~/Library/Android/sdk/tools
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/25.2.9519653

git clone --branch SDL2 https://github.com/libsdl-org/SDL

in the SDL folder created, execute build-scripts/android-prefab.sh and find libSDL2.so for each architecture, along with the includes and .pc files

git clone --branch SDL2 https://github.com/libsdl-org/SDL_image

in the SDL_image folder created, execute build-scripts/android-prefab.sh, find libSL2_image.so for each architecture along the includes and .pc files. There may be some issues that you need to debug in the script itself, for example setting an sdl_build_root variable in the script so that it points to the build-android-prefab in the SLD folder from above, and also checking whether the script can find SDL_image.h, it may be in the include. Also, you need to run the download.sh script in the external folder to get the necessary libraries.

More in detail:

 add a line sdl_build_root="<SDL2 path>/build-android-prefab" where the SDL path is the absolute path to the SDL2 source library, to android-prefab.sh
 and possibly correct the location of SDL_image.h, by finding expressions of the type "${sdlimage_root}/SDL_image.h" and replacing them with "${sdlimage_root}/include/SDL_image.h"


Note: Android API version of at least 29 is generally required to have access to midi via Amidi.h, so we compile everything at API version of at least 29

Of the libraries produced, we use the shard object libraries libSDL2.so and libSDL2_image.so, per architecture. 

Similarly, for the other architectures, copy into the respective architecture folders

Freetype: 

git clone https://github.com/castle-engine/android-freetype/

Edit the make file to copy the libfreetype.so library for the armeabi-v7a architecture to the correct pace at dists/android/external/armeabi-v7a, i.e. add something of the type 
	cp -f Android/libs/armeabi-v7a/libfreetype.so \
	  path/to/USDX/dists/android/external/armeabi-v7a/libfreetype.so

make build

Copy over the libfreetype.so generated to dists/android/external/armeabi-v7a and likewise the other architectures

Copy over the files in the android-freetype/include folder to dists/android/external/include/freetype (i.e. there will be among others a freetype folder nested within dists/android/external/include/freetype) 

Sqlite3

https://github.com/stockrt/sqlite3-android

cd /whereever/you/have/sqlite3-android
make

Copy over the libsqlite3.so to dists/android/external/armeabi-v7a 

To sqlite3-android/jni/Application.mk, add
APP_PLATFORM := 29

to ensure appropriate API level

To make the other architectures, edit sqlite3-android/jni/Application.mk, change the 
APP_ABI := armeabi-v7a
line to 
APP_ABI := arm64-v8a
APP_ABI := x86
APP_ABI := x86_64

You can run one after each other

Also copy over the header files sqlite3.h and sqlite3ext.h located in sqlite3-android/build to dists/android/external/include/sqlite3 


lua
https://www.lua.org/ftp/lua-5.4.6.tar.gz
https://blog.spreendigital.de/2020/05/30/how-to-compile-lua-5-4-0-for-android-as-a-dynamic-library-using-android-studio-4/

Copy over the liblua5.4.6.so to dists/android/external/armeabi-v7a (and analogously the other architectures)
Also, rename to only the major version , i.e. 5.4, during configuration, the minor version is truncated

ffmpeg
https://github.com/Javernaut/ffmpeg-android-maker

run script ffmpeg-android-maker.sh 

copy over all the library files generated in ffmpeg-android-maker/output/lib into the corresponding architectures folders in dists/android/external

copy over all the header files (in their folders) in ffmpeg-android-maker/output/include to dists/android/external/include/ffmpeg

 



portaudio
https://github.com/Gundersanne/portaudio_opensles
mkdir -p build && cd build
cmake     -DANDROID_PLATFORM=android-29     -DANDROID_ABI=armeabi-v7a     -DCMAKE_BUILD_TYPE=Debug     -DCMAKE_TOOLCHAIN_FILE=~/Library/Android/sdk/ndk/25.2.9519653/build/cmake/android.toolchain.cmake ..
make

delete the build folder and start over
mkdir -p build && cd build
cmake     -DANDROID_PLATFORM=android-29     -DANDROID_ABI=arm64-v8a     -DCMAKE_BUILD_TYPE=Debug     -DCMAKE_TOOLCHAIN_FILE=~/Library/Android/sdk/ndk/25.2.9519653/build/cmake/android.toolchain.cmake ..
make

Copy over the libportaudio.so file generated in build to the corresponding architecture


Oboe: This is the preconized alternative to the portaudio library
git clone https://github.com/google/oboe/

cd oboe

./build_all_android.sh

then copy over the liboboe.so files from the build forlder to dists/android/external/armeabi-v7a (and analogously the other architectures). Also copy over the oboe folder from the build/include folder to dists/android/external/include (i.e. there should be an oboe folder in the include directory)


fluidsynth
https://github.com/FluidSynth/fluidsynth/releases get the android release and also a windows one for the headers (the include directory)

fluidsynth also depends on libomp, which is available through the ndk kit, for example: sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/lib64/clang/14.0.7/lib/linux/x86_64/libomp.so

fluidsynth also depends on libc++_shared.so, which is available through the ndk kit, for example: sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/arm-linux-androideabi/libc++_shared.so



fluidsynth from source
git clone https://github.com/VolcanoMobile/fluidsynth-android
and build_all_android.sh
copy libfluidsynth.so as well as the include

ligbles, ligEGL: From ndk (sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/aarch64-linux-android/29 and correspondingly)

libpng: git clone https://github.com/julienr/libpng-android.git
To create dynamic libraries, change the android.mk file (i.e uncomment include $(BUILD_SHARED_LIBRARY) and comment the corresponding static library)
Also, there may be an issue with dynamic linking aginst zlib, use LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -lz to mitigate; finally, in Application.mk, add x86 for building

Copy the corresponding libpng.so files to the architectures in the dist folder




