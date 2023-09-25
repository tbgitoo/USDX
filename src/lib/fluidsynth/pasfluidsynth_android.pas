unit pasfluidsynth_android;




interface

{$IFDEF FPC}
  {$MODE DELPHI }
  {$PACKENUM 4}    (* use 4-byte enums *)
  {$PACKRECORDS C} (* C/C++-compatible record packing *)
{$ELSE}
  {$MINENUMSIZE 4} (* use 4-byte enums *)
{$ENDIF}

uses
cTypes,
  ULog;

// Pascal translation of FluidSynth headers by Kirinn Bunnylin / MoonCore.
//   https://gitlab.com/bunnylin/pasfluidsynth
// This header port comes under the ZLib license, so it is safe to use the unit
// with static linking. FluidSynth is available separately under the LGPL 2.1 license,
// and is linked dynamically by this unit.
//
// Should match 2.2.7 API. Not all functions have been translated!
//
// Usage:
// - uses pasfluidsynth;
// - var fluidsynth : TFluidSynth = NIL;
// - fluidsynth := TFluidSynth.Create();
// - try:
//   * writeln(fluidsynth.status);
//   * if NOT fluidsynth.isLoaded then exit;
//   * fluidsynth.settings := fluidsynth.new_fluid_settings();
//   * fluidsynth.synth := fluidsynth.new_fluid_synth(fluidsynth.settings);
//   * var soundfontid := fluidsynth.fluid_synth_sfload(fluidsynth.synth, '/sounds/soundfont.sf2', 1);
//   * fluidsynth.audioDriver := fluidsynth.new_fluid_audio_driver(fluidsynth.settings, fluidsynth.synth);
//   * fluidsynth.player := fluidsynth.new_fluid_player(fluidsynth.synth);
//   * fluidsynth.fluid_player_add(fluidsynth.player, '/music/song.mid');
//   * fluidsynth.fluid_player_play(fluidsynth.player);
//   * Let the user listen to the song! Maybe wait for a keypress to exit.
// - finally: fluidsynth.Destroy;
//
// Are you getting a SIGSEGV segmentation fault or some other trouble?
// - Make sure you call TFluidSynth.methods() always with brackets, even if there are no parameters!
// - Maybe the function you're calling is incorrectly translated here - doublecheck against fluidsynth.org!
// - Maybe a function you need is not translated here - create an issue or pull request at the git repo!
//
// The latest public-facing API headers:
//   https://github.com/FluidSynth/fluidsynth/tree/master/include/fluidsynth
// It's possible to automatically convert some headers using H2Pas:
//   for file in *.h; do h2pas -e -i "$file"; done
// See exactly what's exported from the dynamic link library:
//   nm -l --demangle --dynamic --defined-only --extern-only libfluidsynth.so

