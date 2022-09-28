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

unit UScreenOptionsMidiInput;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UDisplay,
  UFiles,
  UIni,
  UMenu,
  UMusic,
  UThemes,
  URecord,
  sdl2,
  UMidiInputStream,
  UMenuText,
  PortMidi;





type
// Class definition for the options screen for the tapping (accessible through
// Tools -> Options -> Beat Tapping in the english version
  TScreenOptionsMidiInput = class(TMenu)
    private

       // interaction IDs
      ExitButtonIID: integer;
      MidiDeviceForPlayer: integer;
      SelectMidiDeviceGraphicalNum: integer; // This is a mystery number, but we need it for the slide update
      midiStream: TMidiKeyboardPressedStream;
    public
      lastEvent: PmEvent;
      constructor Create; override;
      destructor Destroy; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure UpdateCalculatedSelectSlides(Init: boolean);
      procedure UpdateMidiStream;
      procedure DrawCaptureField(X, Y, W, H: real);
      procedure DrawPiano(X, Y, W, H: real; lowerOctave: integer; upperOctave: integer);
      function  Draw: boolean; override;


  end;


implementation

uses
  UGraphic,
  UHelp,
  ULog,
  UUnicodeUtils,
  SysUtils,
  dglOpenGL,
  UCommon,
  TextGL;


function TScreenOptionsMidiInput.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptionsBeatPlay);
        end;
      SDLK_TAB:
      begin
        ScreenPopupHelp.ShowPopup();
      end;
      SDLK_RETURN:
        begin

          if SelInteraction = 2 then
          begin
            Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenOptionsBeatPlay);
          end;
        end;
      SDLK_DOWN:
        begin
        InteractNext;

        end;
      SDLK_UP :
        begin
        InteractPrev;

        end;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 1) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
          if SelInteraction=1 then
          begin
            Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]:=MidiDeviceForPlayer-1;
          end;
          UpdateCalculatedSelectSlides(false);
          // if SelInteraction = 1 then // Player selected, update letters from known map
           //  UpdateLetterSelection();
           UpdateMidiStream;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 1) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
          if SelInteraction=1 then
          begin
            Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]:=MidiDeviceForPlayer-1;
          end;
          UpdateCalculatedSelectSlides(false);
          //if SelInteraction = 1 then // Player selected, update letters from known map
          //   UpdateLetterSelection();
          UpdateMidiStream;
        end;
  end;

end;



end;

constructor TScreenOptionsMidiInput.Create;
begin
  inherited Create;
  lastEvent.message_:=0;
  lastEvent.timestamp:=0;
  MidiDeviceForPlayer:=0;
  createMidiInputDeviceList;
  LoadFromTheme(Theme.OptionsMidiPlay);
  Theme.OptionsMidiPlay.SelectPlayer.showArrows := true;
  Theme.OptionsMidiPlay.SelectDevice.oneItemOnly := true;
  Theme.OptionsMidiPlay.SelectDevice.showArrows := true;
  AddSelectSlide(Theme.OptionsMidiPlay.SelectPlayer, Ini.MidiPlayPlayerSelected, IKeyPlayPlayers);
  SelectMidiDeviceGraphicalNum:=AddSelectSlide(Theme.OptionsMidiPlay.SelectDevice, MidiDeviceForPlayer, midiInputDeviceList.input_device_names_with_none);
  midiStream:=TMidiKeyboardPressedStream.create;

  AddButton(Theme.OptionsMidiPlay.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

  UpdateCalculatedSelectSlides(true); // Calculate dependent slides
  UpdateMidiStream;
  end;



procedure TScreenOptionsMidiInput.UpdateCalculatedSelectSlides(Init: boolean);
begin
  //ConsoleWriteLn(IntToStr(Length(midiInputDeviceList.input_devices)));
  // Get the current player midi device id, -1 is off and so we need to add 1 to match the actual device
  MidiDeviceForPlayer:=midiInputDeviceList.getIndexInList(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected])+1;

  UpdateSelectSlideOptions(Theme.OptionsMidiPlay.SelectDevice,
      SelectMidiDeviceGraphicalNum,midiInputDeviceList.input_device_names_with_none,MidiDeviceForPlayer);



end;

procedure TScreenOptionsMidiInput.DrawCaptureField(X, Y, W, H: real);
var test: TText;
    midiMessageString: String;
