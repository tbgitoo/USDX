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

    protected

    fluidSynthHandlerInternal : TFluidSynthHandler;

    midiTicksPerQuarterNote: integer;

    currentMidiFile: IPath;

    BPM: integer;

    song_length_seconds: real;

    procedure AnalyseFile;

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
  UPathUtils,
  UTextEncoding,
  UCommon,
  MidiFile;

var

  DefaultMidiPlayback : IMidiPlayback;


function MidiPlayback(): IMidiPlayback;
begin
  Result := DefaultMidiPlayback;
end;


// For now, use the global singleton for audio synthesis from midi
procedure InitializeMidiPlayback;
var theFluidSynthHandler : TFluidsynthHandler;
begin
  Log.LogStatus('UMidiPlayback', 'Start fluidsynth create');
  theFluidSynthHandler:=TFluidsynthHandler.Create();
  Log.LogStatus('UMidiPlayback', 'Created Fluidsynthhandler');
  theFluidSynthHandler.setGain(Ini.MidiSynthesizerGainValue*Ini.GainFactorAudioPlayback);
  DefaultMidiPlayback:=TMidiPlayback.create(theFluidSynthHandler);


end;



constructor TMidiPlayback.create(handler: TFluidSynthHandler);
begin
  fluidSynthHandlerInternal:=handler;
  midiTicksPerQuarterNote:=480; // Midi default value, has to be re-evaluated for a given file
  currentMidiFile:=PATH_NONE();
  inherited create;
end;



function TMidiPlayback.GetName: AnsiString;
begin
  result := 'fluidsynth_midi_playback';
end;

function TMidiPlayback.InitializePlayback;
begin
  fluidSynthHandlerInternal.StartAudio();
  result:=true;
end;

function TMidiPlayback.FinalizePlayback: boolean;
begin
  fluidSynthHandlerInternal.StopAudio();
  Result := true;
end;



function TMidiPlayback.Open(const Filename: IPath): boolean;
begin
  Result:=false;
  if Filename.isFile() then begin
     fluidSynthHandlerInternal.setMidiFile(Filename.toUTF8());
     Result := true;
     currentMidiFile:=Filename;
     analyseFile;
  end;
end;

procedure TMidiPlayback.Close;
begin

   fluidSynthHandlerInternal.StopAudio();
end;


procedure TMidiPlayback.Play;
begin
  fluidSynthHandlerInternal.applyTuningFromIni();
  fluidSynthHandlerInternal.startMidiFilePlay();
end;

procedure TMidiPlayback.Pause;
begin
    fluidSynthHandlerInternal.pauseMidiFile();
end;

procedure TMidiPlayback.Stop;
begin
   fluidSynthHandlerInternal.stopMidiFile();
end;

procedure TMidiPlayback.analyseFile();
  var
  mFile: TMidiFile;
  T:    integer; // track index
  N:    integer; // note index
  MidiTrack: TMidiTrack;
  MidiEvent: PMidiEvent;
  max_tick: double;
begin

    song_length_seconds:=0;

    max_tick:=0;



    if not (currentMidiFile = PATH_NONE()) then
    begin
    mFile:=TMidiFile.Create(nil); // We are not in a component here and do not need these functionalities

    mFile.Filename:=currentMidiFile;

    mFile.readFile;

    for T := 0 to mFile.NumberOfTracks-1 do
    begin
       MidiTrack := mFile.GetTrack(T);
       for N := 0 to MidiTrack.getEventCount-1 do
       begin
          MidiEvent := MidiTrack.GetEvent(N);
          if ((MidiEvent.event shr 4) = $8) or ((MidiEvent.event shr 4) = $9) then // on/off note events
             if max_tick<MidiEvent.time then max_tick:=MidiEvent.time;
       end;


    end;

    midiTicksPerQuarterNote:=mFile.TicksPerQuarter;
    BPM:=mFile.Bpm;

    song_length_seconds:=max_tick/midiTicksPerQuarterNote/BPM*60.0;



    end;

    // in principle, it would have been more simple and to the point to get this information from
    // fluid synth directly, but unfortunately, there is no guarantee that the file is already loaded,
    // or if loaded, fully loaded,and so midiFileTotalTickLength is typically incorrect unless the file is already
    // playing


    //Result:=fluidSynthHandlerInternal.midiFileTotalTickLength();
    //Result:=Result/midiTicksPerQuarterNote;  // now we have it in numbers of quarter notes
    //Result:=Result/fluidSynthHandlerInternal.midiFileBPM()*60.0; // conversion to seconds via BPM (quarter notes per minute)


end;

// Length of the midi file in seconds. There is no length meta tag in midi
// and so one literally has to go through the midi messages and look for the noteon or
// more likely noteoff event with the highest time information.
// also, time in midi files is ticks so we have to convert to seconds with both
// the number of ticks per quarter and the bpm of the file.
function TMidiPlayback.Length: real;
begin
   Result:=song_length_seconds;
end;

function TMidiPlayback.GetPosition: real;
begin
    result:=fluidSynthHandlerInternal.tickPositionMidiFile();
    result:=result/midiTicksPerQuarterNote/BPM*60.0;

end;

procedure TMidiPlayback.SetPosition(Time: real);
var tick_position: real;
    tick_position_int : longint;
begin
   tick_position:=Time/60.0;
   tick_position:=tick_position*BPM;
   tick_position:=tick_position*midiTicksPerQuarterNote;
   tick_position_int:=round(tick_position)            ;
   fluidSynthHandlerInternal.gotoTickPositionMidiFile(tick_position_int);
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
  result:=fluidSynthHandlerInternal.midiFilePlayerDone();
end;

procedure TMidiPlayback.SetVolume(Volume: single);
begin
   fluidSynthHandlerInternal.setGain(Ini.MidiSynthesizerGainValue*Ini.GainFactorAudioPlayback*Volume);
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
