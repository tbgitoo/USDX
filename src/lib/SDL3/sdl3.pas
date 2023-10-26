unit SDL3;

{
  Simple DirectMedia Layer
  Copyright (C) 1997-2013 Sam Lantinga <slouken@libsdl.org>

  Pascal-Header-Conversion
  Copyright (C) 2012-2014 Tim Blume aka End/EV1313

  SDL.pas is based on the files:
  "sdl.h",
  "sdl_audio.h",
  "sdl_blendmode.h",
  "sdl_clipboard.h",
  "sdl_cpuinfo.h",
  "sdl_events.h",
  "sdl_error.h",
  "sdl_filesystem.h",
  "sdl_gamecontroller.h",
  "sdl_gesture.h",
  "sdl_haptic.h",
  "sdl_hints.h",
  "sdl_joystick.h",
  "sdl_keyboard.h",
  "sdl_keycode.h",
  "sdl_loadso.h",
  "sdl_log.h",
  "sdl_pixels.h",
  "sdl_power.h",
  "sdl_main.h",
  "sdl_messagebox.h",
  "sdl_mouse.h",
  "sdl_mutex.h",
  "sdl_rect.h",
  "sdl_render.h",
  "sdl_rwops.h",
  "sdl_scancode.h",
  "sdl_shape.h",
  "sdl_stdinc.h",
  "sdl_surface.h",
  "sdl_system.h",
  "sdl_syswm.h",
  "sdl_thread.h",
  "sdl_timer.h",
  "sdl_touch.h",
  "sdl_version.h",
  "sdl_video.h",
  "sdl_types.h"

  I will not translate:
  "sdl_opengl.h",
  "sdl_opengles.h"
  "sdl_opengles2.h"

  cause there's a much better OpenGL-Header avaible at delphigl.com:

  the dglopengl.pas

  Parts of the SDL.pas are from the SDL-1.2-Headerconversion from the JEDI-Team,
  written by Domenique Louis and others.

  I've changed the names of the dll for 32 & 64-Bit, so theres no conflict
  between 32 & 64 bit Libraries.

  This software is provided 'as-is', without any express or implied
  warranty.  In no case will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

  Special Thanks to:

   - DelphiGL.com - Community
   - Domenique Louis and everyone else from the JEDI-Team
   - Sam Latinga and everyone else from the SDL-Team
}

{
  Changelog:
  ----------
               ? 31.01.2016: updated sdlevents.inc to SDL3 2.0.4, adressing issue #24 (thx to imantsg)
               ? 16.01.2016: Delphi 6+ bugfixes/compatibility. Thx to Peter Karpov for identifiying and testing.
  v.1.80-stable; 09.10.2014: added sdl_cpuinfo.h and sdl_clipboard.h
  v.1.74-stable; 10.11.2013: added sdl_gamecontroller.h
  v.1.73-stable; 08.11.2013: added sdl_hints.h and some keystate helpers
                             thx to Cybermonkey!
  v.1.72-stable; 23.09.2013: fixed bug with procedures without parameters
                             (they must have brakets)
  v.1.70-stable; 17.09.2013: added "sdl_messagebox.h" and "sdl_haptic.h"
  v.1.63-stable; 16.09.2013: added libs SDL3_image and SDL3_ttf and added sdl_audio.h
  v.1.62-stable; 03.09.2013: fixed.
  v.1.61-stable; 02.09.2013: now it should REALLY work with Mac...
  v.1.60-stable; 01.09.2013: now it should work with Delphi XE4 for Windows and
                            MacOS and of course Lazarus. thx to kotai :D
  v.1.55-Alpha; 24.08.2013: fixed bug with SDL_GetEventState thx to d.l.i.w.
  v.1.54-Alpha; 24.08.2013: added sdl_loadso.h
  v.1.53-Alpha; 24.08.2013: renamed *really* and fixed linux comp.
  v.1.52-Alpha; 24.08.2013: renamed sdl.pas to SDL3.pas
  v.1.51-Alpha; 24.08.2013: added sdl_platform.h
  v.1.50-Alpha; 24.08.2013: the header is now modular. thx for the hint from d.l.i.w.
  v.1.40-Alpha; 13.08.2013: Added MacOS compatibility (thx to stoney-fd)
  v.1.34-Alpha; 05.08.2013: Added missing functions from sdl_thread.h
  v.1.33-Alpha; 31.07.2013: Added missing units for Linux. thx to Cybermonkey
  v.1.32-Alpha; 31.07.2013: Fixed three bugs, thx to grieferatwork
  v.1.31-Alpha; 30.07.2013: Added "sdl_power.h"
  v.1.30-Alpha; 26.07.2013: Added "sdl_thread.h" and "sdl_mutex.h"
  v.1.25-Alpha; 29.07.2013: Added Makros for SDL_RWops
  v.1.24-Alpha; 28.07.2013: Fixed bug with RWops and size_t
  v.1.23-Alpha; 27.07.2013: Fixed two bugs, thx to GrieferAtWork
  v.1.22-Alpha; 24.07.2013: Added "sdl_shape.h" and TSDL_Window
                            (and ordered the translated header list ^^)
  v.1.21-Alpha; 23.07.2013: Added TSDL_Error
  v.1.20-Alpha; 19.07.2013: Added "sdl_timer.h"
  v.1.10-Alpha; 09.07.2013: Added "sdl_render.h"
  v.1.00-Alpha; 05.07.2013: Initial Alpha-Release.
}

