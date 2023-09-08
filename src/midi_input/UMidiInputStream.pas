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
  Classes,
  {$IFDEF UsePortMidi}
  PortMidi,
  {$ELSE}
  Amidi,
  {$ENDIF}

  sysutils,CTypes, UCommon, UTextEncoding,UMidiTransfer;


type

IntegerArray = array of Integer;
PIntegerArray = ^IntegerArray;
PInteger = ^integer;

TMidiDeviceList = class
    protected
    procedure scanDevices(input: boolean; output: boolean);
    public
    midi_devices: array of Integer;
    midi_device_names: array of UTF8String;
    midi_device_names_with_none: array of UTF8String;
    // Convenience array for choice fields, adds "None" as first element and
    // returns the other input devices in order
    constructor Create(input: boolean; output: boolean);
    destructor Destroy; override;
    procedure scanInputDevices;
    procedure scanOutputDevices;
    procedure scanAllDevices;
    function getDeviceName(id: Integer): UTF8String;
    procedure update_names_with_none();
    function getIndexInList(device_id: Integer):Integer;
    function getDeviceIdFromDeviceName(deviceName: UTF8String):Integer;

end;

TMidiInputDeviceList = class(TmidiDeviceList)
   public
   constructor Create;
end;

// The idea of this class is that it can be connected to
// an instance of TMidiInputDeviceMessaging via a callback
TMidiInputStream = class
    public

    midiEvent: array of PmEvent;

    constructor Create;
    procedure processEvents (midiEvents: array of PmEvent);  // This is the callback


  end;


TIntArray = array of Integer;


TMidiKeyboardPressedStream = class(TMidiInputStream)
    public
    keyBoardPressed: array[0..127] of Boolean;
    constructor Create;
    procedure ResetKeyBoardPressed;
    procedure processEvents (midiEvents: array of PmEvent);
    function key_currently_pressed: TIntArray;

end;






procedure createMidiInputDeviceList();

 // global singleton for the TBeatNoteTimerState class
var midiInputDeviceList : TMidiInputDeviceList;

procedure callback_midiKeyboardPressedStream(midiEvents: array of PmEvent; data: TMidiKeyboardPressedStream);



implementation

uses
  UIni,UUnicodeUtils;

constructor TMidiInputDeviceList.Create;
begin
  inherited Create(true,false);
end;

constructor TMidiDeviceList.Create(input: boolean; output: boolean);
begin
  scanDevices(input,output);
end;

procedure TMidiDeviceList.scanAllDevices;
begin
   scanDevices(true,true);
end;

procedure TMidiDeviceList.scanInputDevices;
begin
   scanDevices(true,false);
end;

procedure TMidiDeviceList.scanOutputDevices;
begin
   scanDevices(false,true);
end;

procedure TMidiDeviceList.scanDevices(input: boolean; output: boolean);
var count: integer;
    deviceInfo: PPmDeviceInfo;
begin
   Pm_Terminate();
   Pm_Initialize();  // Otherwise freshly connected devices won't be seen
   setLength(midi_devices,0);
   setLength(midi_device_names,0);
   for count:=0 to (Pm_CountDevices()-1) do
   begin
       deviceInfo:=Pm_GetDeviceInfo(count);
       if(input and (deviceInfo^.input>0)) then
       begin
          setLength(midi_devices,Length(midi_devices)+1);
          setLength(midi_device_names,Length(midi_devices));
          midi_devices[Length(midi_devices)-1]:=count;
          DecodeStringUTF8(deviceInfo^.name, midi_device_names[Length(midi_devices)-1],encLocale);
       end
       else if(output and (deviceInfo^.output>0)) then
       begin
          setLength(midi_devices,Length(midi_devices)+1);
          setLength(midi_device_names,Length(midi_devices));
          midi_devices[Length(midi_devices)-1]:=count;
          DecodeStringUTF8(deviceInfo^.name, midi_device_names[Length(midi_devices)-1],encLocale);
       end;
   end;
   update_names_with_none;
end;



function TMidiDeviceList.getDeviceName(id: Integer): UTF8String;
var
    deviceInfo: PPmDeviceInfo;
