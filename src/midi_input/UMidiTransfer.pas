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
 *
 *}

unit UMidiTransfer;

interface

{$IFDEF FPC}
  {$MODE Delphi}
  {$H+} // use long strings
{$ENDIF}
{$I switches.inc}


uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, PortMidi, sysutils,CTypes, UCommon, UTextEncoding;



type
  TMidiInputDeviceMessaging = class(TThread)
  type
       TCallbackProc = procedure (midiEvents: array of PmEvent; data: pointer);
       // The idea here is to use the generic pointer place to let the callback know the object
       // that is interested in the midi data. This can really be anything, it's up to
       // the callback to know what to do with this data (pass nil if you don't need this)
  protected
       ready: boolean; // indicates that everything has been set up succesfully for transferring
       running: boolean; // indicates that we are actually transferring
       deviceInfoSource: PPmDeviceInfo;
       source_id: integer;
       callback_data_array: array of pointer; // This is for the callbacks, typically the object that shold do something
       wait_time_ms: integer;
       PmidiStreamSource: PPortMidiStream;
       midiStreamSource: PortMidiStream;
       PmidiEvent: PPmEvent;
       midiEvent: array[0..4095] of PmEvent; // Buffer for reading midi events
       availableEvents: Integer;
       callback_array: array of TCallbackProc;
       procedure Execute; override;
       function OpenInput(id: PmDeviceID): PmError;
       procedure CloseInput();
       procedure TransferMessages;
       function readEvents(): PmError;
       function recordOnlyNotes() : PmError;
       function setFilter(filters : CInt32 ) : PmError;
   public
         procedure stopTransfer;
         constructor create(id_source: Integer; callbacks:
           array of TCallbackProc; readOnlyNotes: boolean;callback_data:array of pointer);
         // The callback_data array needs to be at least as long as the callbacks array.
         // If it is longer, the elements towards the end are ignored
         destructor destroy(); override;
  end;








implementation


function TmidiInputDeviceMessaging.OpenInput(id: PmDeviceID): PmError;
 begin
    result:=Pm_OpenInput(PmidiStreamSource, id, nil,4095,nil, nil );
 end;

procedure TmidiInputDeviceMessaging.CloseInput();
begin
  Pm_Close(midiStreamSource);
  ready:=False;
end;


constructor TmidiInputDeviceMessaging.create(id_source: Integer; callbacks:
           array of TCallbackProc; readOnlyNotes: boolean;callback_data:array of pointer);
var
  count: integer;
  last_error: PmError;
begin
   running:=false;
   ready:=false;
   wait_time_ms:=5;
   setLength(callback_array,high(callbacks)-low(callbacks)+1);
   setLength(callback_data_array,high(callbacks)-low(callbacks)+1);
   for count:=low(callbacks) to high(callbacks) do begin
      callback_array[count]:=callbacks[count];
      callback_data_array[count]:=callback_data[count];
   end;

   deviceInfoSource:=nil;
   source_id:=-1;



   availableEvents:=0;
   for count:= 0 to 4095 do
   begin
       midiEvent[count].message_:=$00; // initialize buffer to zero
       midiEvent[count].timestamp:=$00;
   end;
   PmidiStreamSource:=@midiStreamSource;
   PmidiEvent:=@midiEvent[0];

 last_error:=-100; // No specific error encountered but fails
 Pm_Initialize(); // Just in case this hasn't been done elsewhere
 deviceInfoSource:=Pm_GetDeviceInfo(id_source);
   if not (deviceInfoSource = nil) then
   begin
      if (deviceInfoSource^.opened=0) then
         last_error:=OpenInput(id_source);
      if last_error >=0 then // succesfully opened source port
      begin
        source_id:=id_source;
        if readOnlyNotes then recordOnlyNotes();
        ready:=true;
      end;

   end;
 running:=ready;
 FreeOnTerminate := false;
 inherited create(false); // This will return immediately since running is false


end;


procedure TmidiInputDeviceMessaging.Execute;
begin
 while running do
 begin
   readEvents;
   TransferMessages;
   sleep(wait_time_ms);
 end;

end;

procedure TmidiInputDeviceMessaging.TransferMessages;
var
  dynamic_event_array : array of PmEvent;
  count: integer;
  f: TCallbackProc;
begin
  if availableEvents>0 then
  begin
    setLength(dynamic_event_array,availableEvents);
    for count := 0 to (availableEvents-1) do
       dynamic_event_array[count]:=midiEvent[count];
    for count := low(callback_array) to high(callback_array) do begin
      f:=callback_array[count];
      f(dynamic_event_array,callback_data_array[count]);
    end;
  end;

end;

function TmidiInputDeviceMessaging.readEvents(): PmError;
var ret: CInt;
begin
   ret:=Pm_Read(midiStreamSource,@midiEvent[0], 4095 );
   if ret >= 0 then
      availableEvents:=ret
   else
       availableEvents:=0;
   result:=ret;
end;

procedure TmidiInputDeviceMessaging.stopTransfer;
begin
  running:=false;
  WaitFor;
  CloseInput;
end;

function TmidiInputDeviceMessaging.setFilter(filters : CInt32 ) : PmError;
begin
   result:=Pm_SetFilter(midiStreamSource, filters);
end;

function TmidiInputDeviceMessaging.recordOnlyNotes() : PmError;
begin
   result:=setFilter(not PM_FILT_NOTE);
end;


destructor TmidiInputDeviceMessaging.destroy();
begin
   deviceInfoSource:=nil; // this is handled by portmidi
   PmidiStreamSource:=nil;  // this is handled by portmidi
   PmidiEvent:=nil; // this is a pointer on the array
   callback_data_array:=nil; // This is handled externally
   //midiEvent This is preallocated and should be freed with the object
   inherited;
end;

end.




