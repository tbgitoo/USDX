{* UltraStar Deluxe - Karaoke Game
 *
 * UltraStar Deluxe is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/base/UMain.pas $
 * $Id: UMain.pas 2631 2010-09-05 15:26:08Z tobigun $
 *}

unit UMainThread;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SysUtils,
   {$IFDEF UseSDL3}
  SDL3;
  {$ELSE}
  SDL2;
  {$ENDIF}

type
  TMainThreadExecProc = procedure(Data: Pointer);

const
  MAINTHREAD_EXEC_EVENT = SDL_USEREVENT + 2;

{*
 * Delegates execution of procedure Proc to the main thread.
 * The Data pointer is passed to the procedure when it is called.
 * The main thread is notified by signaling a MAINTHREAD_EXEC_EVENT which
 * is handled in CheckEvents.
 * Note that Data must not be a pointer to local data. If you want to pass local
 * data, use Getmem() or New() or create a temporary object.
 *}
procedure MainThreadExec(Proc: TMainThreadExecProc; Data: Pointer);

implementation

procedure MainThreadExec(Proc: TMainThreadExecProc; Data: Pointer);
var
  Event: TSDL_Event;
begin
  with Event.user do
  begin
    type_ := MAINTHREAD_EXEC_EVENT;
    code  := 0;     // not used at the moment
    data1 := @Proc;
    data2 := Data;
  end;
  SDL_PushEvent(@Event);
end;

end.