begin
   if (id<0) or (id>=Length(midi_devices)) then result:='None'
   else
       begin
          if(id >= Pm_CountDevices()) then // Additional safety if devices have changed as compared to stored values
            result:='None'
          else
            begin
               deviceInfo:=Pm_GetDeviceInfo(id);
               result:=deviceInfo^.name;
            end;
       end;
end;

procedure TMidiDeviceList.update_names_with_none();
var
    count: integer;
begin
   if midi_devices=nil then
   begin
     setLength(midi_device_names_with_none,1);
     midi_device_names_with_none[0]:='None';
   end
   else
     begin
        setLength(midi_device_names_with_none,1+Length(midi_devices));
        midi_device_names_with_none[0]:='None';
        for count:=0 to (Length(midi_devices)-1) do
        begin
           midi_device_names_with_none[count+1]:=midi_device_names[count];
        end;

     end;

end;

function TMidiDeviceList.getIndexInList(device_id: Integer):Integer;
var
    count: Integer;
begin
   result:=-1;
   for count:=0 to (Length(midi_devices)-1) do
     if device_id=midi_devices[count] then result:=count;
end;


function TMidiDeviceList.getDeviceIdFromDeviceName(deviceName: UTF8String):Integer;
var
    count: Integer;
begin
   result:=-1;
   for count:=0 to (Length(midi_devices)-1) do begin
     if UTF8CompareStr(midi_device_names[count],deviceName)=0 then
        result:=midi_devices[count];
   end;
end;

destructor TMidiDeviceList.destroy;
begin
   setlength(midi_devices,0);
   setlength(midi_device_names,0);
   setlength(midi_device_names_with_none,0);
    inherited;
end;

constructor TMidiInputStream.Create;
begin
  setLength(midiEvent,0);
end;


procedure TMidiInputStream.processEvents (midiEvents: array of PmEvent);
var count:integer;
begin
  // This is just copying the events over so that we have them locally
  setLength(midiEvent,High(midiEvents)-Low(midiEvents)+1);
  for count := Low(midiEvents) to High(midiEvents) do
       midiEvent[count]:=midiEvents[count];

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




procedure TMidiKeyboardPressedStream.processEvents(midiEvents: array of PmEvent);
var count: Integer;
    availableEvents: Integer;
begin
   inherited processEvents(midiEvents);
   availableEvents:=High(midiEvent)-Low(midiEvent)+1;


   if availableEvents>0 then
   begin
      for count:=0 to (availableEvents-1) do
      begin
          if (Pm_MessageStatus(midiEvent[count].message_)=$81) or
          ((Pm_MessageStatus(midiEvent[count].message_)=$90) and
            (Pm_MessageData2(midiEvent[count].message_)=$00)) then
            begin // Off is either because the key is off ($81) or because the
               // velocity (aka pressure) is set to 0 for a touch ($90)
               keyBoardPressed[Pm_MessageData1(midiEvent[count].message_)]:=False;
               // The key is the second byte
            end;
            if (Pm_MessageStatus(midiEvent[count].message_)=$90) and not
            (Pm_MessageData2(midiEvent[count].message_)=$00) then
            begin
                keyBoardPressed[Pm_MessageData1(midiEvent[count].message_)]:=True;
            end;
      end;
   end;

end;


function TMidiKeyboardPressedStream.key_currently_pressed: TIntArray;
var count : integer;
begin
  setLength(result,0);
  for count:=low(keyBoardPressed) to high(keyBoardPressed) do
  begin
     if keyBoardPressed[count] then begin
        setLength(result,high(result)-low(result)+2); // add an element to the dynamic array
        result[high(result)]:=count;
     end;
  end;

end;


// Instantiate the singleton if necessary
procedure createMidiInputDeviceList();
begin
   if midiInputDeviceList = nil then
      midiInputDeviceList := TMidiInputDeviceList.Create;
end;


procedure callback_midiKeyboardPressedStream(midiEvents: array of PmEvent; data: TMidiKeyboardPressedStream);
begin
  data.processEvents(midiEvents);
end;



end.


