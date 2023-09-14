SEARCH_DIR(/Users/thomasbraschler/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/arm-linux-androideabi/29/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/rtl/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/fcl-base/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/rtl-objpas/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/pasjpeg/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/hash/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/jni/)
SEARCH_DIR(/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/)
VERSION
{
  {
    local:
      *;
  };
}
INPUT(
/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/rtl/prt0.o
/Users/thomasbraschler/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/arm-linux-androideabi/29/crtbegin_dynamic.o
conftest.o
/Users/thomasbraschler/FPC/pp/lib/fpc/3.3.1/units/aarch64-android/rtl/system.o
)
INPUT(
-lc
-llog
)
GROUP(
-lc
)
INPUT(
/Users/thomasbraschler/Library/Android/sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/arm-linux-androideabi/29/crtend_android.o
)
SECTIONS
{
  .data           :
  {
    KEEP (*(.fpc .fpc.n_version .fpc.n_links))
  }
}
INSERT AFTER .data1
FPC_JNI_ON_LOAD = 0;
FPC_LIB_MAIN_ANDROID = PASCALMAIN;
