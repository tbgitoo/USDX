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
 * $URL$
 * $Id$
 *}

unit UMidiNote;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UCommon,
  UScreenSingController,
  UMusic,
  USong,
  SysUtils,
  UIni,
  UMidiInputStream,
  UMidiTransfer;



type
  TMidiNoteHandler=class
    public
    midiKeyboardStreams: array of TMidiKeyboardPressedStream; // There will be a keyboard recording stream per active player
    midiInputDeviceMessaging: array of TmidiInputDeviceMessaging; // There will be a midi message capturing instance per active player
    midiOutputDeviceMessaging: array of TmidiOutputDeviceMessaging; // There will be an midi output stream for addressin the synthesizer per player
    constructor Create;
    procedure updateForCurrentPlayers;
    procedure stopMidiHandling(stopFluidSynth: boolean);
  end;


  procedure createMidiNoteHandler();

 // global singleton for the TBeatNoteTimerState class
var midiNoteHandler : TMidiNoteHandler;



procedure handleMidiNotes(Screen: TScreenSingController); // General handler called at every cycle. This is NewBeatDetect from
// UNote with adaptation

implementation

uses
  UNote,UFluidSynth;

procedure createMidiNoteHandler();
begin
  if  midiNoteHandler=nil then midiNoteHandler:=TMidiNoteHandler.create;
end;

procedure handleMidiNotes(Screen: TScreenSingController);
begin
  ConsoleWriteLn('handleMidiNotes');
end;

constructor TMidiNoteHandler.create;
begin
  setLength(midiKeyboardStreams,0);
  setLength(midiInputDeviceMessaging,0);
  setLength(midiOutputDeviceMessaging,0);
  createfluidSynthHandler();
end;

procedure TMidiNoteHandler.stopMidiHandling(stopFluidSynth: boolean);
var count: Integer;
begin
  for count:=Low(midiInputDeviceMessaging) to High(midiInputDeviceMessaging) do
  begin
    if not (midiInputDeviceMessaging[count]=nil) then begin
         midiInputDeviceMessaging[count].stopTransfer;
         midiInputDeviceMessaging[count].free;
         midiInputDeviceMessaging[count]:=nil;
   end;
  end;
  for count:=Low(midiKeyboardStreams) to High(midiKeyboardStreams) do
  begin
    if not (midiKeyboardStreams[count]=nil) then begin
         midiKeyboardStreams[count].free;
         midiKeyboardStreams[count]:=nil;
   end;
  end;
  for count:=Low(midiOutputDeviceMessaging) to High(midiOutputDeviceMessaging) do
  begin
  if not (midiOutputDeviceMessaging[count]=nil) then begin
         midiOutputDeviceMessaging[count].free;
         midiOutputDeviceMessaging[count]:=nil;

   end;
   end;
   if stopFluidSynth then begin
     fluidSynthHandler.StopMidi();
     fluidSynthHandler.StopAudio();
   end;

   setLength(midiInputDeviceMessaging,0);
   setLength(midiKeyboardStreams,0);
   setLength(midiOutputDeviceMessaging,0);

end;

procedure TMidiNoteHandler.updateForCurrentPlayers;
var count : integer;
    cb_array: array of TMidiInputDeviceMessaging.TCallbackProc;
    cb_data_array: array of pointer;
begin
  // Free previous handles (from preceding song), also stop the synthesizer if
  //
  stopMidiHandling((not CurrentSong.freestyleMidi));

   if CurrentSong.freestyleMidi then // The current song actually requires midi playing
   begin
     // In case this has not been initialized elsewhere
     setLength(midiInputDeviceMessaging,PlayersPlay);
     setLength(midiKeyboardStreams,PlayersPlay);
     setLength(midiOutputDeviceMessaging,PlayersPlay);
     for count:=Low(midiInputDeviceMessaging) to High(midiInputDeviceMessaging) do begin
       // We only need an input device if the player actually is using a valid midi device
       if (Ini.PlayerMidiInputDevice[count]>=0) then
       begin
          midiKeyboardStreams[count]:=TMidiKeyboardPressedStream.create;
          if (Ini.PlayerMidiSynthesizerOn[count]=1) then begin // Connect the synthesizer
             fluidSynthHandler.StartAudio(); // In case this has not been initialized elsewhere
             fluidSynthHandler.StartMidi();
             midiOutputDeviceMessaging[count]:=TMidiOutputDeviceMessaging.create(fluidSynthHandler.midi_port_id);
             setLength(cb_array,2);
             setLength(cb_data_array,2);
             cb_array[0]:=@callback_midiKeyboardPressedStream;
             cb_array[1]:=@callback_midiOutputDeviceMessaging;
             cb_data_array[0]:=midiKeyboardStreams[count];
             cb_data_array[1]:=midiOutputDeviceMessaging[count];
             midiInputDeviceMessaging[count]:=TMidiInputDeviceMessaging.create(
               Ini.PlayerMidiInputDevice[count],cb_array,false,cb_data_array);
          end else begin
             midiOutputDeviceMessaging[count]:=nil; // No transmission to the synthesizer
             setLength(cb_array,1);
             setLength(cb_data_array,1);
             cb_array[0]:=@callback_midiKeyboardPressedStream;
             cb_data_array[0]:=midiKeyboardStreams[count];
             midiInputDeviceMessaging[count]:=TMidiInputDeviceMessaging.create(
               Ini.PlayerMidiInputDevice[count],cb_array,false,cb_data_array);
          end;
       end
       else
       begin
         midiInputDeviceMessaging[count]:=nil; // otherwise we set the input-device to nil
       end;
     end;



  end;
end;












end.

