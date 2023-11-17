library USDX;



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

  //------------------------------
  //Includes - 3rd Party Libraries
  //------------------------------
  SQLiteTable3  in 'lib\SQLite\SQLiteTable3.pas',
  SQLite3       in 'lib\SQLite\SQLite3.pas',
  {$IFDEF UseSDL3}
  SDL3 in 'lib\SDL3\sdl3.pas',
  SDL3_image             in 'lib\SDL3\sdl3_image.pas',
  {$ELSE}
  sdl2                   in 'lib\SDL2\sdl2.pas',
  SDL2_image             in 'lib\SDL2\SDL2_image.pas',
  {$ENDIF}
  //new work on current OpenGL implementation
  {$IFDEF UseOpenGLES}
   dglOpenGLES   in 'lib\dglOpenGL\dglOpenGLES.pas',
  {$ELSE}
  dglOpenGL              in 'lib\dglOpenGL\dglOpenGL.pas',
  {$ENDIF}

  UJniCallback            in 'jni\UJniCallback.pas',

  SysUtils;









function SDL_main(argc: integer; argv: PPChar): integer;
begin


   if not setupGraphicsAndroid then exit(1);


   openGLESexampleProgram;



    while (true)  do begin



       openGLESexampleProgramRenderFrame();

       SDL_GL_SwapWindow(Screen);
    end;




  SDL_Quit();

end;






exports SDL_main name 'SDL_main';





begin

end.
