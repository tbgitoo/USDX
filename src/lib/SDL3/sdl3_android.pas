unit SDL3_Android;


interface

  uses
    jni,
    SDL3;






  procedure Java_com_android_gl2jni_SDLJNILib_onNativeMouse(vm:PJavaVM;reserved:pointer; button,action: jint; x,y: jfloat; relative:jboolean); cdecl;


  procedure Java_com_android_gl2jni_SDLJNILib_nativeSetNaturalOrientation(vm:PJavaVM;reserved:pointer; orientation:jint); cdecl;


  procedure Java_com_android_gl2jni_SDLJNILib_onNativeRotationChanged(vm:PJavaVM;reserved:pointer; rotation:jint); cdecl;











implementation

uses
  UJniCallback;

  procedure Java_com_android_gl2jni_SDLJNILib_onNativeMouse(vm:PJavaVM;reserved:pointer; button,action: jint; x,y: jfloat; relative:jboolean); cdecl;
  begin
      debug_message_to_android('mouse_coucou');
  end;

  procedure Java_com_android_gl2jni_SDLJNILib_nativeSetNaturalOrientation(vm:PJavaVM;reserved:pointer; orientation:jint); cdecl;
  begin

  end;

  procedure Java_com_android_gl2jni_SDLJNILib_onNativeRotationChanged(vm:PJavaVM;reserved:pointer; rotation:jint); cdecl;
  begin

  end;



end.