{$DEFINE SDL}

{$I jedi.inc}

interface

  {$IFDEF WINDOWS}
    uses
      Windows;
  {$ENDIF}

  {$IFDEF LINUX}
    uses
      X,
      XLib;
  {$ENDIF}
  
  {$IFDEF DARWIN}
    uses
      CocoaAll;
  {$ENDIF}



const

  {$IFDEF WINDOWS}
    SDL_LibName = 'SDL3.dll';
  {$ENDIF}

  {$IFDEF UNIX}
    {$IFDEF DARWIN}
      SDL_LibName = 'libSDL3.dylib';
	  {$linklib libSDL3}
    {$ELSE}
      {$IFDEF FPC}
        SDL_LibName = 'libSDL3.so';
      {$ELSE}
        SDL_LibName = 'libSDL3.so.0';
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF MACOS}
    SDL_LibName = 'SDL3';
    {$IFDEF FPC}
      {$linklib libSDL3}
    {$ENDIF}
  {$ENDIF}


const
  // From SDL_init.h
   SDL_INIT_TIMER        = $00000001;
   SDL_INIT_AUDIO        = $00000010;
   SDL_INIT_VIDEO        = $00000020;  // `SDL_INIT_VIDEO` implies `SDL_INIT_EVENTS`
   SDL_INIT_JOYSTICK     = $00000200;  // `SDL_INIT_JOYSTICK` implies `SDL_INIT_EVENTS`
   SDL_INIT_HAPTIC       = $00001000;
   SDL_INIT_GAMEPAD      = $00002000;  // `SDL_INIT_GAMEPAD` implies `SDL_INIT_JOYSTICK`
   SDL_INIT_EVENTS       = $00004000;
   SDL_INIT_SENSOR       = $00008000;


{$I sdltype.inc}
{$I sdlversion.inc}
{$I sdlerror.inc}



function SDL_Init(flags: Uint32): integer; cdecl; external SDL_LibName name 'SDL_Init';


implementation

//from "sdl_version.h"
procedure SDL_VERSION(Out x: TSDL_Version);
begin
  x.major := SDL_MAJOR_VERSION;
  x.minor := SDL_MINOR_VERSION;
  x.patch := SDL_PATCHLEVEL;
end;

function SDL_VERSIONNUM(X,Y,Z: UInt32): Cardinal;
begin
  Result := X*1000 + Y*100 + Z;
end;

function SDL_COMPILEDVERSION: Cardinal;
begin
  Result := SDL_VERSIONNUM(SDL_MAJOR_VERSION,
                           SDL_MINOR_VERSION,
                           SDL_PATCHLEVEL);
end;

function SDL_VERSION_ATLEAST(X,Y,Z: Cardinal): Boolean;
begin
  Result := SDL_COMPILEDVERSION >= SDL_VERSIONNUM(X,Y,Z);
end;



end.
