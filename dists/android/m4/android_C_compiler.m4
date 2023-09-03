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

##
# User PFLAGS
##

AC_PROG_CC([$ANDROID_ARCH$ANDROID_ARCH_VERSION-linux-androideabi$ANDROID_NDK_LEVEL-clang])


])

AC_DEFUN([AC_PROG_ANDROID_CXX], [

##
# User PFLAGS
##

AC_PROG_CXX([$ANDROID_ARCH$ANDROID_ARCH_VERSION-linux-androideabi$ANDROID_NDK_LEVEL-clang++])


])

