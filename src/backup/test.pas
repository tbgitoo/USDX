library test;

{$IFDEF MSWINDOWS}
  {$R '..\res\link.res' '..\res\link.rc'}
{$ENDIF}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

{$IFDEF MSWINDOWS}
  // Set global application-type (GUI/CONSOLE) switch for Windows.
  // CONSOLE is the default for FPC, GUI for Delphi, so we have
  // to specify one of the two in any case.
  {$IFDEF CONSOLE}
    {$APPTYPE CONSOLE}
  {$ELSE}
    {$APPTYPE GUI}
  {$ENDIF}
{$ENDIF}



uses
  //heaptrc,
  {$IFDEF Unix}
  cthreads,            // THIS MUST be the first used unit in FPC if Threads are used!!
                       // (see http://wiki.lazarus.freepascal.org/Multithreaded_Application_Tutorial)
  cwstring,            // Enable Unicode support
  {$ENDIF}

  {$IFNDEF FPC}
  ctypes                 in 'lib\ctypes\ctypes.pas', // FPC compatibility types for C libs
  {$ENDIF}

  jni,   // For communication with Android Java

  UJniCallback            in 'jni\UJniCallback.pas',

  SysUtils,

  dglOpenGLES   in 'lib\dglOpenGL\dglOpenGLES.pas',

  SDL3 in 'lib\SDL3\sdl3.pas',

  SDL3_Android in 'lib\SDL3\sdl3_android.pas';





var gvPositionHandle, gProgram: GLuint;
    grey: GLfloat;
    gTriangleVertices: array[0..5] of GLfloat = (0.0, 0.5, -0.5, -0.5, 0.5, -0.5);


function setupGraphics(w,h: integer): boolean;
    var gVertexShader, gFragmentShader : String;
    begin
      printGLString('Version', GL_VERSION);
      printGLString('Vendor', GL_VENDOR);
      printGLString('Renderer', GL_RENDERER);
      printGLString('Extensions', GL_EXTENSIONS);
      {$IF Defined(ANDROID)}
          debug_message_to_android('setupGraphics('+IntToStr(w)+', '+IntToStr(h)+')');
      {$IFEND}

      gVertexShader:='attribute vec4 vPosition; '+
        'void main() { '+
        '  gl_Position = vPosition; '+
        '} ';


      gFragmentShader :=
        'precision mediump float; '+
        'void main() { '+
        '  gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0); '+
        '} ';

      gProgram := createProgram(gVertexShader, gFragmentShader);
      if gProgram = 0 then begin
      {$IF Defined(ANDROID)}
          debug_message_to_android('Could not create program.');
      {$IFEND}
       exit(False);
       end;
      gvPositionHandle := glGetAttribLocation(gProgram, 'vPosition');
      checkGlError('glGetAttribLocation');

      glViewport(0, 0, w, h);
      {$IF Defined(ANDROID)}
          debug_message_to_android('glViewport');
      {$IFEND}
      checkGlError('glViewport');
      setupGraphics:=True;
      if SDL_Init(SDL_INIT_VIDEO)>=0 then
         debug_message_to_android('SDL init failed with error'+SDL_GetError())
      else
         debug_message_to_android('SDL_INIT: Initialized video system successfully');


    end;

procedure renderFrame();
begin
  grey := grey+0.01;
  if grey > 1 then grey:=0;

  glClearColor(grey, grey, grey, 1.0);
  checkGlError('glClearColor');
  glClear(GL_DEPTH_BUFFER_BIT + GL_COLOR_BUFFER_BIT);
  checkGlError('glClear');
  glUseProgram(gProgram);
  checkGlError('glUseProgram');

  glVertexAttribPointer(gvPositionHandle, 2, GL_FLOAT, Bytebool(GL_FALSE), 0,
                        @gTriangleVertices[0]);
  checkGlError('glVertexAttribPointer');
  glEnableVertexAttribArray(gvPositionHandle);
  checkGlError('glEnableVertexAttribArray');
  glDrawArrays(GL_TRIANGLES, 0, 3);
  checkGlError('glDrawArrays');
end;

procedure Java_com_android_gl2jni_GL2JNILib_init(vm:PJavaVM;reserved:pointer; width,height:jint); cdecl;
  begin
    setupGraphics(width, height);
  end;

  procedure Java_com_android_gl2jni_GL2JNILib_step(vm:PJavaVM;reserved:pointer; width,height:jint); cdecl;
  begin
    renderFrame();
  end;


exports Java_com_android_gl2jni_GL2JNILib_init name 'Java_com_android_gl2jni_GL2JNILib_init';

exports Java_com_android_gl2jni_GL2JNILib_step name 'Java_com_android_gl2jni_GL2JNILib_step';


exports Java_com_android_gl2jni_SDLJNILib_onNativeMouse name 'Java_com_android_gl2jni_SDLJNILib_onNativeMouse';

exports Java_com_android_gl2jni_SDLJNILib_nativeSetNaturalOrientation name 'Java_com_android_gl2jni_SDLJNILib_nativeSetNaturalOrientation';
exports Java_com_android_gl2jni_SDLJNILib_onNativeRotationChanged name 'Java_com_android_gl2jni_SDLJNILib_onNativeRotationChanged';



exports JNI_OnLoad name 'JNI_OnLoad';





begin

end.
