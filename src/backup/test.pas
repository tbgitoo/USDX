

library test;

{$IFDEF MSWINDOWS}
  {$R '..\res\link.res' '..\res\link.rc'}
{$ENDIF}

{$IFDEF FPC}
  {$MODE OBJFPC}
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

    Screen: PSDL_Window;
    window: TSDL_Window;
    gl: TSDL_GLContext;

    screenSurface: PSDL_Surface;
    gVertexShader : String;
    gFragmentShader : String;


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


function SDL_main(argc: integer; argv: PPChar): integer;
var

    displayID: TSDL_DisplayID;
    displayMode: TSDL_DisplayMode;







    ind : integer;

    go_on: boolean;

    e: TSDL_Event;



    vao: GLUint;
    vbo: GLUint;
    vertices: array[1..9] of GLFloat =( -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0);

    vertex_length: GLsizei;

    vs,fs : GLUint;


begin

    gFragmentShader :=
        'precision mediump float; '+
        'void main() { '+
        '  gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0); '+
        '} ';




    gVertexShader := 'attribute vec4 vPosition; '+
        'void main() { '+
        '  gl_Position = vPosition; '+
        '} ';

  if(SDL_Init(SDL_INIT_VIDEO)<0) then exit(1);
  SDL_main:=0;

   SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);


   SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK,    SDL_GL_CONTEXT_PROFILE_ES);

   SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
   SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

   SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL,1);

   displayID:=SDL_GetPrimaryDisplay();
   displayMode:=SDL_GetCurrentDisplayMode(displayID)^;

   debug_message_to_android('Display w='+IntToStr(displayMode.w)+' h='+IntToStr(displayMode.h));


    // Create our window centered at display resolution
    Screen := SDL_CreateWindow('title',displayMode.w, displayMode.h, SDL_WINDOW_OPENGL or SDL_WINDOW_SHOWN or SDL_WINDOW_FULLSCREEN);
    if Screen=nil then
        debug_message_to_android('Could not create window.');

    window:=Screen^;

    debug_message_to_android('Could not create window.');

    screenSurface := SDL_GetWindowSurface( Screen );
    if(screenSurface=nil) then
        debug_message_to_android('Could not get screen surface');

    debug_message_to_android('drawing surface w='+IntToStr((screenSurface^).w)+' h='+IntToStr((screenSurface^).h));



    ind:=0;
    go_on:=false;

    while ((SDL_WaitEvent(@e) <> 0) and not go_on) do begin

       if(e.type_ and SDL_WINDOWEVENT > 0) then begin
          go_on:=true;
          end;
    end;

    gl := SDL_GL_CreateContext(Screen);
    if(gl=nil) then debug_message_to_android('could not create GL context: '+SDL_GetError());

    glViewport(0, 0, displayMode.w, displayMode.h);

    glGenVertexArrays(1,@vao);
    glBindVertexArray(vao);

    glGenBuffers(1, @vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);


    vertex_length:=sizeof(vertices);
    glBufferData(GL_ARRAY_BUFFER, vertex_length, @vertices[1], GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, false, 3 * sizeof(GL_FLOAT), nil);
    glEnableVertexAttribArray(0);


    vs:=loadShader(GL_VERTEX_SHADER,gVertexShader);
    fs:=glCreateShader(GL_FRAGMENT_SHADER);
    //vs:=loadShader(GL_VERTEX_SHADER,gVertexShader);
    //debug_message_to_android(gFragmentShader);
    //fs:=loadShader(GL_FRAGMENT_SHADER,gFragmentShader);




    //glShaderSource (shader: GLuint; count: GLsizei;  source_code_string_array: PPGLChar; length_array: pglint)



    printGLString('Version', GL_VERSION);
      printGLString('Vendor', GL_VENDOR);
      printGLString('Renderer', GL_RENDERER);
      printGLString('Extensions', GL_EXTENSIONS);



    while (true)  do begin

       SDL_Delay(10);
       SDL_FillSurfaceRect( screenSurface, nil, SDL_MapRGB( screenSurface^.format, ind, $FF, $FF ) );
       SDL_UpdateWindowSurface( Screen );
       ind:=ind+1;
       if ind>255 then ind:=0;
       SDL_GL_SwapWindow(Screen);
    end;




  SDL_Quit();

end;

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
      if SDL_Init(SDL_INIT_VIDEO)>=0 then begin
         debug_message_to_android('SDL init failed with error'+SDL_GetError());
         setupGraphics:=false;
         exit;
      end
      else
         debug_message_to_android('SDL_INIT: Initialized video system successfully');
      //screen:=Android_JNI_GetNativeWindow();
      //if(screen=nil) then
      //begin
      //   debug_message_to_android('setupGraphics: Failed to set up window: '+SDL_GetError());
      //   setupGraphics:=false;
      //   exit;
      //end;
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


exports Java_org_libsdl_app_SDLActivity_onNativeMouse name 'Java_org_libsdl_app_SDLActivity_onNativeMouse';

exports Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation name 'Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation';
exports Java_org_libsdl_app_SDLActivity_onNativeRotationChanged name 'Java_org_libsdl_app_SDLActivity_onNativeRotationChanged';

exports Java_org_libsdl_app_SDLActivity_nativeSetupJNI name 'Java_org_libsdl_app_SDLActivity_nativeSetupJNI';

exports JNI_OnLoad name 'JNI_OnLoad';

exports SDL_main name 'SDL_main';





begin

end.
