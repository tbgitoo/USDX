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


// Interfacing fluidsynth is a tricky affair because it's not as simple
// as it sounds, not just midi in => sound out. The chain is:
  // 1) midi input from other programs or external devices
  // 2) this is captured by the midi driver
  // 3) it is next transmitted to the midi router (via the default callback midi
          //fluidsynth.fluid_midi_router_handle_midi_event
  // 4) The router transmits to the sequencer, which by default just transmits the
  //    notes as the enter to the synthesizer
  // 5) The synthesizer generates the wave form and transmits it to the audio driver

  // The issue with this long chain of events is that if anything goes wrong,
  // you don't get sound at the end of the day


unit UFluidSynth;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}



uses

  cthreads,

  Classes, pasfluidsynth,sysutils;



type
    TFluidsynthHandler = class
    public
    const
      Lehman_III: array[0..11] of double =
        ( 0, -5.865, -3.91, -1.955, -7.82, -1.955, -3.91, -1.955, 0, -5.865, 0, -6 );
        // For testing: then all notes are equal and even the non-musical ones
        // can here whether a tuning is applied
        // (0,-100,-200,-300, -400,-500,-600,-700,-800,-900,-1000,-1100);
      equal: array[0..11] of double = (0,0,0,0,0,0,0,0,0,0,0,0);
      availableTunings: array[0..1] of UTF8String=('none (equal)','Lehman III');

    type
      TAsynchronousSoundFontLoader = class(TThread)

      protected
        theHandler: TFluidsynthHandler;
        procedure Execute; override;



        var
        isLoading: boolean; // If true indicates that we are still doing the loading
      public
        constructor create(handler: TFluidsynthHandler);
        function soundFontLoading(): boolean;


      end;
    protected
      presentSoundFontID: Integer; // Soundfont id internally to fluidsynth. We need this because we only want one soundfont in memory
      currentSoundFont: string;
      soundFontLoader: TAsynchronousSoundFontLoader;
      soundFondLoaded: boolean;
      function getTuningConstantsC(tuningName: UTF8string): PDouble;
      function convertToCTuningConstants(pitch_in_cents: array of double): PDouble;
      procedure applyOctaveTuning(tuningName: UTF8string);

      public
      fluidsynth : TFluidSynth;
      midiDriver: TFluidSynth.PFluidMidiDriver;
      midiRouter: TFluidSynth.PFluidMidiRouter;
      seq_id: TFluidSynth.fluid_seq_id_t;
      midi_port_name: PChar;
      midi_port_id: Integer;
      constructor Create;
      procedure StartAudio();
      procedure StopAudio();
      procedure StartMidi();
      procedure StopMidi();
      procedure setGain(gain: real);
      function audioIsRunning(): boolean;
      function soundFontIsLoaded(): boolean;
      function soundFontFile(): string;
      function midiIsRunning(): boolean;
      procedure updateSoundFontFromIni;
      procedure setGainFromIni();
      procedure sendNotesOff();
      procedure loadSoundFontSynchronous();
      procedure loadSoundFontAsynchronous();
      function get_info_for_channel(chan : Integer; out sfont_id : Integer; out bank_num : Integer; out preset_num : Integer): Integer;
      procedure applyTuningFromIni();
      procedure playMidiFile(filename: UTF8string);
      procedure stopMidiFile();
      function isPlayingMidiFile(): boolean;
    end;




var  // global singleton for the connection to the synthesizer
  fluidSynthHandler: TFluidsynthHandler;

procedure createfluidSynthHandler();

// The idea here is to be able to load soundfonts in the background. This
// is useful for large soundfonts which otherwise cause a noticeable delay
// in program startup.




implementation

uses
  UMidiInputStream, UTextEncoding, UCommon,UPlatform,UIni,UUnicodeUtils;

// Instantiate the singleton if necessary
procedure createfluidSynthHandler();
begin
   if fluidSynthHandler = nil then
   begin
      fluidSynthHandler := TFluidsynthHandler.Create();
      fluidSynthHandler.StartMidi(); // This opens the midi port
   end;
