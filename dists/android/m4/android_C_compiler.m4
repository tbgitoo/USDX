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
#     Note: 
#       The C compilers in the NDK are a bit obscure, this is a bit experimental


AC_DEFUN([AC_PROG_ANDROID_CC], [

##
# User PFLAGS
##

AC_PROG_CC([armv7a-linux-androideabi21-clang])


])

