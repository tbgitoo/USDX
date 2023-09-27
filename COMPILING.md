# Compiling
[Freepascal](http://freepascal.org/) 3.0.0 or newer is required to compile UltraStar Deluxe. If you had some older version of fpc installed before, make sure to remove everything of it correctly before trying to install freepascal (otherwise compiling will fail with various weird error messages). Also, using the 3.0-development branch with current fixes is suggested.
If you want to help the project by coding patches, we suggest you to use the [Lazarus 1.6](http://www.lazarus-ide.org/) or newer integrated development environment.
For linking and running the game, the following libraries are also required:
- SDL2, SDL2_image
- ffmpeg 2.8 or older
- sqlite
- [bass](http://www.un4seen.com/bass.html)
- some fonts like DejaVu
- portaudio
- lua 5.1 or 5.2 or 5.3
- opencv if you want webcam support
- projectM if you want audio visualisation support

## Compiling using Lazarus
1. Start Lazarus.
2. Choose Project → Open Project … in the menu bar. A file-dialog box will show.
3. Change to the src subdirectory of your USDX working copy (e.g. ultrastardx/src).
  * If you are running Windows, open the ultrastardx-win.lpi project-file (Preferably use the win32 verison of lazarus, as the included libraries are 32 bit).
  * On Unix-like systems use the ultrastardx-unix.lpi file.
4. Now you can compile USDX by choosing the menu entry Run → Build or pressing Ctrl+F9.
5. If you want to compile and/or start USDX directly choose Run → Run or press F9.

## Compiling using make
### Install prequisites
#### Linux/BSD
Required libraries:
- Debian/Ubuntu: `git automake make gcc fpc libsdl2-image-dev libavformat-dev libswscale-dev libsqlite3-dev libfreetype6-dev portaudio19-dev libportmidi-dev liblua5.3-dev libopencv-videoio-dev fonts-dejavu`
- Fedora: `git automake make gcc fpc SDL2_image-devel ffmpeg-devel sqlite-devel freetype-devel portaudio-devel portmidi-devel lua-devel opencv-devel`
- Archlinux: see the dependencies in the [ultrastardx-git](https://aur.archlinux.org/packages/ultrastardx-git) AUR package

Optional libraries:
- ProjectM visualization: `g++ libprojectm-dev` (Debian/Ubuntu) or `gcc-c++ libprojectM-devel` (Fedora)
- Webcam: `g++ libopencv-dev` (Debian/Ubuntu)

#### MacOS (High Sierra and above)
- Install Homebrew. Follow instructions from [brew.sh](http://brew.sh)
- `brew install fpc` or get it from [freepascal.org](http://www.freepascal.org/down/i386/macosx.var)
- `xcode-select --install`
- `brew install sdl2 sdl2_image automake portaudio binutils sqlite freetype lua libtiff pkg-config ffmpeg`

#### Windows using MSYS2
- Install [MSYS2](https://www.msys2.org)
- Install [FPC](https://www.freepascal.org). You need at least a custom installation with the Free Pascal Utils (for `fpcres`) and the Units.
- `pacman -S autoconf-wrapper automake-wrapper gcc git make mingw-w64-x86_64-SDL2 mingw-w64-x86_64-SDL2_gfx mingw-w64-x86_64-SDL2_image mingw-w64-x86_64-SDL2_mixer mingw-w64-x86_64-SDL2_net mingw-w64-x86_64-SDL2_ttf mingw-w64-x86_64-ffmpeg mingw-w64-x86_64-lua51 pkgconf`
- Add some information to `.bash_profile`:
  * Path to FPC, something like `PATH="${PATH}:/c/FPC/3.2.2/bin/i386-win32"`
  * Path to mingw64 libraries, `PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/mingw64/lib/pkgconfig"`

### Compile and run
- `git clone https://github.com/UltraStar-Deluxe/USDX`
- `cd USDX`
- `./autogen.sh`
- `./configure` (see optional flags below)
- `make` (on MacOS: `make macosx-standalone-app`)
- `./game/ultrastardx[.exe]` (on MacOS: `open UltraStarDeluxe.app`)

#### configure flags
* `--with-portaudio`: This is the default.
* `--without-portaudio`: Use SDL audio input instead.
  This should support newer platforms like PulseAudio and PipeWire.
  Might not be able to detect the number of channels correctly when used with PulseAudio.
  Might fix issues experienced when using PortAudio on certain distributions.
* `--without-opencv-cxx-api`: This is the default.
  OpenCV does not need to be present at build time.
  It will look for it at runtime using a deprecated C API, and enable webcam functionality if found.
  Current Linux distributions do not offer the C API.
* `--with-opencv-cxx-api`: Use OpenCV's newer C++ API.
  Required for webcam support under Linux, but requires OpenCV to be present at both build time as well as runtime.

## Compiling on Linux using flatpak-builder
- The Flatpak manifest uses the org.freedesktop.Platform 20.08 runtime, which is available for the major architectures on the [Flathub](https://flathub.org/repo/flathub.flatpakrepo) remote. If it isn't available for your architecture, you can lower the version in the manifest. Below 19.08 you either need to enable the dav1d module or disable AV1 support in the ffmpeg module by removing the --enable-libdav1d configure option. For some architectures the runtime is not hosted by Flathub but can be downloaded from the [Freedesktop SDK](https://releases.freedesktop-sdk.io/freedesktop-sdk.flatpakrepo) remote.
- The build has to be done outside of the USDX source code tree since flatpak-builder will to copy the whole source tree into the build directory. Also note that flatpak-builder will create a hidden directory `.flatpak-builder` in the directory it was called in where downloads and build results are cached.
- Assuming you can use the Flathub remote and you didn't already add it to your flatpak configuration, you can do it with
  * `flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo`
- Then building and installing the USDX flatpak is just a matter of
  * `flatpak-builder --user --install-deps-from=flathub --install build $USDX_SOURCE_TREE/dists/flatpak/eu.usdx.UltraStarDeluxe.yaml`
- The `.flatpak-builder` and `build` directories can be removed afterwards.
- Songs must be placed in `~/.var/app/eu.usdx.UltraStarDeluxe/.ultrastardx/songs`

# Windows installer
The CI does this for you, but if you need to do it manually:
- Create Windows portable version: zip the contents of the `game` directory
- Create Windows installer:
  * Install NSIS (also install the Graphics and Language components during setup)
  * Copy the DLLs from `game` to `installer/dependencies/dll`
  * `C:\...\makensis "installer/UltraStar Deluxe.nsi"` (this will take a while)
  * The .exe will be placed in `installer/dist`
  
  
  # Android cross compilation
Android cross compilation needs:
- The crosscompiler. The crosscompiler can be built from the free pascal sources at https://gitlab.com/freepascal.org/fpc/source.git, following the instructions at https://wiki.freepascal.org/Android. Depending on the platform, this needs the presence of a number of libraries. An example make command on MacOSX (12.6.6) is
  For arm-v7a
  `make clean crossall crossinstall OS_TARGET=android CPU_TARGET=arm COMPILER_LIBRARYDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib FPCMAKEGCCLIBDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib INSTALL_PREFIX=~/FPC/pp`
  - For x86
  `make crossall crossinstall OS_TARGET=android CPU_TARGET=i386 COMPILER_LIBRARYDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib FPCMAKEGCCLIBDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib INSTALL_PREFIX=~/FPC/pp`
  - For arm64
    `make crossall crossinstall OS_TARGET=android CPU_TARGET=aarch64 COMPILER_LIBRARYDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib FPCMAKEGCCLIBDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib INSTALL_PREFIX=~/FPC/pp`
   - For x86_64
    `make crossall crossinstall OS_TARGET=android CPU_TARGET=x86_64 COMPILER_LIBRARYDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib FPCMAKEGCCLIBDIR=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib INSTALL_PREFIX=~/FPC/pp`
    
- Building the cross-compiler can be a bit tricky. On MacOSX (12.6.6), there can be minor issues in the make file and some sources of the fpc source for crosscompilation. 
* In the makefile add somewhere arround line 500, add
`ifdef COMPILER_LIBRARYDIR
override OPT+=$(addprefix -Fl,$(COMPILER_LIBRARYDIR))
endif`
* There also seems to be an error in compiler/options.pas, replace line 886 by
`Assign(xmloutput,Copy(More,2,Length(More)));`

- The Android NDK. In fact the Android NDK is already needed for making the fpc cross compiler. For compatibility reasons, the highest suitable release seems to be 19C (the old versions are available at https://github.com/android/ndk/wiki/Unsupported-Downloads)

- Environment variables are also needed. For example, something like this in .bash_profile (depends where you put your variables)
`#For FPC crosscompilation armeabi-v7a
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/arm-linux-androideabi/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-arm/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/arm-linux-androideabi/bin/ranlib

`#For FPC crosscompilation x86
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/x86-4.9/prebuilt/darwin-x86_64/i686-linux-android/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-x86/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/i686-linux-android/bin/ranlib


`#For FPC crosscompilation aarch64=arm64-v8a
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/aarch64-linux-android/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-arm64/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/aarch64-linux-android/bin/ranlib

`#For FPC crosscompilation x86_64
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/x86_64-4.9/prebuilt/darwin-x86_64/x86_64-linux-android/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-x86_64/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64x86_64-linux-android/bin/ranlib


See https://lists.gnu.org/archive/html/autoconf/2013-10/msg00004.html for some discussion


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
 


or similar depending on what the architecture and version. Android API version of at least 29 is generally required to have access to midi via Amidi.h, so we compile everything at API version of at least 29

Of the libraries produced, we use the shard object libraries libSDL2.so and libSDL2_image.so, as well as the static archive libraries libcpufeatures.a, libjpeg.a, and libpng.a. These are produced in the liball folder, and should be copied over to dists/android/external/armeabi-v7a for the .so files, and libcpufeatures.a, libjpeg.a and libpng.a to dists/android/external/armeabi-v7a/lib

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

#USDX

./autogen.sh
autoconf -f
./configure --host=x86_64-darwin --build=arm --with-android
make android
`


And for the other architectures, that's
./configure --host=x86_64-darwin --build=aarch64 --with-android
./configure --host=x86_64-darwin --build=x86 --with-android
./configure --host=x86_64-darwin --build=x86_64 --with-android