end;

 constructor TFluidSynthHandler.Create;
 begin
   midi_port_name:='fluidsynth_ultrastar_midi_port';
   presentSoundFontID:=-1;
   fluidsynth := TFluidSynth.Create();
   fluidsynth.settings := fluidsynth.new_fluid_settings();
   // For just synthesizing, one could also use autoconnect (although it doesn't seem to work
   // with libfluidsynth, only the executable), but anyways, we need to treat the midi messages
   // to get the keys being hit, and so we need to shuffle the midi messages to
   // fluidsynth AND analyse them.
   fluidsynth.fluid_settings_setstr(fluidsynth.settings,'midi.portname',midi_port_name);
   fluidsynth.fluid_settings_setnum(fluidsynth.settings,'synth.gain',Ini.MidiSynthesizerGainValue);
   // Create the actual synthesizer instance, the TFluidSynth is already a wrapper in pasfluidsynth
   fluidsynth.synth := fluidsynth.new_fluid_synth(fluidsynth.settings);


   fluidsynth.audioDriver:=nil;
   midiDriver:=nil;
   midi_port_id:=-1;
   currentSoundFont:='';
   soundFondLoaded:=false;
   loadSoundFontAsynchronous();
 end;
 // Even if the audio is stopped, fluidsynth will keep track of notes played
 // so to avoid having notes carried over when interrupting audio play,
 // it is necessary to take precautions and swith all notes off direclty at the
 // synthesizer
 procedure TFluidSynthHandler.sendNotesOff();
 var noteIndex:Integer;
     channelIndex:Integer;
 begin
   for noteIndex:=0 to 127 do
     for channelIndex:=0 to 15 do
       fluidsynth.fluid_synth_noteoff(fluidsynth.synth,channelIndex,noteIndex);
 end;


 procedure TFluidSynthHandler.setGainFromIni();
 begin
   setGain(Ini.MidiSynthesizerGainValue);
 end;

 procedure TFluidSynthHandler.setGain(gain: real);
 var
   audioWasRunning:boolean;
 begin
    audioWasRunning:=audioIsRunning();
    StopAudio();
    fluidsynth.fluid_settings_setnum(fluidsynth.settings,'synth.gain',gain);
    if audioWasRunning then startAudio();
 end;

function TFluidSynthHandler.audioIsRunning(): boolean;
begin
  result:=(not (fluidsynth.audioDriver=nil));
end;

function TFluidSynthHandler.midiIsRunning(): boolean;
begin
  result:=(not (midiDriver=nil));
end;

procedure TFluidSynthHandler.updateSoundFontFromIni; // only reload sound font file name is different
begin
  if soundFontIsLoaded() and (UTF8CompareStr(Ini.SoundfontFluidSynth,fluidSynthHandler.soundFontFile())<>0) then
  begin
     loadSoundFontSynchronous();
  end;

end;

procedure TFluidSynthHandler.loadSoundFontSynchronous();  // Forces sound font load, blocking (synchronous, in current thread)
var soundfont_path: AnsiString;
begin
  EncodeStringUTF8(Platform.GetGameSharedPath.Append('soundfonts').Append(Ini.SoundfontFluidSynth).ToUTF8(),
           soundfont_path,encLocale);   // Convert to non-utf8 string
  if soundFondLoaded then begin
     fluidsynth.fluid_synth_sfunload(fluidsynth.synth,presentSoundFontID,1);
     soundFondLoaded:=false;
  end;
  presentSoundFontID:=fluidsynth.fluid_synth_sfload(fluidsynth.synth,
        PChar(soundfont_path), 1); // Type conversion, this has to be PChar

  soundFondLoaded:=true;
  currentSoundFont:=Ini.SoundfontFluidSynth;

end;

