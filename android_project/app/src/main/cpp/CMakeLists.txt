# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.22.1)

# Declares and names the project.

project("sdl2_native")

set(SOURCE_FILES ${CMAKE_SOURCE_DIR}/main.cpp ${CMAKE_SOURCE_DIR}/glad/glad.c)

add_library( main SHARED ${SOURCE_FILES} )



target_include_directories(
        main PUBLIC
        ${CMAKE_SOURCE_DIR}/../../../libs/include/SDL2/${ANDROID_ABI}
        ${CMAKE_SOURCE_DIR}/../../../libs/include/SDL2_image/${ANDROID_ABI}
)

add_library (SDL2 SHARED IMPORTED)
set_target_properties (SDL2
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI}/libSDL2.so)

add_library (SDL2_IMAGE SHARED IMPORTED)
set_target_properties (SDL2_IMAGE
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI}/libSDL2_image.so)

add_library (HIDAPI SHARED IMPORTED)
set_target_properties (HIDAPI
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI}/libhidapi.so)

add_library (USB SHARED IMPORTED)
set_target_properties (USB
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI}/libusb1.0.so)

add_library (LUA SHARED IMPORTED)
set_target_properties (LUA
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI}/liblua.so)




# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
        log-lib

        # Specifies the name of the NDK library that
        # you want CMake to locate.
        log)




# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
        main

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib}

        SDL2
        SDL2_IMAGE
        HIDAPI
        USB
        LUA
        GLESv1_CM
        )