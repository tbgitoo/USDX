# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.22.1)

# Declares and names the project.

project("ultrastardx_android")

include_directories(${CMAKE_SOURCE_DIR}/libusdx/include)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/sqlite3)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/sdl2)

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



# android logging

find_library (log-lib log)



# nodejsmobiledemo library

add_library (ultrastardx_android SHARED native-lib.cpp)

target_link_libraries (
        ultrastardx_android
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
)