procedure TFluidSynthHandler.playMidiFile(filename: UTF8string);
var midifile_path: AnsiString;
begin
  if not (fluidsynth.player=nil) then stopMidiFile();
  fluidsynth.player := fluidsynth.new_fluid_player(fluidsynth.synth);
  EncodeStringUTF8(Platform.GetGameSharedPath.Append('sounds').Append(filename).ToUTF8(),
           midifile_path,encLocale);   // Convert to non-utf8 string
  fluidsynth.fluid_player_add(fluidsynth.player, PChar(midifile_path));
  fluidsynth.fluid_player_play(fluidsynth.player);
end;

procedure TFluidSynthHandler.stopMidiFile();
begin
   if not (fluidsynth.player=nil) then begin
      fluidsynth.fluid_player_stop(fluidsynth.player);
      fluidsynth.delete_fluid_player(fluidsynth.player);
      fluidsynth.player:=nil;
   end;
end;

function TFluidSynthHandler.isPlayingMidiFile(): boolean;
begin
  result:=not (fluidsynth.player=nil);
end;

procedure TFluidSynthHandler.StartAudio;
begin
  if not audioIsRunning() then
  begin
     if not soundFontIsLoaded() then begin // only load the audiofont when really needed, this
        // takes a while


        loadSoundFontSynchronous();
     end;
   // This is starts the synthesis thread, which will produce the actual sound
   // So this is more than an instation, it creates a background process
   // this is however very useful in order to best exploit processing capacity


  fluidsynth.audioDriver := fluidsynth.new_fluid_audio_driver(fluidsynth.settings, fluidsynth.synth);
  // Initialize sequencer, this is the thing that actually dispatches the midi messages directly to the synth
  // Here it is used merely to directly transmit the messages, but it can have call-back and timer functions
  // in general
  fluidsynth.sequencer:=fluidsynth.new_fluid_sequencer2(0);
  // This establishes the connection between sequencer and synthesizer.
   seq_id:=fluidsynth.fluid_sequencer_register_fluidsynth(fluidsynth.sequencer,fluidsynth.synth);
   end;
end;



procedure TFluidSynthHandler.StartMidi;
var
  midiOutputDevices: TMidiDeviceList;
  UTF8PortName: UTF8String;
begin
  if not midiIsRunning() then
  begin

     // The midi router takes midi events and feeds them to the synthesizer
  // This is the default way of doing it:
   midiRouter:=fluidsynth.new_fluid_midi_router(fluidsynth.settings,
   fluidsynth.fluid_synth_handle_midi_event  , fluidsynth.synth);

   // With a custom handle (which should call fluidsynth.fluid_synth_handle_midi_event where
  // appropriate). The handleMidiEvant function needs to have the same signature as
  //fluidsynth.fluid_synth_handle_midi_event
  //midiRouter:=fluidsynth.new_fluid_midi_router(fluidsynth.settings,
   //@handleMidiEvent  , fluidsynth.synth);

   midiDriver:=fluidsynth.new_fluid_midi_driver(fluidsynth.settings, fluidsynth.fluid_midi_router_handle_midi_event, midiRouter);

   // We need not only the port name, but also the port id in order to write to this port for synthesizing
   midiOutputDevices:=TMidiDeviceList.create(false,true);
   DecodeStringUTF8(midi_port_name, UTF8PortName,encLocale);   // Convert to UTF8
   midi_port_id:=midiOutputDevices.getDeviceIdFromDeviceName(UTF8PortName);
   end;
end;


procedure TFluidSynthHandler.StopMidi;
begin
  if midiIsRunning() then
  begin
    fluidsynth.delete_fluid_midi_driver(midiDriver);
    midiDriver:=nil;
    fluidsynth.delete_fluid_midi_router(midiRouter);
    midiRouter:=nil;
  end;
