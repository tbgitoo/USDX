cmake_minimum_required(VERSION 3.4.1)

# now build app's shared lib
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

include_directories(${CMAKE_SOURCE_DIR}/libusdx/include)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/include/SDL3)


add_library (USDX SHARED IMPORTED)

set_target_properties (USDX
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libUSDX.so)

add_library (SDL3 SHARED IMPORTED)
set_target_properties (SDL3
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libSDL3.so)

add_library (sdl3_image SHARED IMPORTED)
set_target_properties (sdl3_image
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libSDL3_image.so)

add_library (sqlite3 SHARED IMPORTED)
set_target_properties (sqlite3
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libsqlite3.so)

add_library (lua SHARED IMPORTED)
set_target_properties (lua
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/liblua5.4.6.so)

add_library (fluidsynth SHARED IMPORTED)
set_target_properties (fluidsynth
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libfluidsynth.so)

add_library (cplusplus SHARED IMPORTED)
set_target_properties (cplusplus
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/lib/libc++_shared.so)

add_library (avformat SHARED IMPORTED)
set_target_properties (avformat
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libavformat.so)


add_library (avcodec SHARED IMPORTED)
set_target_properties (avcodec
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libavcodec.so)


add_library (avutil SHARED IMPORTED)
set_target_properties (avutil
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libavutil.so)

add_library (swresample SHARED IMPORTED)
set_target_properties (swresample
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libswresample.so)

add_library (freetype SHARED IMPORTED)
set_target_properties (freetype
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libfreetype.so)

add_library (swscale SHARED IMPORTED)
set_target_properties (swscale
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libswscale.so)



add_library(gl2jni SHARED
            gl_code.cpp)

# add lib dependencies
target_link_libraries(gl2jni
                      USDX
                      android
                      log 
                      EGL
                      GLESv3
                      SDL3
                      sdl3_image
                      sqlite3
                      lua
                      fluidsynth
                      cplusplus
                      avformat
                      avcodec
                      avutil
                      swresample
                      freetype
                      swscale)

