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
  PortMidi,
  UFluidSynth,
  UMidiTransfer;





type
// Class definition for the options screen for the tapping (accessible through
// Tools -> Options -> Beat Tapping in the english version
  TScreenOptionsMidiInput = class(TMenu)
    private
       // interaction IDs
      ExitButtonIID: integer;
      MidiDeviceForPlayer: integer;   // Local variable to hold the device information for the current player
      SynthesizerForPlayer: integer;
      SynthesizerGainForPlayer: integer;
      SelectMidiDeviceGraphicalNum: integer; // This is a mystery number, but we need it for the slide update
      SelectSynthesizerGraphicalNum: integer;
      SelectSynthesizerGainGraphicalNum: integer;
      midiKeyboardStream: TMidiKeyboardPressedStream;
      midiInputDeviceMessaging: TmidiInputDeviceMessaging; // For reading midi input
      midiOutputDeviceMessaging: TmidiOutputDeviceMessaging; // For transferring midi to fluidsynth midi port
      isShown: boolean;
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

          if SelInteraction = 4 then
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
          if (SelInteraction >= 0) and (SelInteraction <= 3) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
          if SelInteraction=1 then
          begin
            Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]:=MidiDeviceForPlayer-1;
          end;
          if SelInteraction=2 then
          begin
            Ini.PlayerMidiSynthesizerOn[Ini.MidiPlayPlayerSelected]:=SynthesizerForPlayer;
          end;
          if SelInteraction=3 then
          begin
            Ini.PlayerMidiSynthesizerGain[Ini.MidiPlayPlayerSelected]:=SynthesizerGainForPlayer;
            fluidSynthHandler.setGain(getGainFromIniSetting(Ini.PlayerMidiSynthesizerGain[Ini.MidiPlayPlayerSelected]));
          end;




          UpdateCalculatedSelectSlides(false);
          // if SelInteraction = 1 then // Player selected, update letters from known map
           //  UpdateLetterSelection();
           if isShown then UpdateMidiStream;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 3) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
          if SelInteraction=1 then
          begin
            Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]:=MidiDeviceForPlayer-1;
          end;
          if SelInteraction=2 then
          begin
            Ini.PlayerMidiSynthesizerOn[Ini.MidiPlayPlayerSelected]:=SynthesizerForPlayer;
          end;
          if SelInteraction=3 then
          begin
            Ini.PlayerMidiSynthesizerGain[Ini.MidiPlayPlayerSelected]:=SynthesizerGainForPlayer;
            fluidSynthHandler.setGain(getGainFromIniSetting(Ini.PlayerMidiSynthesizerGain[Ini.MidiPlayPlayerSelected]));
          end;




          UpdateCalculatedSelectSlides(false);

          if isShown then UpdateMidiStream;
        end;
  end;

end;



end;

constructor TScreenOptionsMidiInput.Create;
begin
  inherited Create;
  isShown:=false; // The construction takes place at app initiation, this is way before showing
  createfluidSynthHandler(); // In case it hasn't been created yet
  lastEvent.message_:=0;
  lastEvent.timestamp:=0;
  createMidiInputDeviceList;
  MidiDeviceForPlayer:=midiInputDeviceList.getIndexInList(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected])+1;
  SynthesizerForPlayer:=Ini.PlayerMidiSynthesizerOn[Ini.MidiPlayPlayerSelected];
  SynthesizerGainForPlayer:=Ini.PlayerMidiSynthesizerGain[Ini.MidiPlayPlayerSelected];


  LoadFromTheme(Theme.OptionsMidiPlay);
  Theme.OptionsMidiPlay.SelectPlayer.showArrows := true;
  Theme.OptionsMidiPlay.SelectDevice.oneItemOnly := true;
  Theme.OptionsMidiPlay.SelectPlayer.showArrows := true;
  Theme.OptionsMidiPlay.SynthesizerOnOff.showArrows := true;
  Theme.OptionsMidiPlay.SynthesizerOnOff.oneItemOnly := true;
  Theme.OptionsMidiPlay.SynthesizerOnOff.showArrows := true;
  Theme.OptionsMidiPlay.SelectDevice.showArrows := true;
  Theme.OptionsMidiPlay.SelectDevice.oneItemOnly := true;
  Theme.OptionsMidiPlay.SelectDevice.showArrows := true;
  Theme.OptionsMidiPlay.SynthesizerGain.showArrows := true;
  Theme.OptionsMidiPlay.SynthesizerGain.oneItemOnly := true;
  Theme.OptionsMidiPlay.SynthesizerGain.showArrows := true;

  AddSelectSlide(Theme.OptionsMidiPlay.SelectPlayer, Ini.MidiPlayPlayerSelected, IKeyPlayPlayers);
  SelectMidiDeviceGraphicalNum:=AddSelectSlide(Theme.OptionsMidiPlay.SelectDevice,
        MidiDeviceForPlayer, midiInputDeviceList.midi_device_names_with_none);
  SelectSynthesizerGraphicalNum:=AddSelectSlide(Theme.OptionsMidiPlay.SynthesizerOnOff,
        SynthesizerForPlayer, IMidiPlayOn);
  SelectSynthesizerGainGraphicalNum:=AddSelectSlide(Theme.OptionsMidiPlay.SynthesizerGain,
        SynthesizerGainForPlayer, IMidiInputGain);
  midiKeyboardStream:=TMidiKeyboardPressedStream.create;
  midiInputDeviceMessaging:=nil;
  midiOutputDeviceMessaging:=nil;
  AddButton(Theme.OptionsMidiPlay.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

  UpdateCalculatedSelectSlides(true); // Calculate dependent slides
  //UpdateMidiStream;
  end;



procedure TScreenOptionsMidiInput.UpdateCalculatedSelectSlides(Init: boolean);
begin
  MidiDeviceForPlayer:=midiInputDeviceList.getIndexInList(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected])+1;

  UpdateSelectSlideOptions(Theme.OptionsMidiPlay.SelectDevice,
      SelectMidiDeviceGraphicalNum,midiInputDeviceList.midi_device_names_with_none,MidiDeviceForPlayer);

  UpdateSelectSlideOptions(Theme.OptionsMidiPlay.SynthesizerOnOff,
      SelectSynthesizerGraphicalNum,IMidiPlayOn,SynthesizerForPlayer);

  UpdateSelectSlideOptions(Theme.OptionsMidiPlay.SynthesizerGain,
      SelectSynthesizerGainGraphicalNum,IMidiInputGain,SynthesizerGainForPlayer);



