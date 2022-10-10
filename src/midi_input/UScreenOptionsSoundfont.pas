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

unit UScreenOptionsSoundfont;

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
  PortMidi,
  UFluidSynth,
  UMidiTransfer;





type
  TScreenOptionsSoundfont = class(TMenu)
    private
       // interaction IDs
      ExitButtonIID: integer;
      soundfont_index: integer;
      midiInputDeviceMessaging: TmidiInputDeviceMessaging; // For reading midi input
      midiOutputDeviceMessaging: TmidiOutputDeviceMessaging; // For transferring midi to fluidsynth midi port

    public
      availableSoundFontFiles: array of UTF8String;
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure scanAvailableSoundFontFiles;
      procedure updateFluidSynthFromIni;
      procedure UpdateMidiStream;
      procedure OnShowFinish; override;
      procedure OnHide; override;

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
  TextGL,
  UPlatform,
  UTextEncoding,
  UFileSystem,
  UPath;





constructor TScreenOptionsSoundfont.Create;
var soundfontpath : string;
     firstPart: string;
     secondPart: string;
begin
  inherited Create;

  midiInputDeviceMessaging:=nil; // For reading midi input
  midiOutputDeviceMessaging:=nil;

  soundfont_index:=0;

  LoadFromTheme(Theme.OptionsSoundfont);
  Theme.OptionsSoundfont.SoundfontFile.showArrows := true;
  Theme.OptionsSoundfont.SoundfontFile.oneItemOnly := true;
  Theme.OptionsSoundfont.SoundfontFile.showArrows := true;

  scanAvailableSoundFontFiles();

  AddSelectSlide(Theme.OptionsSoundfont.SoundfontFile, soundfont_index, availableSoundFontFiles);

  AddButton(Theme.OptionsSoundfont.ButtonExit);


  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);


  AddButton(Theme.OptionsSoundfont.ButtonPath);
  EncodeStringUTF8(Platform.GetGameSharedPath.Append('soundfonts').ToUTF8(),
           soundfontpath,encLocale);
  // Usually, the string is too long to fit into the box, separate the common part
  // up to, but without the UltraStarDeluxe application support folder in a first line and
  // Ultrastar part + the soundfont specific part to a second line
  if length(soundfontpath)<50 then begin
    AddButtonText(20, 5, soundfontpath);
  end
  else
  begin
  if Pos('UltraStarDeluxe',soundfontpath) > 0 then begin
      firstPart := copy(soundfontpath,0,Pos('UltraStarDeluxe',soundfontpath)-1);
      secondPart := copy(soundfontpath,Pos('UltraStarDeluxe',soundfontpath),
           length(soundfontpath)-Pos('UltraStarDeluxe',soundfontpath)+1);
      AddButtonText(20, 5, firstPart+'\n'+secondPart);
  end else
  begin
     firstPart := copy(soundfontpath,0,50-1);
      secondPart := copy(soundfontpath,50,
           length(soundfontpath)-50+1);
      AddButtonText(20, 5, firstPart+'\n'+secondPart);

  end;
  end;


  end;


procedure TScreenOptionsSoundfont.updateFluidSynthFromIni;
begin
  // We only load a new soundfont if an incorrect sound font is already loaded
  if fluidSynthHandler.soundFontIsLoaded() and
     (UTF8CompareStr(Ini.SoundfontFluidSynth,fluidSynthHandler.soundFontFile())<>0) then
       begin
           if fluidSynthHandler.audioIsRunning() then begin
              fluidSynthHandler.StopAudio();
              fluidSynthHandler.updateSoundFontFromIni();
              fluidSynthHandler.StartAudio();
           end else
           begin
              fluidSynthHandler.updateSoundFontFromIni();
           end;


       end;



end;

procedure TScreenOptionsSoundfont.scanAvailableSoundFontFiles;
var

     file_listing: IFileIterator;
     working_directory: IPath;
