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
  TMidiThrough = class(TThread)
   protected
       ready: boolean; // indicates that everything has been set up succesfully for transferring
       running: boolean; // indicates that we are actually transferring
       deviceInfoSource: PPmDeviceInfo;
       deviceInfoDestination: PPmDeviceInfo;
       PmidiStreamSource: PPortMidiStream;
       midiStreamSource: PortMidiStream;
       PmidiStreamDestination: PPortMidiStream;
       midiStreamDestination: PortMidiStream;
       PmidiEvent: PPmEvent;
       midiEvent: array[0..4095] of PmEvent; // Buffer for reading midi events
       availableEvents: Integer;
       procedure Execute; override;
       function OpenInput(id: PmDeviceID): PmError;
       function OpenOutput(id: PmDeviceID): PmError;
       procedure CloseInput();
       procedure CloseOutput();
   public
         procedure TransferMessages;
         constructor create(id_source: Integer; id_destination: Integer);
  end;





implementation

uses
  UFluidSynth;


function TMidiThrough.OpenInput(id: PmDeviceID): PmError;
 begin
    result:=Pm_OpenInput(PmidiStreamSource, id, nil,4095,nil, nil );
 end;

function TMidiThrough.OpenOutput(id: PmDeviceID): PmError;
begin
  result:=Pm_OpenOutput(PmidiStreamDestination, id, nil,4095,nil, nil,0 );
end;

procedure TMidiThrough.CloseInput();
begin
  Pm_Close(midiStreamSource);
  ready:=False;
end;

procedure TMidiThrough.CloseOutput();
begin
  Pm_Close(midiStreamDestination);
  ready:=False;
end;



constructor TMidiThrough.Create(id_source: Integer; id_destination: Integer);
begin
 running:=false;
 ready:=false;
 Pm_Initialize(); // Just in case this hasn't been done elsewhere
 deviceInfoSource:=Pm_GetDeviceInfo(id_source);
   if not (deviceInfoSource = nil) then
      if OpenInput(id_source) >=0 then // succesfully opened source port
      begin
        deviceInfoDestination:=Pm_GetDeviceInfo(id_destination);
        if not (deviceInfoDestination = nil) then
          if OpenOutput(id_destination) >= 0 then // succesfully opened destination port
          begin
            ready:=true;
          end;
      end;
 inherited create(false);
 running:=true;
 FreeOnTerminate := true;
end;


procedure TMidiThrough.Execute;
begin
 while running do
 begin
   ConsoleWriteLn('Executing');
   sleep(1);
 end;

end;

procedure TMidiThrough.TransferMessages;
begin

end;


end.