end;

  procedure TFluidSynthHandler.StopAudio;
  begin
    if audioIsRunning() then
    begin
      fluidsynth.delete_fluid_audio_driver(fluidsynth.audioDriver);
      fluidsynth.audioDriver:=nil;
    end;
  end;

  function TFluidSynthHandler.soundFontIsLoaded(): boolean;
  begin
    if not (soundFontLoader = nil) then
      if soundFontLoader.soundFontLoading() then
        soundFontLoader.waitFor();
    result:=soundFondLoaded;
  end;

  function TFluidSynthHandler.soundFontFile(): string;
  begin
    if soundFontIsLoaded() then
       result:=currentSoundFont
    else
       result:='';
  end;

  procedure TFluidSynthHandler.TAsynchronousSoundFontLoader.Execute;
  begin
    if isLoading then
    begin
         theHandler.loadSoundFontSynchronous();
         isLoading:=false;

    end;
  end;

  constructor TFluidSynthHandler.TAsynchronousSoundFontLoader.create(handler: TFluidsynthHandler);
  begin
     theHandler:=handler;
     isLoading:=true;
     inherited create(false);
  end;

  function TFluidSynthHandler.TAsynchronousSoundFontLoader.soundFontLoading(): boolean;
  begin
    result:=isLoading;
  end;

  procedure TFluidSynthHandler.loadSoundFontAsynchronous();
  begin
    soundFontLoader:= TAsynchronousSoundFontLoader.create(self);
  end;

  function TFluidSynthHandler.get_info_for_channel(chan : Integer; out sfont_id : Integer; out bank_num : Integer; out preset_num : Integer): Integer;
  begin
    if not soundFontIsLoaded() then
    begin
       sfont_id := -1;
       bank_num := -1;
       preset_num := -1;
       result:=TFluidSynth.FLUID_FAILED;
       exit;
    end;
    result:=fluidsynth.fluid_synth_get_program(fluidsynth.synth,chan,sfont_id,bank_num,preset_num);
  end;

  function TFluidSynthHandler.getTuningConstantsC(tuningName: UTF8string): PDouble;
  var count: integer;
      pitch: array of double;
  begin
     setlength(pitch,12);
     for count:=0 to 11 do
       pitch[count]:=0; // by default, equal temperament, so zero departure from equal temperament
     if UTF8CompareStr(tuningName,availableTunings[1])=0 then
       for count:=0 to 11 do
           pitch[count]:=Lehman_III[count];
     result:=convertToCTuningConstants(pitch);


  end;



  function TFluidSynthHandler.convertToCTuningConstants(pitch_in_cents: array of double): PDouble;
  var
      pitch_in_cents_12: array of double;
      count: integer;
  begin
    setlength(pitch_in_cents_12,12);
    result:= @pitch_in_cents_12[0];
    for count:=0 to 11 do
       pitch_in_cents_12[count]:=0;
    for count:=low(pitch_in_cents) to high(pitch_in_cents) do
     if count<12 then
         pitch_in_cents_12[count]:=pitch_in_cents[count];
  end;

  procedure TFluidSynthHandler.applyOctaveTuning(tuningName: UTF8string);
  var
      pointer_to_first_note: PDouble;
      count: integer;
      sfont_id : Integer;
      bank_num : Integer;  // this complicated because tuning is technically applied to bank/preset and then selected for a channel
      preset_num : Integer;
      channel: Integer;
  begin
    if not soundFontIsLoaded() then
      exit; // We need a soundfont

    pointer_to_first_note:=getTuningConstantsC(tuningName);

    for channel:=0 to 15 do begin
        if get_info_for_channel(channel,sfont_id,bank_num,preset_num)=TFluidSynth.FLUID_OK then
        begin

           fluidsynth.fluid_synth_activate_octave_tuning(fluidsynth.synth,bank_num, preset_num,
              PChar(tuningName), pointer_to_first_note, 1);
           fluidsynth.fluid_synth_activate_tuning(fluidsynth.synth, channel, bank_num, preset_num,1);
        end;

    end;
  end;

  procedure TFluidSynthHandler.applyTuningFromIni();
  begin
     applyOctaveTuning(Ini.getCurrentTuning());
  end;

end.