// For reference, the FluidSynth license notice:
{ FluidSynth - A Software Synthesizer
*
* Copyright (C) 2003  Peter Hanappe and others.
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation; either version 2.1 of
* the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free
* Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
* 02110-1301, USA
}

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


 const

        fluid_synth_lib = 'libfluidsynth.so';



 type
        PFluidAudioDriver = pointer; // opaque audio driver struct
        PFluidCmdHandler = pointer; // opaque command handler struct, access via fluid_command() and fluid_source()
	PFluidEvent = pointer; // opaque event struct, access via fluid_event_*() and fluid_midi_event_*()
	PFluidFileRenderer = pointer; // opaque file renderer struct, access via fluid_file_renderer_*()
	PFluidMidiDriver = pointer; // opaque midi driver struct
	PFluidMidiEvent = pointer; // opaque midi event struct, access via fluid_event_*() and fluid_midi_event_*()
	PFluidMidiRouterRule = pointer; // opaque router rule struct, access via fluid_midi_router_rule_*()
	PFluidMod = pointer; // opaque soundfont modulator struct, access via fluid_mod_*()
	PFluidPlayer = pointer; // opaque player struct, access via fluid_player_*()
	PFluidPreset = pointer; // opaque preset struct, access via fluid_preset_*() and fluid_sfont_*()
	PFluidSample = pointer; // opaque sample struct, access via fluid_sample_*()
	PFluidSequencer = pointer; // opaque sequencer struct, access via fluid_sequencer_*()
	PFluidServer = pointer; // opaque TCP/IP shell server struct, access via fluid_server_*()
	PFluidSettings = pointer; // opaque settings struct, access via fluid_settings_get/set*()
	PFluidShell = pointer; // opaque command shell struct
	PFluidSoundFont = pointer; // opaque sound font struct, access via fluid_synth_*()
	PFluidSoundFontLoader = pointer; // opaque sound font loader struct, access via fluid_sfloader_*()
	PFluidSynth = pointer; // opaque synth struct, access via fluid_synth_*()
	PFluidVoice = pointer; // opaque voice struct, access via fluid_voice_*()

	fluid_midi_router_t = record
		synth : PFluidSynth;
		rules_mutex : pointer;
		rules : array[0..5] of pointer;
		free_rules : pointer;
		event_handler : pointer;
		event_handler_data : pointer;
		nr_midi_channels : longint;
		cmd_rule : pointer;
		cmd_rule_type : ^longint;
	end;
	PFluidMidiRouter = ^fluid_midi_router_t;

	fluid_istream_t = longint;
	fluid_ostream_t = longint;
	fluid_seq_id_t = smallint;

	fluid_audio_func_t = function(data : pointer; len, nfx : longint; fx : pointer; nout : longint; out_ : pointer) : longint;
	fluid_event_callback_t = procedure(time : dword; event : PFluidEvent; seq : PFluidSequencer; data : pointer);
	handle_midi_event_func_t = function(data : pointer; event : PFluidMidiEvent) : longint;
	handle_midi_tick_func_t = function(data : pointer; tick : longint) : longint;
	fluid_log_function_t = procedure(level : longint; message : pchar; data : pointer);
	fluid_settings_foreach_t = procedure(data : pointer; name : pchar; type_ : longint);
	fluid_settings_foreach_option_t = procedure(data : pointer; name, option : pchar);