begin
  working_directory:=FileSystem().GetCurrentDir();

  FileSystem().SetCurrentDir(Platform.GetGameSharedPath.Append('soundfonts'));

  file_listing:=FileSystem().FileFind(Path('*.sf*'),0);

  setLength(availableSoundFontFiles,0);

   while(file_listing.HasNext()) do
   begin
      setLength(availableSoundFontFiles,High(availableSoundFontFiles)-Low(availableSoundFontFiles)+2);
      availableSoundFontFiles[High(availableSoundFontFiles)]:=file_listing.Next().Name.ToUTF8();
      if UTF8CompareStr(Ini.SoundfontFluidSynth,availableSoundFontFiles[High(availableSoundFontFiles)])=0 then
        soundfont_index:=High(availableSoundFontFiles);
   end;




  FileSystem().SetCurrentDir(working_directory); // Reset working directory to what it was before

end;

function TScreenOptionsSoundfont.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
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
          FadeTo(@ScreenOptionsMidiInput);

        end;
      SDLK_TAB:
      begin
        ScreenPopupHelp.ShowPopup();
      end;
      SDLK_RETURN:
        begin
          if SelInteraction = 1 then
          begin
            Ini.Save;
            FadeTo(@ScreenOptionsMidiInput);
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

        if SelInteraction=0 then
        begin
             AudioPlayback.PlaySound(SoundLib.Option);
             InteractInc;
        end;

        if SelInteraction=0 then
          begin

            if length(availableSoundFontFiles)>0 then begin
               Ini.SoundfontFluidSynth:=availableSoundFontFiles[soundfont_index];
               updateFluidSynthFromIni;
            end;
          end;

        end;
      SDLK_LEFT:
        begin
        if SelInteraction=0 then
        begin
             AudioPlayback.PlaySound(SoundLib.Option);
             InteractDec;
        end;
           if SelInteraction=0 then
          begin
            if length(availableSoundFontFiles)>0 then begin
               Ini.SoundfontFluidSynth:=availableSoundFontFiles[soundfont_index];
               updateFluidSynthFromIni;
            end;
          end;

        end;
  end;

end;



end;


procedure TScreenOptionsSoundfont.UpdateMidiStream;
var
  cb_array: array of TMidiInputDeviceMessaging.TCallbackProc;
  cb_data_array: array of pointer;
begin
   //midiStream.setMidiDeviceID(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]);

   if Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]>=0 then begin

      fluidSynthHandler.StartAudio();
      fluidSynthHandler.StartMidi();

      if not (midiInputDeviceMessaging=nil) then begin
         midiInputDeviceMessaging.stopTransfer;
         midiInputDeviceMessaging.free;
         midiInputDeviceMessaging:=nil;



      end;

      if (Ini.PlayerMidiSynthesizerOn[Ini.MidiPlayPlayerSelected]=1) and (midiOutputDeviceMessaging=nil) then begin
        midiOutputDeviceMessaging:=TMidiOutputDeviceMessaging.create(fluidSynthHandler.midi_port_id);


        // Here we indicate the port of the fluidsynth so that we can transfer
        // the midi packets fromt he midiInputDeviceMessaging to
        // fluidSynthHandler via midiOutputDeviceMessaging
      end;

      // Whether or not we transmit the midi information to the synthesizer depends on
      // synthesizer setting for the current player
      if Ini.PlayerMidiSynthesizerOn[Ini.MidiPlayPlayerSelected]=1 then begin
         // This is the case where Ultrastar acts as a synthesizer, include synthesizer callback
         // via the midiOutputDeviceMessaging system which transmits the midi messages
         // to the midi port of the internal fluidsynth

          setLength(cb_array,1);
          setLength(cb_data_array,1);
          cb_array[0]:=@callback_midiOutputDeviceMessaging;
          cb_data_array[0]:=midiOutputDeviceMessaging;
          midiInputDeviceMessaging:=TMidiInputDeviceMessaging.create(
          Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected],cb_array,false,cb_data_array);
      end;



   end;
end;

procedure TScreenOptionsSoundfont.OnShowFinish;
begin
   UpdateMidiStream;
   inherited;
end;

procedure TScreenOptionsSoundfont.OnHide;
begin
   if not (midiInputDeviceMessaging=nil) then begin
         midiInputDeviceMessaging.stopTransfer;
         midiInputDeviceMessaging.free;
         midiInputDeviceMessaging:=nil;

   end;
   if not (midiOutputDeviceMessaging=nil) then begin
         midiOutputDeviceMessaging.closeOutput;
         midiOutputDeviceMessaging.free;
         midiOutputDeviceMessaging:=nil;

   end;

   fluidSynthHandler.StopAudio();

   inherited;
end;




end.
