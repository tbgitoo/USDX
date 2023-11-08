unit SDL3_Android;


interface

  uses
    jni,
    SDL3;









  procedure Java_org_libsdl_app_SDLActivity_onNativeMouse(vm:PJavaVM;reserved:pointer; button,action: jint; x,y: jfloat; relative:jboolean); cdecl;


  procedure Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation(vm:PJavaVM;reserved:pointer; orientation:jint); cdecl;


  procedure Java_org_libsdl_app_SDLActivity_onNativeRotationChanged(vm:PJavaVM;reserved:pointer; rotation:jint); cdecl;

  function Java_org_libsdl_app_SDLActivity_nativeSetupJNI(vm:PJavaVM;reserved:pointer): jint; cdecl; external SDL_LibName  name 'Java_org_libsdl_app_SDLActivity_nativeSetupJNI';

  //function Android_JNI_GetNativeWindow(): PANativeWindow; cdecl; external 'libnativewindow.so'  name 'Android_JNI_GetNativeWindow';









implementation

uses
  UJniCallback;

  procedure __Java_org_libsdl_app_SDLActivity_onNativeMouse(button,action: UInt32; x,y: Float; relative:Boolean) cdecl; external SDL_LibName  name 'Java_org_libsdl_app_SDLActivity_onNativeMouse';

  procedure __Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation(vm:PJavaVM;reserved:pointer; orientation: SInt32) cdecl; external SDL_LibName  name 'Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation';




  procedure Java_org_libsdl_app_SDLActivity_onNativeMouse(vm:PJavaVM;reserved:pointer; button,action: jint; x,y: jfloat; relative:jboolean); cdecl;
  begin
      __Java_org_libsdl_app_SDLActivity_onNativeMouse(button,action,x,y,Boolean(relative));
  end;

  procedure Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation(vm:PJavaVM;reserved:pointer; orientation:jint); cdecl;
  begin
     //__Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation(vm,reserved,orientation);
  end;

  procedure Java_org_libsdl_app_SDLActivity_onNativeRotationChanged(vm:PJavaVM;reserved:pointer; rotation:jint); cdecl;
  begin

  end;



end.
