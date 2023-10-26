cmake_minimum_required(VERSION 3.4.1)

# now build app's shared lib
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

include_directories(${CMAKE_SOURCE_DIR}/libusdx/include)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/include/SDL3)


add_library (test SHARED IMPORTED)

set_target_properties (test
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libtest.so)

add_library (SDL3 SHARED IMPORTED)
set_target_properties (SDL3
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libSDL3.so)

add_library (sdl3_image SHARED IMPORTED)
set_target_properties (sdl3_image
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libSDL3_image.so)


add_library(gl2jni SHARED
            gl_code.cpp)

# add lib dependencies
target_link_libraries(gl2jni
                      test
                      android
                      log 
                      EGL
                      GLESv2
                      SDL3
                      sdl3_image)