end;

procedure TScreenOptionsMidiInput.DrawCaptureField(X, Y, W, H: real);
var test: TText;
    midiMessageString: String;
begin

  if MidiDeviceForPlayer>=0 then
  begin
    //midiStream.readEvents;
    //if midiStream.availableEvents>0 then
    //begin
    //  lastEvent:= midiStream.midiEvent[midiStream.availableEvents-1];

  end;
  midiMessageString:='-';
  if lastEvent.message_ <> 0 then
     midiMessageString:='0x'+IntToHex(lastEvent.message_,3);
  test:=TText.Create(70, 300,midiMessageString);
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
         keyIsPlayed := midiKeyboardStream.keyBoardPressed[midikey];
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
        keyIsPlayed := midiKeyboardStream.keyBoardPressed[midikey];
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
var
  cb_array: array of TMidiInputDeviceMessaging.TCallbackProc;
  cb_data_array: array of pointer;
begin
   //midiStream.setMidiDeviceID(Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]);
   lastEvent.message_:=0;
   lastEvent.timestamp:=0;
   if Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected]>=0 then begin
      fluidSynthHandler.StartAudio();
      fluidSynthHandler.StartMidi();

      if not (midiInputDeviceMessaging=nil) then begin
         midiInputDeviceMessaging.stopTransfer;
         midiInputDeviceMessaging.free;
         midiInputDeviceMessaging:=nil;



      end;
      if midiOutputDeviceMessaging=nil then begin
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
          setLength(cb_array,2);
          setLength(cb_data_array,2);
          cb_array[0]:=@callback_midiKeyboardPressedStream;
          cb_array[1]:=@callback_midiOutputDeviceMessaging;
          cb_data_array[0]:=midiKeyboardStream;
          cb_data_array[1]:=midiOutputDeviceMessaging;
      end else begin // no synthesizer, only analysis (for example with midi keyboard playing acoustically)
          setLength(cb_array,1);
          setLength(cb_data_array,1);
          cb_array[0]:=@callback_midiKeyboardPressedStream;
          cb_data_array[0]:=midiKeyboardStream;
      end;


      midiInputDeviceMessaging:=TMidiInputDeviceMessaging.create(
          Ini.PlayerMidiInputDevice[Ini.MidiPlayPlayerSelected],cb_array,false,cb_data_array);
   end;
end;

procedure TScreenOptionsMidiInput.OnShowFinish;
begin
   isShown:=true;
   // BgMusic distracts too much, pause it
  SoundLib.PauseBgMusic;
   UpdateMidiStream;
   inherited;
end;

procedure TScreenOptionsMidiInput.OnHide;
begin
   if not (midiInputDeviceMessaging=nil) then begin
         midiInputDeviceMessaging.stopTransfer;
         midiInputDeviceMessaging.free;
         midiInputDeviceMessaging:=nil;

   end;
   isShown:=false;
   inherited;
end;





destructor TScreenOptionsMidiInput.Destroy;
begin
   //midiStream.Free;
  inherited;
end;

end.
