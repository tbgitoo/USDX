# Compiling
[Free Pascal](http://freepascal.org/) 3.0.0 or newer is required to compile UltraStar Deluxe. If you had some older version of fpc installed before, make sure to remove everything of it correctly before trying to install Free Pascal (otherwise compiling will fail with various weird error messages). Also, using the newest version is suggested.
If you want to help the project by coding patches, we suggest you to use the [Lazarus 1.6](http://www.lazarus-ide.org/) or newer integrated development environment.
For linking and running the game, the following libraries are also required:
- SDL2, SDL2_image
- FFmpeg 7.0 or older
- SQLite 3
- [BASS](http://www.un4seen.com/bass.html)
- some fonts like DejaVu
- PortAudio
- Lua 5.1, 5.2, 5.3 or 5.4
- OpenCV if you want webcam support
- projectM 2,x if you want audio visualisation support

Prebuilt DLLs for SDL2, SDL2_image, FFmpeg, SQLite, PortAudio, and Lua can be found in the releases section of [our MXE fork](https://github.com/UltraStar-Deluxe/mxe). You can use the dldlls.py script to download the DLLs for the checked out code. The remaining DLLs needed for Windows builds are part of this repository.

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
* `--enable-debug`: Outputs warnings and errors from Error.log also to the console, and prints stacktraces when an EAccessViolation occurs.
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
* `--host=x86_64-w64-mingw64`: Specifically for cross-compiling to Windows 64 bit in mingw (uses the fpc crosscompiler ppcrossx64, if available, for windows 64 as there is no native fpc for this as yet


## Compiling on Linux using flatpak-builder
- The manifest for our Flathub releases is in a different repository:
  *  `git clone --recurse-submodules https://github.com/flathub/eu.usdx.UltraStarDeluxe manifest-dir`
- The Flatpak manifest uses the org.freedesktop.Platform 23.08 runtime, which is available for the major architectures on the [Flathub](https://flathub.org/repo/flathub.flatpakrepo) remote. If it isn't available for your architecture, you can lower the version in the manifest. Below 23.08 you might want to add your own build of FFmpeg and dav1d for better file format support. For some architectures the runtime is not hosted by Flathub but can be downloaded from the [Freedesktop SDK](https://releases.freedesktop-sdk.io/freedesktop-sdk.flatpakrepo) remote.
- If you change the manifest to use a USDX source tree from your hard disk, the build has to be done outside of that tree since flatpak-builder will try to copy the whole source tree into the build directory. Also note that flatpak-builder will create a hidden directory `.flatpak-builder` in the directory it was called in where downloads and build results are cached.
- Assuming you can use the Flathub remote and you didn't already add it to your flatpak configuration, you can do it with
  * `flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo`
- Then building and installing the USDX flatpak is just a matter of
  * `flatpak-builder --user --install-deps-from=flathub --install build manifest-dir/eu.usdx.UltraStarDeluxe.yaml`
- The `.flatpak-builder` and `build` directories can be removed afterwards.
- Songs must be placed in `~/.var/app/eu.usdx.UltraStarDeluxe/.ultrastardx/songs`

# Windows installer
The CI does this for you, but if you need to do it manually:
- Complete the set of DLLs in the `game` directory using a matching release from [here](https://github.com/UltraStar-Deluxe/mxe).
- Create Windows portable version: zip the contents of the `game` directory
- Create Windows installer:
  * Install NSIS (also install the Graphics and Language components during setup)
  * Copy the DLLs from `game` to `installer/dependencies/dll`
  * `C:\...\makensis "installer/UltraStar Deluxe.nsi"` (this will take a while)
  * The .exe will be placed in `installer/dist`

### Windows 64bit using MSYS2
- As of 2024, FPC for windows 64bit does not run natively but as a crosscompiler
- To specically detect this, use ./configure --host=x86_64-w64-mingw64
  
  
  # Android cross compilation
Android cross compilation needs:
- The crosscompiler. There are prebuilt binary packages for various operating systems. Otherwise, the crosscompiler can also be built from the free pascal sources at https://gitlab.com/freepascal.org/fpc/source.git, following the instructions at https://wiki.freepascal.org/Android. Depending on the platform, this needs the presence of a number of libraries. An example make command on MacOSX (12.6.6) is
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

- The Android NDK. In fact the Android NDK is already needed for making the fpc cross compiler. For compatibility reasons, the highest suitable release seems to be 19C for macosx and 21b for windows (the old versions are available at https://github.com/android/ndk/wiki/Unsupported-Downloads)

- Environment variables are also needed. For example, something like this in .bash_profile (depends where you put your variables)
`#For FPC crosscompilation armeabi-v7a, on macosx
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/arm-linux-androideabi/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-arm/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/arm-linux-androideabi/bin/ranlib

`#For FPC crosscompilation x86 on macosx
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/x86-4.9/prebuilt/darwin-x86_64/i686-linux-android/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-x86/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/i686-linux-android/bin/ranlib


`#For FPC crosscompilation aarch64=arm64-v8a on macosx
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/aarch64-linux-android/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-arm64/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/aarch64-linux-android/bin/ranlib

`#For FPC crosscompilation x86_64 on macosx
export PATH=$PATH:~/Documents/android-ndk-r19c/toolchains/x86_64-4.9/prebuilt/darwin-x86_64/x86_64-linux-android/bin:~/Documents/android-ndk-r19c/platforms/android-21/arch-x86_64/usr/lib:~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64/bin:~/FPC/pp/lib/fpc/3.3.1
export ANDROID_NDK_HOME=~/Documents/android-ndk-r19c
export RANLIB=~/Documents/android-ndk-r19c/toolchains/llvm/prebuilt/darwin-x86_64x86_64-linux-android/bin/ranlib

`In mingw, the path also needs to be extended, and ANDROID_NDK_HOME needs to be provided, but ranlib seems to be automatically chosen.


See https://lists.gnu.org/archive/html/autoconf/2013-10/msg00004.html for some discussion

A number of .so files is provided for the various android architectures in dists/android/external. These are compiled from third-party libraries. For a discussion on how to obtain these, see ANDROID_THIRDPARTY.md



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

There is also a script that builds all the architectures
./android_make_all_darwin.sh
or
./android_make_all_windows.sh


Specifically for the emulator or a device running x86:
./configure --host=x86_64-darwin --build=x86 --with-android
make android

or for debugging when everything is installed already
make android-so	


