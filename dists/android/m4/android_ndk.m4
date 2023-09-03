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
#     ANDROID_NDK_LEVEL: 21 
#     ANDROID_ARCH
#     ANDROID_ARCH_VERSION

#
#     Note: 
#       Expects environment ANDROID_NDK_HOME variable to be set, if no directory
#	is supplied as an argument to AC_PROG_ANDROID_NDK 
#       If necessary, do
#       export ANDROID_NDK_HOME=/path/to/your/NDK
#	because of subsequent changes, the highest ndk that seems to work for 
#	cross-compliation is R19C


AC_DEFUN([AC_PROG_ANDROID_NDK], [

##
# User PFLAGS
##

AC_ARG_VAR(ANDROID_LEVEL, [Android language level])


# Android NDK root path
# Preferred: NDK root is set explicitly

ANDROID_NDK_ROOT=`echo $ANDROID_NDK_HOME`

# otherwise try to get it from path

if test -z "$ANDROID_NDK_ROOT"; then
  ANDROID_NDK_ROOT=`echo $PATH | egrep -o    ":[^:]*?android-ndk-[^:]*?/" | head -n 1`
  ANDROID_NDK_ROOT=`echo ${ANDROID_NDK_ROOT:1} | sed 's/.\{1\}$//'`
fi


AC_ARG_WITH(ndk,
  [AS_HELP_STRING([--with-ndk=DIR],
    [Directory of the NDK @<:@PATH@:>@])],
  [ANDROID_NDK_ROOT=$withval], [])

if test -z "$ANDROID_NDK_ROOT"; then
   AC_MSG_ERROR([Android NDK kit not found])
fi

ANDROID_NDK_LEVEL=21

ANDROID_NDK_LIB=${ANDROID_NDK_ROOT}/platforms/android-${ANDROID_NDK_LEVEL}/arch-arm/usr/lib

echo $ANDROID_NDK_LIB


ANDROID_ARCH=arm
ANDROID_ARCH_VERSION=v7a


])

