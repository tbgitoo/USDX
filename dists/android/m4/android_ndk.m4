# Thomas Braschler

# SYNOPSIS
#
#   AC_PROG_ANDROID_NDK
#
# DESCRIPTION
#
#   Checks for suitable Android NDK files
#
#   Sets:
#     ANDROID_NDK_ROOT  
#     ANDROID_NDK_LIB: usr/lib directory in the android ndk with necessary binaries
#     ANDROID_NDK_LEVEL: 29 
#     ANDROID_ARCH
#     ANDROID_ARCH_VERSION
#     ANDROID_SUBFOLDER: in dist/android/external

#
#     Note: 
#       Expects environment ANDROID_NDK_HOME variable to be set, if no directory
#	is supplied as an argument to AC_PROG_ANDROID_NDK 
#       If necessary, do
#       export ANDROID_NDK_HOME=/path/to/your/NDK


AC_DEFUN([AC_PROG_ANDROID_NDK], [

##
# User PFLAGS
##

AC_ARG_VAR(ANDROID_LEVEL, [Android language level])


# Android NDK root path
# Preferred: NDK root is set explicitly

ANDROID_NDK_ROOT=`echo $ANDROID_NDK_HOME`

echo "Android NDK HOME environment variable: $ANDROID_NDK_HOME"

# if it is not explicitly set, try to find wether a default ndk-build
# executable is set
if test -z "$ANDROID_NDK_ROOT"; then
  ANDROID_NDK_ROOT=`echo $(dirname $(which ndk-build))`
fi

# otherwise try to get it from path

if test -z "$ANDROID_NDK_ROOT"; then
  ANDROID_NDK_ROOT=`echo $PATH | egrep -o    ":[^:]*?android-ndk-[^:]*?/" | head -n 1`
  ANDROID_NDK_ROOT=`echo ${ANDROID_NDK_ROOT:1} | sed 's/.\{1\}$//'`
fi


# Explicit override: ndk from the argument to the configure script
AC_ARG_WITH(ndk,
  [AS_HELP_STRING([--with-ndk=DIR],
    [Directory of the NDK @<:@PATH@:>@])],
  [ANDROID_NDK_ROOT=$withval], [])

if test -z "$ANDROID_NDK_ROOT"; then
   AC_MSG_ERROR([Android NDK kit not found])
fi


ANDROID_NDK_LEVEL=29
AC_ARG_WITH(androidlevel,
  [AS_HELP_STRING([--with-androidlevel=LEVEL],
    [Android language level, at least 29 is needed for midi support; only relevant when compiling for Android])],
  [ANDROID_NDK_LEVEL=$withval], [])


ANDROID_NDK_LIB=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${host-os}-${host-cpu}/sysroot/usr/lib

if @<:@ ! -d "$ANDROID_NDK_LIB" @:>@; then
ANDROID_NDK_LIB=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${host-os}/sysroot/usr/lib
fi

if @<:@ ! -d "$ANDROID_NDK_LIB" @:>@; then
ANDROID_NDK_LIB=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${host-cpu}/sysroot/usr/lib
fi









ANDROID_ARCH=arm
ANDROID_ARCH_VERSION=v7a
ANDROID_SUBFOLDER="armeabi-v7a"


if [[ "$build" = "armv8a-unknown-none" ]]; then
  ANDROID_ARCH="aarch64"
  ANDROID_ARCH_VERSION=v8a
  ANDROID_SUBFOLDER="arm64-v8a"
fi

if [[ "$build" = "aarch64-none-linux-android29" ]]; then
  ANDROID_ARCH="aarch64"
  ANDROID_ARCH_VERSION=v8a
  ANDROID_SUBFOLDER="arm64-v8a"
fi

if [[ "$build" = "aarch64-unknown-none" ]]; then
  ANDROID_ARCH="aarch64"
  ANDROID_ARCH_VERSION=v8a
  ANDROID_SUBFOLDER="arm64-v8a"
fi

if [[ "$build" = "aarch64" ]]; then
  ANDROID_ARCH="aarch64"
  ANDROID_ARCH_VERSION=v8a
  ANDROID_SUBFOLDER="arm64-v8a"
fi

if [[ "$build" = "x86-unknown-none" ]]; then
  ANDROID_ARCH=x86
  ANDROID_ARCH_VERSION=NONE
  ANDROID_SUBFOLDER="x86"
fi

if [[ "$build" = "x86" ]]; then
  ANDROID_ARCH=x86
  ANDROID_ARCH_VERSION=NONE
  ANDROID_SUBFOLDER="x86"
fi



if [[ "$build" = "x86_64-pc-none" ]]; then
  ANDROID_ARCH=x86_64
  ANDROID_ARCH_VERSION=NONE
  ANDROID_SUBFOLDER="x86_64"
fi

if [[ "$build" = "x86_64" ]]; then
  ANDROID_ARCH=x86_64
  ANDROID_ARCH_VERSION=NONE
  ANDROID_SUBFOLDER="x86_64"
fi


if @<:@ ! -d "$ANDROID_NDK_LIB" @:>@; then
ANDROID_NDK_LIB=${ANDROID_NDK_ROOT}/platforms/android-${ANDROID_NDK_LEVEL}
if @<:@ -d "$ANDROID_NDK_LIB" @:>@; then
  ANDROID_NDK_LIB_ROOT=$ANDROID_NDK_LIB
  if [[ "x$ANDROID_SUBFOLDER" = "xarmeabi-v7a" ]]; then
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/armeabi-v7a" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/armeabi-v7a"
     fi
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/arch-arm" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/arch-arm"
     fi
  fi
  if [[ "x$ANDROID_SUBFOLDER" = "xarm64-v8a" ]]; then
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/arm64-v8a" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/arm64-v8a"
     fi
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/arch-arm64" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/arch-arm64"
     fi
  fi
  if [[ "x$ANDROID_SUBFOLDER" = "xx86" ]]; then
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/x86" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/x86"
     fi
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/arch-x86" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/arch-x86"
     fi
  fi
  if [[ "x$ANDROID_SUBFOLDER" = "xx86_64" ]]; then
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/x86_64" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/x86_64"
     fi
     if @<:@ -d "${ANDROID_NDK_LIB_ROOT}/arch-x86_64" @:>@; then
        ANDROID_NDK_LIB="${ANDROID_NDK_LIB_ROOT}/arch-x86_64"
     fi
  fi
fi
fi


if @<:@@<:@ "x$host" = "xx86_64-windows" || "x$host" = "xx86_64-pc-windows"  @:>@@:>@; then
	       ANDROID_NDK_LIB=${ANDROID_NDK_LIB//\/c\//C:/}
               ANDROID_NDK_LIB=${ANDROID_NDK_LIB//\/d\//D:/}
	       ANDROID_NDK_LIB=${ANDROID_NDK_LIB//\//\\}
fi

echo "Android sysroot library: $ANDROID_NDK_LIB"



AC_SUBST(ANDROID_SUBFOLDER)






])