type TFluidSynth = class

        public
	const

	FLUID_OK = 0;
	FLUID_FAILED = -1;

	// tempo_type used by fluid_player_set_tempo()
	FLUID_PLAYER_TEMPO_INTERNAL = 0;
	FLUID_PLAYER_TEMPO_EXTERNAL_BPM = 1;
	FLUID_PLAYER_TEMPO_EXTERNAL_MIDI = 2;

	FLUID_PANIC = 0;
	FLUID_ERR = 1;
	FLUID_WARN = 2;
	FLUID_INFO = 3;
	FLUID_DBG = 4;





        public
	var


	settings : PFluidSettings;
	synth : PFluidSynth;
	sequencer : PFluidSequencer;
	player : PFluidPlayer;
	audioDriver : PFluidAudioDriver;
	status : UTF8string;

        public
	constructor Create;

        function new_fluid_settings(): PFluidSettings;
        function fluid_settings_setstr(settings : PFluidSettings; name : pchar; str : pchar) : longint;
        function fluid_settings_setnum(settings : PFluidSettings; name : pchar; val : double) : longint;
        function new_fluid_synth(settings : PFluidSettings) : PFluidSynth;
        function fluid_synth_noteoff(synth : PFluidSynth; chan, key : longint) : longint;
        function fluid_synth_sfunload(synth : PFluidSynth; id, reset_presets : longint) : longint;
        function fluid_synth_sfload(synth : PFluidSynth; filename : pchar; reset_presets : longint) : longint;
        function new_fluid_player(synth : PFluidSynth) : PFluidPlayer;
        function fluid_player_set_loop(player : PFluidPlayer; loop : longint) : longint;
        function fluid_player_add(player : PFluidPlayer; filename : pchar) : longint;
        function fluid_player_play(player : PFluidPlayer) : longint;
        function fluid_player_stop(player : PFluidPlayer) : longint;
        procedure delete_fluid_player(player : PFluidPlayer);
        function new_fluid_audio_driver(settings : PFluidSettings; synth : PFluidSynth) : PFluidAudioDriver;
        function new_fluid_midi_router(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiRouter;
        function fluid_synth_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;
        function new_fluid_midi_driver(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiDriver;
        procedure delete_fluid_midi_driver(driver : PFluidMidiDriver);
        procedure delete_fluid_midi_router(rule : PFluidMidiRouter);
        procedure delete_fluid_audio_driver(driver : PFluidAudioDriver);
        function fluid_synth_get_program(synth : PFluidSynth; chan : longint; out sfont_id : longint; out bank_num : longint; out preset_num : longint) : longint;
        function fluid_synth_activate_octave_tuning(synth : PFluidSynth; bank, prog: longint;
                                   name: pchar; pitch: pdouble; apply:longint): longint;
        function fluid_synth_activate_tuning(synth : PFluidSynth; chan, bank, prog,apply: longint): longint;
        function fluid_player_get_current_tick(player : PFluidPlayer) : longint;
        function fluid_player_seek(player : PFluidPlayer; ticks : longint) : longint;
        function fluid_player_get_status(player : PFluidPlayer) : longint;
        function fluid_player_set_playback_callback(player : PFluidPlayer; handler : handle_midi_event_func_t; handler_data : pointer) : longint;
        function fluid_midi_event_get_channel(evt : PFluidEvent) : longint;
        function fluid_midi_event_get_type(evt : PFluidEvent) : longint;
        function fluid_midi_router_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;



        public
        fluid_synth_handle_midi_event_pointer:handle_midi_event_func_t;
        fluid_midi_router_handle_midi_event_pointer:handle_midi_event_func_t;




end;


function pchar_from_string(str : String): PChar;

function g_fluid_synth_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;
function g_fluid_midi_router_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;


// ------------------------------------------------------------------

implementation

uses strings;

function __new_fluid_settings(): PFluidSettings; cdecl; external fluid_synth_lib name 'new_fluid_settings';
 function __fluid_settings_setstr(settings : PFluidSettings; name : pchar; str : pchar) : longint; cdecl; external fluid_synth_lib name 'fluid_settings_setstr';
 function __fluid_settings_setnum(settings : PFluidSettings; name : pchar; val : double) : longint; cdecl; external fluid_synth_lib name 'fluid_settings_setnum';
 function __new_fluid_synth(settings : PFluidSettings) : PFluidSynth; cdecl; external fluid_synth_lib name 'new_fluid_synth';
 function __fluid_synth_noteoff(synth : PFluidSynth; chan, key : longint) : longint; cdecl;  external fluid_synth_lib name 'fluid_synth_noteoff';
 function __fluid_synth_sfunload(synth : PFluidSynth; id, reset_presets : longint) : longint; cdecl;  external fluid_synth_lib name 'fluid_synth_sfunload';
 function __fluid_synth_sfload(synth : PFluidSynth; filename : pchar; reset_presets : longint) : longint; cdecl;  external fluid_synth_lib name 'fluid_synth_sfload';
 function __new_fluid_player(synth : PFluidSynth) : PFluidPlayer; cdecl;  external fluid_synth_lib name 'new_fluid_player';
 function __fluid_player_set_loop(player : PFluidPlayer; loop : longint) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_set_loop';
 function __fluid_player_add(player : PFluidPlayer; filename : pchar) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_add';
 function __fluid_player_play(player : PFluidPlayer) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_play';
 function __fluid_player_stop(player : PFluidPlayer) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_stop';
 procedure __delete_fluid_player(player : PFluidPlayer); cdecl;  external fluid_synth_lib name 'delete_fluid_player';
 function __new_fluid_audio_driver(settings : PFluidSettings; synth : PFluidSynth) : PFluidAudioDriver; cdecl;  external fluid_synth_lib name 'new_fluid_audio_driver';
 function __new_fluid_midi_router(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiRouter; cdecl;  external fluid_synth_lib name 'new_fluid_midi_router';
 function __fluid_synth_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint; cdecl;  external fluid_synth_lib name 'fluid_synth_handle_midi_event';
 function __new_fluid_midi_driver(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiDriver; cdecl;  external fluid_synth_lib name 'new_fluid_midi_driver';
 procedure __delete_fluid_midi_driver(driver : PFluidMidiDriver); cdecl;  external fluid_synth_lib name 'delete_fluid_midi_driver';
 procedure __delete_fluid_midi_router(rule : PFluidMidiRouter); cdecl;  external fluid_synth_lib name 'delete_fluid_midi_router';
 procedure __delete_fluid_audio_driver(driver : PFluidAudioDriver); cdecl;  external fluid_synth_lib name 'delete_fluid_audio_driver';
 function __fluid_synth_get_program(synth : PFluidSynth; chan : longint; out sfont_id : longint; out bank_num : longint; out preset_num : longint) : longint; cdecl;  external fluid_synth_lib name 'fluid_synth_get_program';
 function __fluid_synth_activate_octave_tuning(synth : PFluidSynth; bank, prog: longint;
                                   name: pchar; pitch: pdouble; apply:longint): longint; cdecl;  external fluid_synth_lib name 'fluid_synth_activate_octave_tuning';
 function __fluid_synth_activate_tuning(synth : PFluidSynth; chan, bank, prog,apply: longint): longint; cdecl;  external fluid_synth_lib name 'fluid_synth_activate_tuning';
 function __fluid_player_get_current_tick(player : PFluidPlayer) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_get_current_tick';
 function __fluid_player_seek(player : PFluidPlayer; ticks : longint) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_seek';
 function __fluid_player_get_status(player : PFluidPlayer) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_get_status';
 function __fluid_player_set_playback_callback(player : PFluidPlayer; handler : handle_midi_event_func_t; handler_data : pointer) : longint; cdecl;  external fluid_synth_lib name 'fluid_player_get_status';
 function __fluid_midi_event_get_channel(evt : PFluidEvent) : longint; cdecl;  external fluid_synth_lib name 'fluid_midi_event_get_channel';
 function __fluid_midi_event_get_type(evt : PFluidEvent) : longint; cdecl;  external fluid_synth_lib name 'fluid_midi_event_get_type';
 function __fluid_midi_router_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint; cdecl;  external fluid_synth_lib name 'fluid_midi_router_handle_midi_event';


function g_fluid_synth_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;
begin
   g_fluid_synth_handle_midi_event:=__fluid_synth_handle_midi_event(data,event);
end;

function g_fluid_midi_router_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;
begin
   g_fluid_midi_router_handle_midi_event:=__fluid_midi_router_handle_midi_event(data,event);
end;

function pchar_from_string(str : String): PChar;
var
  stra: AnsiString;
  p: PChar;
  ind: integer;
begin
   stra:=AnsiString(str);
   p:=StrAlloc(Length(stra) + 1);

   Move(stra[1], p[0], Length(stra));

   p[Length(stra)]:=#0;
   pchar_from_string:=p;
end;


constructor TFluidSynth.Create;
begin
	settings := NIL;
	synth := NIL;

	status := 'Using ' + fluid_synth_lib;

        fluid_synth_handle_midi_event_pointer:=g_fluid_synth_handle_midi_event;
        fluid_midi_router_handle_midi_event_pointer:=g_fluid_midi_router_handle_midi_event;
        Log.LogStatus('pasfluidsynth', status);



end;




function TFluidSynth.new_fluid_settings(): PFluidSettings;
begin
     new_fluid_settings:=__new_fluid_settings();
end;

function TFluidSynth.fluid_settings_setstr(settings : PFluidSettings; name : pchar; str : pchar) : longint;
begin
    fluid_settings_setstr:=__fluid_settings_setstr(settings,name,str);
end;

function TFluidSynth.fluid_settings_setnum(settings : PFluidSettings; name : pchar; val : double) : longint;
begin
    fluid_settings_setnum:=__fluid_settings_setnum(settings,name,val);
end;

function TFluidSynth.new_fluid_synth(settings : PFluidSettings) : PFluidSynth;
begin
    new_fluid_synth:=__new_fluid_synth(settings);
end;

function TFluidSynth.fluid_synth_noteoff(synth : PFluidSynth; chan, key : longint) : longint;
begin
   fluid_synth_noteoff:=__fluid_synth_noteoff(synth,chan,key);
end;

function TFluidSynth.fluid_synth_sfunload(synth : PFluidSynth; id, reset_presets : longint) : longint;
begin
    fluid_synth_sfunload:=__fluid_synth_sfunload(synth,id,reset_presets);
end;

function TFluidSynth.fluid_synth_sfload(synth : PFluidSynth; filename : pchar; reset_presets : longint) : longint;
begin
   fluid_synth_sfload:=__fluid_synth_sfload(synth,filename,reset_presets);
end;

function TFluidSynth.new_fluid_player(synth : PFluidSynth) : PFluidPlayer;
begin
   new_fluid_player:=__new_fluid_player(synth);
end;

function TFluidSynth.fluid_player_set_loop(player : PFluidPlayer; loop : longint) : longint;
begin
   fluid_player_set_loop:=__fluid_player_set_loop(player,loop);
end;

function TFluidSynth.fluid_player_add(player : PFluidPlayer; filename : pchar) : longint;
begin
   fluid_player_add:=__fluid_player_add(player,filename);
end;

function TFluidSynth.fluid_player_play(player : PFluidPlayer) : longint;
begin
  fluid_player_play:=__fluid_player_play(player);
end;

function TFluidSynth.fluid_player_stop(player : PFluidPlayer) : longint;
begin
   fluid_player_stop:=__fluid_player_stop(player);
end;

procedure TFluidSynth.delete_fluid_player(player : PFluidPlayer);
begin
   __delete_fluid_player(player);
end;

function TFluidSynth.new_fluid_audio_driver(settings : PFluidSettings; synth : PFluidSynth) : PFluidAudioDriver;
begin
   new_fluid_audio_driver:=__new_fluid_audio_driver(settings,synth);
end;

function TFluidSynth.new_fluid_midi_router(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiRouter;
begin
   new_fluid_midi_router:=__new_fluid_midi_router(settings,handler,event_handler_data);
end;

function TFluidSynth.fluid_synth_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;
begin
   fluid_synth_handle_midi_event:=__fluid_synth_handle_midi_event(data,event);
end;

function TFluidSynth.new_fluid_midi_driver(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiDriver;
begin
  new_fluid_midi_driver:=__new_fluid_midi_driver(settings,handler,event_handler_data);
end;

procedure TFluidSynth.delete_fluid_midi_driver(driver : PFluidMidiDriver);
begin
  __delete_fluid_midi_driver(driver);
end;

procedure TFluidSynth.delete_fluid_midi_router(rule : PFluidMidiRouter);
begin
   __delete_fluid_midi_router(rule);
end;

procedure TFluidSynth.delete_fluid_audio_driver(driver : PFluidAudioDriver);
begin
   __delete_fluid_audio_driver(driver);
end;

function TFluidSynth.fluid_synth_get_program(synth : PFluidSynth; chan : longint; out sfont_id : longint; out bank_num : longint; out preset_num : longint) : longint;
begin
   fluid_synth_get_program:=__fluid_synth_get_program(synth,chan,sfont_id,bank_num,preset_num);
end;

function TFluidSynth.fluid_synth_activate_octave_tuning(synth : PFluidSynth; bank, prog: longint;
   name: pchar; pitch: pdouble; apply:longint): longint;
begin
   fluid_synth_activate_octave_tuning:=__fluid_synth_activate_octave_tuning(synth,bank,prog,name,pitch,apply);
end;

function TFluidSynth.fluid_synth_activate_tuning(synth : PFluidSynth; chan, bank, prog,apply: longint): longint;
begin
   fluid_synth_activate_tuning:=__fluid_synth_activate_tuning(synth,chan,bank,prog,apply);
end;

function TFluidSynth.fluid_player_get_current_tick(player : PFluidPlayer) : longint;
begin
   fluid_player_get_current_tick:=__fluid_player_get_current_tick(player);
end;

function TFluidSynth.fluid_player_seek(player : PFluidPlayer; ticks : longint) : longint;
begin
   fluid_player_seek:=__fluid_player_seek(player,ticks);
end;

function TFluidSynth.fluid_player_get_status(player : PFluidPlayer) : longint;
begin
   fluid_player_get_status:=__fluid_player_get_status(player);
end;

function TFluidSynth.fluid_player_set_playback_callback(player : PFluidPlayer; handler : handle_midi_event_func_t; handler_data : pointer) : longint;
begin
   fluid_player_set_playback_callback:=__fluid_player_set_playback_callback(player,handler,handler_data);
end;

function TFluidSynth.fluid_midi_event_get_channel(evt : PFluidEvent) : longint;
begin
   fluid_midi_event_get_channel:=__fluid_midi_event_get_channel(evt);
end;

function TFluidSynth.fluid_midi_event_get_type(evt : PFluidEvent) : longint;
begin
   fluid_midi_event_get_type:=__fluid_midi_event_get_type(evt);
end;

function TFluidSynth.fluid_midi_router_handle_midi_event(data : pointer; event : PFluidMidiEvent) : longint;
begin
    fluid_midi_router_handle_midi_event:=__fluid_midi_router_handle_midi_event(data,event);
end;


end.