begin

  if MidiDeviceForPlayer>=0 then
  begin
    midiStream.readEvents;
    if midiStream.availableEvents>0 then
    begin
      lastEvent:= midiStream.midiEvent[midiStream.availableEvents-1];
    end;
  end;
  midiMessageString:='-';
  if lastEvent.message_ <> 0 then
     midiMessageString:='0x'+IntToHex(lastEvent.message_,3);
  test:=TText.Create(70, 300,IntToHex(lastEvent.message_,3));
  test.Draw;






end;

procedure TScreenOptionsMidiInput.DrawPiano(X, Y, W, H: real; lowerOctave: integer; upperOctave: integer);
var
  n_white_key:integer;  // white keys that we have to draw
  count:integer;
  n_total:integer; // Total number of keys to be drawn, including the black ones
  count_white:integer;
  midikey: integer;
  keyIsPlayed: boolean;
begin
   n_white_key:=(upperOctave-lowerOctave+1)*7+1; // White keys
   n_total:=(upperOctave-lowerOctave+1)*12+1; // plus the five black ones
   count_white:=0;
   for count:=0 to (n_total-1) do begin
      midikey := 60 + (lowerOctave-4)*12+count;
      keyIsPlayed := False;

      if (MidiDeviceForPlayer>=0) and (midikey >= 0) and (midikey <= 127) then begin
         keyIsPlayed := midiStream.keyBoardPressed[midikey];
      end;

      if ((count mod 12)=1) or ((count mod 12)=3) or ((count mod 12)=6) or ((count mod 12)=8) or ((count mod 12)=10) then
      begin
        // We wall draw the black keys afterwards, otherwise this will be hidden
      end else
      begin // white keys
       if keyIsPlayed then
          glColor3f(100.0/255.0, 180.0/255.0, 255.0/255.0)
       else
          glColor3f(255, 255, 255);
       glBegin(GL_QUADS);
       glVertex2f(X+W/n_white_key*count_white , Y);
       glVertex2f(X+W/n_white_key*count_white , Y+H);
       glVertex2f(X+W/n_white_key*(count_white+1.0) , Y+H);
       glVertex2f(X+W/n_white_key*(count_white+1.0) , Y);
      glEnd;

      glColor3f(0, 0, 0);

       glBegin(GL_LINE_STRIP);
       glVertex2f(X+W/n_white_key*count_white , Y);
       glVertex2f(X+W/n_white_key*count_white , Y+H);
       glVertex2f(X+W/n_white_key*(count_white+1.0) , Y+H);
       glVertex2f(X+W/n_white_key*(count_white+1.0) , Y);
       glVertex2f(X+W/n_white_key*count_white , Y);
      glEnd;

      count_white:=count_white+1;

      end;




   end;
   count_white:=0;
   for count:=0 to (n_total-1) do begin
       midikey := 60 + (lowerOctave-4)*12+count;
       keyIsPlayed := False;
      if (MidiDeviceForPlayer>=0) and (midikey >= 0) and (midikey <= 127) then
        keyIsPlayed := midiStream.keyBoardPressed[midikey];
      if ((count mod 12)=1) or ((count mod 12)=3) or ((count mod 12)=6) or ((count mod 12)=8) or ((count mod 12)=10) then
      begin

        if keyIsPlayed then
          glColor3f(50.0/255.0, 120.0/255.0, 200.0/255.0)
       else
          glColor3f(0, 0, 0);
      glBegin(GL_QUADS);
       glVertex2f(X+W/n_white_key*(count_white-0.25) , Y);
       glVertex2f(X+W/n_white_key*(count_white-0.25) , Y+H*0.6);
       glVertex2f(X+W/n_white_key*(count_white+0.25) , Y+H*0.6);
       glVertex2f(X+W/n_white_key*(count_white+0.25) , Y);
      glEnd;
      end else
      begin // white keys, but we've already drawn them


            count_white:=count_white+1;

      end;




   end;


end;

function TScreenOptionsMidiInput.Draw: boolean;

begin
  DrawBG;
  DrawFG;

  DrawCaptureField(70, 300, 200, 40);

  DrawPiano(70,350,600,100,2,5);



  Result := true;
end;

procedure TScreenOptionsMidiInput.UpdateMidiStream;
begin
   midiStream.setMidiDeviceID(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]);
   lastEvent.message_:=0;
   lastEvent.timestamp:=0;
end;

destructor TScreenOptionsMidiInput.Destroy;
begin
   midiStream.Free;
  inherited;
end;

end.
