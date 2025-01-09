AC_DEFUN([ANDROID_PKG_HAVE],
[
    have_lib="no"
    AC_MSG_CHECKING([for $2])
    if test x"$with_[$1]" = xnocheck; then
        # do not call pkg-config, use user settings
        have_lib="yes"
    elif test x"$with_[$1]" != xno; then
        # check if package exists
        PKG_CHECK_EXISTS([dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$2.pc], [
            have_lib="yes"
            config_root_directory=$(dirname "@S|@0")
	    config_root_directory=$(realpath "$config_root_directory")
            [$1][_LIBS]=`$PKG_CONFIG --libs --silence-errors "dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$2.pc"` 
            [$1][_LIBDIRS]=`$PKG_CONFIG --libs-only-L --silence-errors "dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$2.pc"`
            [$1][_LIBDIRS]=`AX_TRIM($[$1][_LIBDIRS])`
	    [$1][_LIBDIRS]=${[$1][_LIBDIRS]//"dists/android/external"/"$config_root_directory/dists/android/external"}
	    [$1][_LIBS]=${[$1][_LIBS]//"dists/android/external"/"$config_root_directory/dists/android/external"}
	    
	    if @<:@@<:@ "x$host" = "xx86_64-windows" || "x$host" = "xx86_64-pc-windows"  @:>@@:>@; then
	       [$1][_LIBS]=${[$1][_LIBS]//\/c\//C:/}
	       [$1][_LIBDIRS]=${[$1][_LIBDIRS]//\/c\//C:/}
	       [$1][_LIBS]=${[$1][_LIBS]//\/d\//D:/}
	       [$1][_LIBDIRS]=${[$1][_LIBDIRS]//\/d\//D:/}
	       [$1][_LIBS]=${[$1][_LIBS]//\//\\}
	       [$1][_LIBDIRS]=${[$1][_LIBDIRS]//\//\\}

		
	    fi

            # add library directories to LIBS (ignore *_LIBS for now)
	    if test -n "$[$1][_LIBDIRS]"; then
                LIBS="$LIBS $[$1][_LIBDIRS]"
            fi
        ])
    fi
    if test x$have_lib = xyes; then
        [$1][_HAVE]="yes"
        if test -n "$[$1][_LIBDIRS]"; then
            # show additional lib-dirs
            AC_MSG_RESULT(yes [(]$[$1][_LIBDIRS][)])
        else
            AC_MSG_RESULT(yes)
        fi
    else
        [$1][_HAVE]="no"
        AC_MSG_RESULT(no)

        # check if package is required
        if test x$3 = xyes -o x"$with_[$1]" = xyes ; then
            # print error message and quit
            err_msg=`$PKG_CONFIG --errors-to-stdout --print-errors "$2"`
            AC_MSG_ERROR(
[

$err_msg

Alternatively, you may set --with-[$1]=nocheck and the environment
variables [$1]_[[...]] (see configure --help) 
to appropriate values to avoid the need to call pkg-config.

See the pkg-config man page for more details.
])
        fi
    fi
])




AC_DEFUN([ANDROID_PKG_VERSION],
[
    if test x$[$1][_HAVE] = xyes; then
        AC_MSG_CHECKING([version of $1])
        PKG_VALUE([$1], [VERSION], [modversion], [dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$2.pc], [version of $1])   
        AC_MSG_RESULT(@<:@$[$1][_VERSION]@:>@)
    else
        [$1][_VERSION]="0.0.0"
    fi
    AX_EXTRACT_VERSION([$1], $[$1][_VERSION])
])




# SYNOPSIS
#
#   ANDROID_PKG_VALUE(VARIABLE_PREFIX, POSTFIX, COMMAND, MODULE, HELP-STRING)
#
# DESCRIPTION
#PKG_CHECK_EXISTS
#   Calls pkg-config with a given command and stores the result.
#   If the variable was already defined by the user or the package
#   is not present on the system ([$VARIABLE_PREFIX]_HAVE <> yes) 
#   pkg-config will not be executed and the old value remains.
#   In addition the variable will be shown on "./configure --help"
#   described by a given help-string.
#
#   Parameters:
#     - VARIABLE_PREFIX: the prefix for the variables storing 
#                        information about the package.
#     - POSTFIX:         [$VARIABLE_PREFIX]_[$POSTFIX] will contain the value
#     - COMMAND:         a pkg-config command, e.g. "variable=prefix"
#     - MODULE:          the package pkg-config will retrieve info from
#     - HELP-STRING:     description of the variable
#
#   Sets:
#     [$VARIABLE_PREFIX]_[$POSTFIX]   # value (AC_SUBST)

AC_DEFUN([ANDROID_PKG_VALUE],
[
    AC_ARG_VAR([$1]_[$2], [$5, overriding pkg-config])   
    # check if variable was defined by the user
    if test -z "$[$1]_[$2]"; then
        # if not, get it from pkg-config
        if test x$[$1][_HAVE] = xyes; then
            PKG_CHECK_EXISTS([dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$4.pc],
                [[$1]_[$2]=`$PKG_CONFIG --[$3] --silence-errors "dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$4.pc"`],
                [# print error message and quit
                 err_msg=`$PKG_CONFIG --errors-to-stdout --print-errors "dists/android/external/${ANDROID_SUBFOLDER}/pkginfo/$4.pc"`
                 AC_MSG_ERROR(
[

$err_msg

If --with-[$1]=nocheck is defined the environment variable 
[$1]_[$2]
must be set to avoid the need to call pkg-config.

See the pkg-config man page for more details.
])

                ])
        fi
    fi
    AC_SUBST([$1]_[$2]) 
])
