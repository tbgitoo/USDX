# Thomas Braschler

# SYNOPSIS
#
#   AC_PROG_ANDROID_CC
#
# DESCRIPTION
#
#   Checks for the Android C compiler
#
#   Sets:
#     CC    
#     
#
#     Note: 
#       The C compilers in the NDK are a bit obscure, this is a bit experimental


AC_DEFUN([AC_PROG_ANDROID_CC], [



if [[ "$ANDROID_ARCH" = "aarch64" ]]; then
	AC_PROG_CC([${ANDROID_ARCH}-linux-android$ANDROID_NDK_LEVEL-clang])
fi
if [[ "$ANDROID_ARCH" = "arm" ]]; then
	AC_PROG_CC([$ANDROID_ARCH$ANDROID_ARCH_VERSION-linux-androideabi$ANDROID_NDK_LEVEL-clang])
fi
if [[ "$ANDROID_ARCH" = "x86" ]]; then
	AC_PROG_CC([i686-linux-android$ANDROID_NDK_LEVEL-clang])
fi
if [[ "$ANDROID_ARCH" = "x86_64" ]]; then
	AC_PROG_CC([x86_64-linux-android$ANDROID_NDK_LEVEL-clang])
fi


])



AC_DEFUN([AC_PROG_ANDROID_CXX], [

##
# User PFLAGS
##

if [[ "$ANDROID_ARCH" = "aarch64" ]]; then
	AC_PROG_CC([${ANDROID_ARCH}-linux-android$ANDROID_NDK_LEVEL-clang++])
fi
if [[ "$ANDROID_ARCH" = "arm" ]]; then
	AC_PROG_CC([$ANDROID_ARCH$ANDROID_ARCH_VERSION-linux-androideabi$ANDROID_NDK_LEVEL-clang++])
fi
if [[ "$ANDROID_ARCH" = "x86" ]]; then
	AC_PROG_CC([i686-linux-android$ANDROID_NDK_LEVEL-clang++])
fi
if [[ "$ANDROID_ARCH" = "x86_64" ]]; then
	AC_PROG_CC([x86_64-linux-android$ANDROID_NDK_LEVEL-clang++])
fi


])

