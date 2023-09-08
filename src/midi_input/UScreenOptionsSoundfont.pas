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
  {$IFDEF UsePortMidi}
  PortMidi,
  {$ELSE}
  Amidi,
  {$ENDIF}
  UFluidSynth,
  UMidiTransfer;





type
  TScreenOptionsSoundfont = class(TMenu)
    private
       // interaction IDs
      ExitButtonIID: integer;
      soundfont_index: integer;
      current_tuning_index: integer;
      current_key_index: integer;

      soundFontTuningGraphicalNum: integer;
      soundFontTuningKeyGraphicalNum: integer;

      midiInputDeviceMessaging: TmidiInputDeviceMessaging; // For reading midi input
      midiOutputDeviceMessaging: TmidiOutputDeviceMessaging; // For transferring midi to fluidsynth midi port

    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure updateFluidSynthFromIni;
      procedure UpdateMidiStream;
      procedure OnShowFinish; override;
      procedure OnHide; override;
      procedure updateTuningSlide;
      procedure updateKeySlide;
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
     countTuning: integer;
     countSoundFont: integer;
begin
  inherited Create;




  midiInputDeviceMessaging:=nil; // For reading midi input
  midiOutputDeviceMessaging:=nil;

  soundfont_index:=Ini.IndexInArray(Ini.SoundfontFluidSynth,Ini.availableSoundFontFiles);
  current_tuning_index:=Ini.IndexInArray(Ini.TuningForSoundFont[soundfont_index],Ini.availableTunings);

  LoadFromTheme(Theme.OptionsSoundfont);
  Theme.OptionsSoundfont.SoundfontFile.showArrows := true;
  Theme.OptionsSoundfont.SoundfontFile.oneItemOnly := true;
  Theme.OptionsSoundfont.SoundfontFile.showArrows := true;


  AddSelectSlide(Theme.OptionsSoundfont.SoundfontFile, soundfont_index, Ini.availableSoundFontFiles);


  Theme.OptionsSoundfont.SoundfontTuning.showArrows := true;
  Theme.OptionsSoundfont.SoundfontTuning.oneItemOnly := true;
  Theme.OptionsSoundfont.SoundfontTuning.showArrows := true;

  soundFontTuningGraphicalNum:=AddSelectSlide(Theme.OptionsSoundfont.SoundfontTuning, current_tuning_index, Ini.availableTunings);


  Theme.OptionsSoundfont.SoundfontTuningKey.showArrows := true;
  Theme.OptionsSoundfont.SoundfontTuningKey.oneItemOnly := true;
  Theme.OptionsSoundfont.SoundfontTuningKey.showArrows := true;

  soundFontTuningKeyGraphicalNum:=AddSelectSlide(Theme.OptionsSoundfont.SoundfontTuningKey, current_key_index, IKey);


  AddButton(Theme.OptionsSoundfont.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

  AddButton(Theme.OptionsSoundfont.ButtonToccata  );
  if (Length(Button[1].Text)=0) then
    AddButtonText(20, 5, Theme.OptionsSoundfont.Description[0]);

  AddButton(Theme.OptionsSoundfont.ButtonFlowerABit  );
  if (Length(Button[2].Text)=0) then
    AddButtonText(20, 5, Theme.OptionsSoundfont.Description[1]);

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



function TScreenOptionsSoundfont.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
var midifile_path: AnsiString;
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
          if SelInteraction = 3 then
          begin
            Ini.Save;
            FadeTo(@ScreenOptionsMidiInput);
          end;

          if SelInteraction = 4 then
          begin
            if not FluidSynthHandler.isPlayingMidiFile() then begin
               FluidSynthHandler.playMidiFile(Platform.GetGameSharedPath.Append('sounds').Append('toccata.mid').ToUTF8());
               updateFluidSynthFromIni;
               fluidSynthHandler.applyTuningFromIni();
            end

            else
               FluidSynthHandler.stopMidiFile();
          end;

          if SelInteraction = 5 then
          begin
            if not FluidSynthHandler.isPlayingMidiFile() then begin
               FluidSynthHandler.playMidiFile(Platform.GetGameSharedPath.Append('sounds').Append('a_bit_of_flower.mid').ToUTF8());
               updateFluidSynthFromIni;
               fluidSynthHandler.applyTuningFromIni();
            end

            else
               FluidSynthHandler.stopMidiFile();
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

        if (SelInteraction >= 0) and (SelInteraction <= 2) then
        begin
             AudioPlayback.PlaySound(SoundLib.Option);
             InteractInc;
        end;

        if SelInteraction=0 then
          begin

            if length(Ini.availableSoundFontFiles)>0 then begin
               Ini.SoundfontFluidSynth:=Ini.availableSoundFontFiles[soundfont_index];
               updateFluidSynthFromIni;
               current_tuning_index:=Ini.IndexInArray(Ini.TuningForSoundFont[soundfont_index],Ini.availableTunings);
               updateTuningSlide;
               fluidSynthHandler.applyTuningFromIni();
            end;
          end;

        if SelInteraction=1 then
          begin
             Ini.TuningForSoundFont[soundfont_index]:= Ini.availableTunings[current_tuning_index];
             fluidSynthHandler.applyTuningFromIni();
          end;

        if SelInteraction=2 then
          begin
             Ini.BaseKeyForSoundFont[soundfont_index]:= IKey[current_key_index];
             fluidSynthHandler.applyTuningFromIni();
          end;



        end;
      SDLK_LEFT:
        begin
        if (SelInteraction >= 0) and (SelInteraction <= 2) then
        begin
             AudioPlayback.PlaySound(SoundLib.Option);
             InteractDec;
        end;
        if SelInteraction=0 then
          begin
            if length(Ini.availableSoundFontFiles)>0 then begin
               Ini.SoundfontFluidSynth:=Ini.availableSoundFontFiles[soundfont_index];
               updateFluidSynthFromIni;
                // we have changed soundfont, now we need to update the tuning according to precedent select
               current_tuning_index:=Ini.IndexInArray(Ini.TuningForSoundFont[soundfont_index],Ini.availableTunings);
               current_key_index:=Ini.IndexInArray(Ini.BaseKeyForSoundFont[soundfont_index],IKey);
               updateTuningSlide;
               updateKeySlide;
               fluidSynthHandler.applyTuningFromIni();
            end;
          end;

        if SelInteraction=1 then
          begin
             Ini.TuningForSoundFont[soundfont_index]:= Ini.availableTunings[current_tuning_index];
             fluidSynthHandler.applyTuningFromIni();
          end;

         if SelInteraction=2 then
          begin
             Ini.BaseKeyForSoundFont[soundfont_index]:= IKey[current_key_index];
             fluidSynthHandler.applyTuningFromIni();
          end;

        end;
  end;

end;



end;

procedure TScreenOptionsSoundfont.updateTuningSlide;
begin

  UpdateSelectSlideOptions(Theme.OptionsSoundfont.SoundfontTuning,
      soundFontTuningGraphicalNum, Ini.availableTunings,current_tuning_index);

end;

procedure TScreenOptionsSoundfont.updateKeySlide;
begin

  UpdateSelectSlideOptions(Theme.OptionsSoundfont.SoundfontTuningKey,
      soundFontTuningKeyGraphicalNum, IKey,current_key_index);

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
   SoundLib.PauseBgMusic;
   UpdateMidiStream;
   fluidSynthHandler.applyTuningFromIni();
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
   FluidSynthHandler.stopMidiFile();
   fluidSynthHandler.StopAudio();

   inherited;
end;






end.
