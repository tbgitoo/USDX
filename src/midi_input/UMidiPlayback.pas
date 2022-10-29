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
 * $URL: svn://basisbit@svn.code.sf.net/p/ultrastardx/svn/trunk/src/base/UMusic.pas $
 * $Id: UMusic.pas 3103 2014-11-22 23:21:19Z k-m_schindler $
 *}

unit UMidiPlayback;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SysUtils,
  Classes,
  UTime,
  UPath,
  UMusic,
  UFluidSynth;

type

  IMidiPlayback = Interface( IGenericPlayback )
  ['{6A76264F-BBCF-46D3-B63D-612E641C04F0}']
      function InitializePlayback: boolean;
      function FinalizePlayback: boolean;

      procedure SetVolume(Volume: single);
      procedure SetLoop(Enabled: boolean);

      procedure FadeIn(Time: real; TargetVolume: single);
      procedure Fade(Time: real; TargetVolume: single);
      procedure SetSyncSource(SyncSource: TSyncSource);

      procedure Rewind;
      function  Finished: boolean;
      function  Length: real;

      function Open(const Filename: IPath): boolean; // true if succeed
      procedure Close;

      procedure Play;
      procedure Pause;
      procedure Stop;

      procedure SetPosition(Time: real);
      function GetPosition: real;

      property Position: real read GetPosition write SetPosition;


  end;

  (*
   * State-Chart for playback-stream state transitions
   * []: Transition, (): State
   *
   *               /---[Play/FadeIn]--->-\  /-------[Pause]----->-\
   * -[Create]->(Stop)                  (Play)                 (Pause)
   *              \\-<-[Stop/EOF*/Error]-/  \-<---[Play/FadeIn]--//
   *               \-<------------[Stop/EOF*/Error]--------------/
   *
   * *: if not looped, otherwise stream is repeated
   * Note: SetPosition() does not change the state.
   *)

  TMidiPlayback = class(TInterfacedObject, IMidiPlayback)

    fluidSynthHandlerInternal : TFluidSynthHandler;

    public
      function GetName: AnsiString;

      function InitializePlayback: boolean;
      function FinalizePlayback: boolean;

      procedure SetVolume(Volume: single);
      procedure SetLoop(Enabled: boolean);

      procedure FadeIn(Time: real; TargetVolume: single);
      procedure Fade(Time: real; TargetVolume: single);
      procedure SetSyncSource(SyncSource: TSyncSource);

      procedure Rewind;
      function  Finished: boolean;
      function  Length: real;

      function Open(const Filename: IPath): boolean; // true if succeed
      procedure Close;

      procedure Play;
      procedure Pause;
      procedure Stop;

      procedure SetPosition(Time: real);
      function GetPosition: real;
      constructor create(handler: TFluidSynthHandler);
      property Position: real read GetPosition write SetPosition;
  end;


 procedure InitializeMidiPlayback;


function  MidiPlayback(): IMidiPlayback;

implementation

uses
  math,
  UIni,
  UNote,
  UCommandLine,
  URecord,
  ULog,
  UPathUtils;

var

  DefaultMidiPlayback : IMidiPlayback;


function MidiPlayback(): IMidiPlayback;
begin
  Result := DefaultMidiPlayback;
end;


// For now, use the global singleton for audio synthesis from midi
procedure InitializeMidiPlayback;
begin
  if fluidSynthHandler=nil then
     createfluidSynthHandler();
  DefaultMidiPlayback:=TMidiPlayback.create(fluidSynthHandler);

end;


constructor TMidiPlayback.create(handler: TFluidSynthHandler);
begin
  fluidSynthHandlerInternal:=handler;
  inherited create;
end;



function TMidiPlayback.GetName: AnsiString;
begin
  result := 'fluidsynth_midi_playback';
end;

function TMidiPlayback.InitializePlayback;
begin
  // nothing to do
  result:=true;
end;

function TMidiPlayback.FinalizePlayback: boolean;
begin
  // nothing to do, fluidsynth is handled elsewhere
  Result := true;
end;

function TMidiPlayback.Open(const Filename: IPath): boolean;
begin
  Result := true;
end;

procedure TMidiPlayback.Close;
begin
end;


procedure TMidiPlayback.Play;
begin

end;

procedure TMidiPlayback.Pause;
begin

end;

procedure TMidiPlayback.Stop;
begin

end;

function TMidiPlayback.Length: real;
begin

    Result := 0;
end;

function TMidiPlayback.GetPosition: real;
begin

    Result := 0;
end;

procedure TMidiPlayback.SetPosition(Time: real);
begin

end;

procedure TMidiPlayback.SetSyncSource(SyncSource: TSyncSource);
begin

end;

procedure TMidiPlayback.Rewind;
begin
  SetPosition(0);
end;

function TMidiPlayback.Finished: boolean;
begin
  result:=true;
end;

procedure TMidiPlayback.SetVolume(Volume: single);
begin
end;

procedure TMidiPlayback.FadeIn(Time: real; TargetVolume: single);
begin
end;

procedure TMidiPlayback.Fade(Time: real; TargetVolume: single);
begin
end;

procedure TMidiPlayback.SetLoop(Enabled: boolean);
begin
end;





end.
