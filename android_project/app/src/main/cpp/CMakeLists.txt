# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.22.1)

# Declares and names the project.

project("ultrastardx_android")

include_directories(${CMAKE_SOURCE_DIR}/libusdx/include)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/sqlite3)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/sdl2)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/fluidsynth)


add_library (usdx SHARED IMPORTED)

set_target_properties (usdx
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libusdx.so)


add_library (sqlite3 SHARED IMPORTED)
set_target_properties (sqlite3
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libsqlite3.so)

add_library (sdl2 SHARED IMPORTED)
set_target_properties (sdl2
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libSDL2.so)

add_library (sdl2_image SHARED IMPORTED)
set_target_properties (sdl2_image
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libSDL2_image.so)

add_library (freetype SHARED IMPORTED)
set_target_properties (freetype
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libfreetype.so)

add_library (portaudio SHARED IMPORTED)
set_target_properties (portaudio
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libportaudio.so)

add_library (avcodec SHARED IMPORTED)
set_target_properties (avcodec
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libavcodec.so)

add_library (avformat SHARED IMPORTED)
set_target_properties (avformat
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libavformat.so)

add_library (avutil SHARED IMPORTED)
set_target_properties (avutil
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libavutil.so)

add_library (swresample SHARED IMPORTED)
set_target_properties (swresample
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libswresample.so)

add_library (swscale SHARED IMPORTED)
set_target_properties (swscale
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libswscale.so)

add_library (lua SHARED IMPORTED)
set_target_properties (lua
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/liblua5.4.6.so)

add_library (fluidsynth SHARED IMPORTED)
set_target_properties (fluidsynth
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libfluidsynth.so)
# Dependencies of libfluidsynth
add_library (omp SHARED IMPORTED)
set_target_properties (omp
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libomp.so)


add_library (glib SHARED IMPORTED)
set_target_properties (glib
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libglib-2.0.so)

add_library (gthread SHARED IMPORTED)
set_target_properties (gthread
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libgthread-2.0.so)

add_library (sndfile SHARED IMPORTED)
set_target_properties (sndfile
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libsndfile.so)

add_library (instpatch SHARED IMPORTED)
set_target_properties (instpatch
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libinstpatch-1.0.so)

add_library (gobject SHARED IMPORTED)
set_target_properties (gobject
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libgobject-2.0.so)

add_library (cpp_shared SHARED IMPORTED)
set_target_properties (cpp_shared
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libc++_shared.so)


add_library (pcre SHARED IMPORTED)
set_target_properties (pcre
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libpcre.so)

add_library (vorbisenc SHARED IMPORTED)
set_target_properties (vorbisenc
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libvorbisenc.so)

add_library (flac SHARED IMPORTED)
set_target_properties (flac
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libFLAC.so)

add_library (opus SHARED IMPORTED)
set_target_properties (opus
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libopus.so)

add_library (vorbis SHARED IMPORTED)
set_target_properties (vorbis
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libvorbis.so)

add_library (ogg SHARED IMPORTED)
set_target_properties (ogg
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libogg.so)


# android logging

find_library (log-lib log)



# compilation of the main loop library for sdl

add_library (main SHARED main.cpp)

# System libraries are generally not accessible in Android and
# so we need to include almost everything explicitly
target_link_libraries (
        main
        usdx
        ${log-lib}
        sqlite3
        sdl2
        sdl2_image
        freetype
        portaudio
        avcodec
        avformat
        avutil
        swresample
        swscale
        lua
        fluidsynth
        omp
        glib
        gthread
        sndfile
        instpatch
        gobject
        cpp_shared
        pcre
        vorbisenc
        flac
        opus
        vorbis
        ogg
        EGL
        GLESv1_CM
)



