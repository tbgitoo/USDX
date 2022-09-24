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
  UMidiInputStream;





type
// Class definition for the options screen for the tapping (accessible through
// Tools -> Options -> Beat Tapping in the english version
  TScreenOptionsMidiInput = class(TMenu)
    private

       // interaction IDs
      ExitButtonIID: integer;
      MidiDeviceForPlayer: integer;

      SelectMidiDeviceGraphicalNum: integer; // This is a mystery number, but we need it for the slide update

    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure UpdateCalculatedSelectSlides(Init: boolean);


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
        end;
  end;

end;



end;

constructor TScreenOptionsMidiInput.Create;
begin
  inherited Create;

  MidiDeviceForPlayer:=0;
  createMidiInputDeviceList;
  LoadFromTheme(Theme.OptionsMidiPlay);
  Theme.OptionsMidiPlay.SelectPlayer.showArrows := true;
  Theme.OptionsMidiPlay.SelectDevice.oneItemOnly := true;
  Theme.OptionsMidiPlay.SelectDevice.showArrows := true;
  AddSelectSlide(Theme.OptionsMidiPlay.SelectPlayer, Ini.MidiPlayPlayerSelected, IKeyPlayPlayers);
  SelectMidiDeviceGraphicalNum:=AddSelectSlide(Theme.OptionsMidiPlay.SelectDevice, MidiDeviceForPlayer, midiInputDeviceList.input_device_names_with_none);


  AddButton(Theme.OptionsMidiPlay.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

  UpdateCalculatedSelectSlides(true); // Calculate dependent slides
  end;



procedure TScreenOptionsMidiInput.UpdateCalculatedSelectSlides(Init: boolean);
begin
  //ConsoleWriteLn(IntToStr(Length(midiInputDeviceList.input_devices)));
  // Get the current player midi device id, -1 is off and so we need to add 1 to match the actual device
  MidiDeviceForPlayer:=midiInputDeviceList.getIndexInList(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected])+1;

  UpdateSelectSlideOptions(Theme.OptionsMidiPlay.SelectDevice,
      SelectMidiDeviceGraphicalNum,midiInputDeviceList.input_device_names_with_none,MidiDeviceForPlayer);



end;

end.
