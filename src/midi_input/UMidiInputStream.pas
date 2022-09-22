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

unit UMidiInputStream;

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
  Classes, PortMidi, sysutils,CTypes;


type




TMidiInputStream = class
    public
    deviceInfo: PPmDeviceInfo;
    PmidiStream: PPortMidiStream;
    midiStream: PortMidiStream;
    PmidiEvent: PPmEvent;
    midiEvent: array[0..4095] of PmEvent;
    availableEvents: Integer;
    isCapturing: Boolean;
    constructor Create;
    procedure initMidi;
    procedure ReadMessages;
    procedure setMidiDeviceID(id: PmDeviceID);
    function midiDeviceName(): PChar;
    function midiDeviceInterf(): PChar;
    function midiDeviceIsInput(): CInt;
    function midiDeviceIsOutput(): CInt;
    function midiDeviceIsOpened(): CInt;
    function setFilter(filters : CInt32 ) : PmError;
    function recordOnlyNotes() : PmError;
    function readEvents(): PmError;
    function OpenInput(id: PmDeviceID): PmError;
    procedure CloseInput();
  end;


TMidiKeyboardPressedStream = class(TMidiInputStream)
    public
    keyBoardPressed: array[0..127] of Boolean;
    constructor Create;
    procedure ResetKeyBoardPressed;
    procedure setMidiDeviceID(id: PmDeviceID);
    function readEvents(): PmError;
end;





implementation

procedure TMidiInputStream.ReadMessages;
begin

end;

constructor TMidiInputStream.Create;
var
  count: integer;
begin
   isCapturing:=False;
   deviceInfo:=nil;
   availableEvents:=0;
   for count:= 0 to 4095 do
   begin
       midiEvent[count].message_:=$00; // initialize buffer to zero
       midiEvent[count].timestamp:=$00;
   end;
   PmidiStream:=@midiStream;
   PmidiEvent:=@midiEvent[0];
   initMidi;
end;

procedure TMidiInputStream.initMidi;
begin
   Pm_Initialize();
end;

function TMidiInputStream.OpenInput(id: PmDeviceID): PmError;
begin
   result:=Pm_OpenInput(PmidiStream, id, nil,4095,nil, nil );
end;

procedure TMidiInputStream.CloseInput();
begin
   Pm_Close(midiStream);
   isCapturing:=False;
end;

procedure TMidiInputStream.setMidiDeviceID(id: PmDeviceID);
begin
   deviceInfo:=Pm_GetDeviceInfo(id);
   if not (deviceInfo = nil) then
   begin
      if OpenInput(id) >=0 then
          isCapturing:=True;
   end;
end;

function TMidiInputStream.midiDeviceName(): PChar;
begin
   if deviceInfo = nil then
      result:=''
   else
       result:= deviceInfo^.name;
end;

function TMidiInputStream.midiDeviceInterf(): PChar;
begin
   if deviceInfo = nil then
      result:=''
   else
       result:= deviceInfo^.interf;
end;

function TMidiInputStream.midiDeviceIsInput(): CInt;
begin
   if deviceInfo = nil then
      result:=0
   else
       result:= deviceInfo^.input;
end;

function TMidiInputStream.midiDeviceIsOutput(): CInt;
begin
   if deviceInfo = nil then
      result:=0
   else
       result:= deviceInfo^.output;
end;

function TMidiInputStream.midiDeviceIsOpened(): CInt;
begin
   if deviceInfo = nil then
      result:=0
   else
    result:= deviceInfo^.opened;
end;


function TMidiInputStream.setFilter(filters : CInt32 ) : PmError;
begin
   result:=Pm_SetFilter(midiStream, filters);
end;

function TMidiInputStream.recordOnlyNotes() : PmError;
begin
   result:=setFilter(not PM_FILT_NOTE);
end;
// This function delivers a negative error code when it fails, otherwise
// it indicates the number of events read, which is 0 or a positive integer
function TMidiInputStream.readEvents(): PmError;
var ret: CInt;
begin
   ret:=Pm_Read(midiStream,@midiEvent[0], 4095 );
   if ret >= 0 then
      availableEvents:=ret
   else
       availableEvents:=0;
   result:=ret;
end;


constructor TMidiKeyboardPressedStream.Create;

begin
   inherited Create;
   ResetKeyBoardPressed;
end;

procedure TMidiKeyboardPressedStream.ResetKeyBoardPressed;
var count: Integer;
begin
  for count:=0 to 127 do
      keyBoardPressed[count]:=False;

end;

procedure TMidiKeyboardPressedStream.setMidiDeviceID(id: PmDeviceID);
begin
  inherited setMidiDeviceID(id);
  if isCapturing then
    recordOnlyNotes();

end;


function TMidiKeyboardPressedStream.readEvents(): PmError;
var count: Integer;
begin
   result:=inherited readEvents;
   if availableEvents>0 then
   begin
      for count:=0 to (availableEvents-1) do
      begin
          if (Pm_MessageStatus(midiEvent[count].message_)=$81) or
          ((Pm_MessageStatus(midiEvent[count].message_)=$91) and
            (Pm_MessageData2(midiEvent[count].message_)=$00)) then
            begin // Off is either because the key is off ($81) or because the
               // velocity (aka pressure) is set to 0 for a touch ($91)
               keyBoardPressed[Pm_MessageData1(midiEvent[count].message_)]:=False;
               // The key is the second byte
            end;
            if (Pm_MessageStatus(midiEvent[count].message_)=$91) and not
            (Pm_MessageData2(midiEvent[count].message_)=$00) then
            begin
                keyBoardPressed[Pm_MessageData1(midiEvent[count].message_)]:=True;
            end;
      end;
   end;

end;

end.


