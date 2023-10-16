cmake_minimum_required(VERSION 3.4.1)

# now build app's shared lib
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

include_directories(${CMAKE_SOURCE_DIR}/libusdx/include)

add_library (test SHARED IMPORTED)

set_target_properties (test
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/../../../libs/${CMAKE_ANDROID_ARCH_ABI}/libtest.so)


add_library(gl2jni SHARED
            gl_code.cpp)

# add lib dependencies
target_link_libraries(gl2jni
                      test
                      android
                      log 
                      EGL
                      GLESv2)

