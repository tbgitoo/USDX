# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.22.1)

# Declares and names the project.

project("ultrastardx_android")

include_directories(${CMAKE_SOURCE_DIR}/libusdx/include)
include_directories(${CMAKE_SOURCE_DIR}/../../../libs/sqlite3)

add_library (usdx SHARED IMPORTED)

set_target_properties (usdx

        PROPERTIES IMPORTED_LOCATION

        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libusdx.so)

add_library (sqlite3 SHARED IMPORTED)

set_target_properties (sqlite3

        PROPERTIES IMPORTED_LOCATION

        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libsqlite3.so)


# android logging

find_library (log-lib log)



# nodejsmobiledemo library

add_library (ultrastardx_android SHARED native-lib.cpp)

target_link_libraries (ultrastardx_android usdx ${log-lib} sqlite3)



