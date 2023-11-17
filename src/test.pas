

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

  SDL3 in 'lib\SDL3\sdl3.pas';





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
