

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

  glad_gl in 'lib\glad\glad_gl.pas',

  //dglOpenGLES   in 'lib\dglOpenGL\dglOpenGLES.pas',

  SDL2 in 'lib\SDL2\sdl2.pas';



var    window: PSDL_Window;
  maincontext: TSDL_GLContext;
  mode: TSDL_DisplayMode;


function SDL_GL_GetProcAddress_wrapper(load: PAnsiChar): Pointer;
begin
   SDL_GL_GetProcAddress_wrapper:=SDL_GL_GetProcAddress(load);

end;

function SDL_main(argc: integer; argv: PPChar): integer;
var index: GLint;
begin
      if SDL_Init(SDL_INIT_VIDEO)<0 then debug_message_to_android('SDL not loaded');

      SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION,3);
      SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION,0);
      SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK,SDL_GL_CONTEXT_PROFILE_ES);
      SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER,1);

      window:=SDL_CreateWindow('USDX',SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,640,480,
      SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL);


      maincontext := SDL_GL_CreateContext(window);

      SDL_GetDesktopDisplayMode(0, @mode);


      gladLoadGLES2(@SDL_GL_GetProcAddress_wrapper);

      get_exts();

      for index:=Low(gl_exts_i) to High(gl_exts_i) do
          debug_message_to_android(gl_exts_i[index]);











      while(true) do
      begin

      end;


end;






exports SDL_main name 'SDL_main';





begin

end.
