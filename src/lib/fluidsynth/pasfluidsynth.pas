unit pasfluidsynth;

{$mode objfpc}

{$IFDEF LINKOBJECT}
  {$LINKLIB fluidsynth.o}
{$ELSE}
  {$IFDEF Darwin}
    {$LINKLIB libfluidsynth}
  {$ENDIF}
{$ENDIF}


interface

uses
  {$ifdef LOAD_PA_ON_RUNTIME}
  dynlibs,
  {$endif}
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
        protected
        procedure _GetFunc(dest : pointer; const funcname : ansistring); inline; // Get the pointer to a given fluidsynth function
        procedure _GetFuncs(); // populate the points to all the fluidsynth functions
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



	var
	delete_fluid_audio_driver : procedure(driver : PFluidAudioDriver);
	delete_fluid_cmd_handler : procedure(handler : PFluidCmdHandler);
	delete_fluid_event : procedure(evt : PFluidEvent);
	delete_fluid_file_renderer : procedure(dev : PFluidFileRenderer);
	delete_fluid_midi_driver : procedure(driver : PFluidMidiDriver);
	delete_fluid_midi_event : procedure(evt : PFluidMidiEvent);
	delete_fluid_midi_router : procedure(rule : PFluidMidiRouter);
	delete_fluid_midi_router_rule : procedure(rule : PFluidMidiRouterRule);
	delete_fluid_mod : procedure(mod_ : PFluidMod);
	//delete_fluid_note_container : procedure?
	delete_fluid_player : procedure(player : PFluidPlayer);
	delete_fluid_preset : procedure(preset : PFluidPreset);
	delete_fluid_sample : procedure(sample : PFluidSample);
	delete_fluid_sequencer : procedure(seq : PFluidSequencer);
	//delete_fluid_seq_queue : procedure?
	delete_fluid_server : procedure(server : PFluidServer);
	delete_fluid_settings : procedure(settings : PFluidSettings);
	delete_fluid_sfloader : procedure(loader : PFluidSoundFontLoader);
	delete_fluid_sfont : function(sfont : PFluidSoundFont) : longint;
	delete_fluid_shell : procedure(shell : PFluidShell);
	delete_fluid_synth : procedure(synth : PFluidSynth);
	//event_compare_for_test
	fluid_audio_driver_register : function(adrivers : pointer) : longint;
	//fluid_cmd_handler_set_synth : procedure(handler : PFluidCmdHandler; synth : PFluidSynth);
	fluid_command : function(handler : PFluidCmdHandler; cmd : pchar; out_ : fluid_ostream_t) : longint;
	fluid_default_log_function : procedure(level : longint; message : pchar; data : pointer);
	fluid_event_all_notes_off : procedure(evt : PFluidEvent; channel : longint);
	fluid_event_all_sounds_off : procedure(evt : PFluidEvent; channel : longint);
	fluid_event_bank_select : procedure(evt : PFluidEvent; channel : longint; bank_num : smallint);
	fluid_event_channel_pressure : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_chorus_send : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_control_change : procedure(evt : PFluidEvent; channel : longint; control : smallint; val : longint);
	fluid_event_from_midi_event : function(evt : PFluidEvent; event : PFluidMidiEvent) : longint;
	//fluid_event_get_bank
	//fluid_event_get_channel
	//fluid_event_get_control
	//fluid_event_get_data
	//fluid_event_get_dest
	//fluid_event_get_duration
	//fluid_event_get_key
	//fluid_event_get_pitch
	//fluid_event_get_program
	//fluid_event_get_scale
	//fluid_event_get_sfont_id
	//fluid_event_get_source
	//fluid_event_get_type
	//fluid_event_get_value
	//fluid_event_get_velocity
	fluid_event_key_pressure : procedure(evt : PFluidEvent; channel : longint; key : smallint; val : longint);
	fluid_event_modulation : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_note : procedure(evt : PFluidEvent; channel : longint; key, vel : smallint; duration : dword);
	fluid_event_noteoff : procedure(evt : PFluidEvent; channel : longint; key : smallint);
	fluid_event_noteon : procedure(evt : PFluidEvent; channel : longint; key, vel : smallint);
	fluid_event_pan : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_pitch_bend : procedure(evt : PFluidEvent; channel, pitch : longint);
	fluid_event_pitch_wheelsens : procedure(evt : PFluidEvent; channel, value : longint);
	fluid_event_program_change : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_program_select : procedure(evt : PFluidEvent; channel : longint; sfont_id : dword; bank_num, preset_num : smallint);
	fluid_event_reverb_send : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_scale : procedure(evt : PFluidEvent; new_scale : double);
	fluid_event_set_dest : procedure(evt : PFluidEvent; dest : fluid_seq_id_t);
	fluid_event_set_source : procedure(evt : PFluidEvent; src : fluid_seq_id_t);
	fluid_event_sustain : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_event_system_reset : procedure(evt : PFluidEvent);
	fluid_event_timer : procedure(evt : PFluidEvent; data : pointer);
	fluid_event_unregistering : procedure(evt : PFluidEvent);
	fluid_event_volume : procedure(evt : PFluidEvent; channel, val : longint);
	fluid_file_renderer_process_block : function(dev : PFluidFileRenderer) : longint;
	fluid_file_set_encoding_quality : function(dev : PFluidFileRenderer; q : double) : longint;
	fluid_free : procedure(ptr : pointer); // only call this if the API explicitly tells you to!
	//fluid_get_stdin
	//fluid_get_stdout
	//fluid_get_sysconf
	//fluid_get_userconf
	fluid_is_midifile : function(filename : pchar) : longint;
	fluid_is_soundfont : function(filename : pchar) : longint;
	//fluid_ladspa_activate
	//fluid_ladspa_add_buffer
	//fluid_ladspa_add_effect
	//fluid_ladspa_buffer_exists
	//fluid_ladspa_check
	//fluid_ladspa_deactivate
	//fluid_ladspa_effect_can_mix
	//fluid_ladspa_effect_link
	//fluid_ladspa_effect_port_exists
	//fluid_ladspa_effect_set_control
	//fluid_ladspa_effect_set_mix
	//fluid_ladspa_host_port_exists
	//fluid_ladspa_is_active
	//fluid_ladspa_reset
	//fluid_log : function(level : longint; fmt : pchar; params : array of object) : longint;
	//fluid_midi_dump_postrouter
	//fluid_midi_dump_prerouter
	fluid_midi_event_get_channel : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_control : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_key : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_lyrics : function(evt : PFluidEvent; out data : pointer; out size : longint) : longint;
	fluid_midi_event_get_pitch : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_program : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_text : function(evt : PFluidEvent; out data : pointer; out size : longint) : longint;
	fluid_midi_event_get_type : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_value : function(evt : PFluidEvent) : longint;
	fluid_midi_event_get_velocity : function(evt : PFluidEvent) : longint;
	//fluid_midi_event_set_channel
	//fluid_midi_event_set_control
	//fluid_midi_event_set_key
	//fluid_midi_event_set_lyrics
	//fluid_midi_event_set_pitch
	//fluid_midi_event_set_program
	//fluid_midi_event_set_sysex
	//fluid_midi_event_set_text
	//fluid_midi_event_set_type
	//fluid_midi_event_set_value
	//fluid_midi_event_set_velocity
	fluid_midi_router_add_rule : function(router : PFluidMidiRouter; rule : PFluidMidiRouterRule; type_ : longint) : longint;
	fluid_midi_router_clear_rules : function(router : PFluidMidiRouter) : longint;
	fluid_midi_router_handle_midi_event : function(data : pointer; event : PFluidMidiEvent) : longint;
	fluid_midi_router_rule_set_chan : procedure(rule : PFluidMidiRouterRule; min, max : longint; mul : single; add : longint);
	fluid_midi_router_rule_set_param1 : procedure(rule : PFluidMidiRouterRule; min, max : longint; mul : single; add : longint);
	fluid_midi_router_rule_set_param2 : procedure(rule : PFluidMidiRouterRule; min, max : longint; mul : single; add : longint);
	fluid_midi_router_set_default_rules : function(router : PFluidMidiRouter) : longint;
	//fluid_mod_clone
	//fluid_mod_get_amount
	//fluid_mod_get_dest
	//fluid_mod_get_flags1
	//fluid_mod_get_flags2
	//fluid_mod_get_source1
	//fluid_mod_get_source2
	//fluid_mod_has_dest
	//fluid_mod_has_source
	//fluid_mod_set_amount
	//fluid_mod_set_dest
	//fluid_mod_set_source1
	//fluid_mod_set_source2
	//fluid_mod_sizeof
	//fluid_mod_test_identity
	//fluid_note_compute_id
	//fluid_note_container_clear
	//fluid_note_container_insert
	//fluid_note_container_remove
	fluid_player_add : function(player : PFluidPlayer; filename : pchar) : longint;
	fluid_player_add_mem : function(player : PFluidPlayer; buffer : pointer; len : qword) : longint;
	fluid_player_get_bpm : function(player : PFluidPlayer) : longint;
	fluid_player_get_current_tick : function(player : PFluidPlayer) : longint;
	fluid_player_get_midi_tempo : function(player : PFluidPlayer) : longint;
	fluid_player_get_status : function(player : PFluidPlayer) : longint;
	fluid_player_get_total_ticks : function(player : PFluidPlayer) : longint;
	fluid_player_join : function(player : PFluidPlayer) : longint;
	fluid_player_play : function(player : PFluidPlayer) : longint;
	fluid_player_seek : function(player : PFluidPlayer; ticks : longint) : longint;
	fluid_player_set_bpm : function(player : PFluidPlayer; bpm : longint) : longint;
	fluid_player_set_loop : function(player : PFluidPlayer; loop : longint) : longint;
	fluid_player_set_midi_tempo : function(player : PFluidPlayer; tempo : longint) : longint;
	fluid_player_set_playback_callback : function(player : PFluidPlayer; handler : handle_midi_event_func_t; handler_data : pointer) : longint;
	fluid_player_set_tempo : function(player : PFluidPlayer; tempo_type : longint; tempo : double) : longint;
	fluid_player_set_tick_callback : function(player : PFluidPlayer; handler : handle_midi_tick_func_t; handler_data : pointer) : longint;
	fluid_player_stop : function(player : PFluidPlayer) : longint;
	//fluid_preset_get_banknum
	//fluid_preset_get_data
	fluid_preset_get_name : function(preset : PFluidPreset) : pchar;
	//fluid_preset_get_num
	//fluid_preset_get_sfont
	//fluid_preset_set_data
	//fluid_sample_set_loop
	//fluid_sample_set_name
	//fluid_sample_set_pitch
	//fluid_sample_set_sound_data
	//fluid_sample_sizeof
	//fluid_seq_queue_invalidate_note_private
	//fluid_seq_queue_process
	//fluid_seq_queue_push
	//fluid_seq_queue_remove
	fluid_sequencer_add_midi_event_to_buffer : function(data: pointer; event : PFluidMidiEvent) : longint;
	//fluid_sequencer_client_is_dest
	//fluid_sequencer_count_clients
	//fluid_sequencer_get_client_id
	//fluid_sequencer_get_client_name
	fluid_sequencer_get_tick : function(seq : PFluidSequencer) : dword;
	fluid_sequencer_get_time_scale : function(seq : PFluidSequencer) : double;
	//fluid_sequencer_get_use_system_timer
	fluid_sequencer_process : procedure(seq : PFluidSequencer; msec : dword);
	fluid_sequencer_register_client : function(seq : PFluidSequencer; name : pchar; callback : fluid_event_callback_t; data : pointer) : fluid_seq_id_t;
	fluid_sequencer_register_fluidsynth : function(seq : PFluidSequencer; synth : PFluidSynth) : fluid_seq_id_t;
	fluid_sequencer_remove_events : procedure(seq : PFluidSequencer; source, dest : fluid_seq_id_t; type_ : longint);
	fluid_sequencer_send_at : function(seq : PFluidSequencer; evt : PFluidEvent; time : dword; absolute_ : longint) : longint;
	fluid_sequencer_send_now : procedure(seq : PFluidSequencer; evt : PFluidEvent);
	fluid_sequencer_set_time_scale : procedure(seq : PFluidSequencer; scale : double);
	fluid_sequencer_unregister_client : procedure(seq : PFluidSequencer; id : fluid_seq_id_t);
	//fluid_server_join
	fluid_set_log_function : function(level : longint; fun : fluid_log_function_t; data : pointer) : fluid_log_function_t;
	fluid_settings_copystr : function(settings : PFluidSettings; name : pchar; str : pchar; len : longint) : longint;
	fluid_settings_dupstr : function(settings : PFluidSettings; name : pchar; str : ppchar) : longint;
	fluid_settings_foreach : function(settings : PFluidSettings; data : pointer; func : fluid_settings_foreach_t) : longint;
	fluid_settings_foreach_option : function(settings : PFluidSettings; name : pchar; data : pointer; func : fluid_settings_foreach_option_t) : longint;
	//fluid_settings_get_hints
	fluid_settings_getint : function(settings : PFluidSettings; name : pchar; out val : longint) : longint;
	fluid_settings_getint_default : function(settings : PFluidSettings; name : pchar; out val : longint) : longint;
	//fluid_settings_getint_range
	fluid_settings_getnum : function(settings : PFluidSettings; name : pchar; out val : double) : longint;
	fluid_settings_getnum_default : function(settings : PFluidSettings; name : pchar; out val : double) : longint;
	//fluid_settings_getnum_range
	fluid_settings_getstr_default : function(settings : PFluidSettings; name : pchar; def : ppchar) : longint;
	fluid_settings_get_type : function(settings : PFluidSettings; name : pchar) : longint;
	//fluid_settings_is_realtime
	//fluid_settings_option_concat
	//fluid_settings_option_count
	fluid_settings_setint : function(settings : PFluidSettings; name : pchar; val : longint) : longint;
	fluid_settings_setnum : function(settings : PFluidSettings; name : pchar; val : double) : longint;
	fluid_settings_setstr : function(settings : PFluidSettings; name : pchar; str : pchar) : longint;
	fluid_settings_str_equal : function(settings : PFluidSettings; name, s : pchar) : longint;
	//fluid_sfloader_get_data
	//fluid_sfloader_set_callbacks
	//fluid_sfloader_set_data
	fluid_sfont_get_data : function(sfont : PFluidSoundFont) : pointer;
	fluid_sfont_get_id : function(sfont : PFluidSoundFont) : longint;
	fluid_sfont_get_name : function(sfont : PFluidSoundFont) : pchar;
	fluid_sfont_get_preset : function(sfont : PFluidSoundFont; bank, prenum : longint) : PFluidPreset;
	fluid_sfont_iteration_next : function(sfont : PFluidSoundFont) : PFluidPreset;
	fluid_sfont_iteration_start : procedure(sfont : PFluidSoundFont);
	fluid_sfont_set_data : function(sfont : PFluidSoundFont; data : pointer) : longint;
	fluid_source : function(handler : PFluidCmdHandler; filename : pchar) : longint;
	//fluid_synth_activate_key_tunings
        fluid_synth_activate_octave_tuning: function(synth : PFluidSynth; bank, prog: longint;
                                   name: pchar; pitch: pdouble; apply:longint): longint;
        fluid_synth_activate_tuning: function(synth : PFluidSynth; chan, bank, prog,apply: longint): longint;

        //fluid_synth_activate_tuning
	//fluid_synth_add_default_mod
	fluid_synth_add_sfloader : procedure(synth : PFluidSynth; loader : PFluidSoundFontLoader);
	fluid_synth_add_sfont : function(synth : PFluidSynth; sfont : PFluidSoundFont) : longint;
	//fluid_synth_alloc_voice
	fluid_synth_all_notes_off : function(synth : PFluidSynth; chan : longint) : longint;
	fluid_synth_all_sounds_off : function(synth : PFluidSynth; chan : longint) : longint;
	fluid_synth_bank_select : function(synth : PFluidSynth; chan, bank : longint) : longint;
	fluid_synth_cc : function(synth : PFluidSynth; chan, num, val : longint) : longint;
	fluid_synth_channel_pressure : function(synth : PFluidSynth; chan, val : longint) : longint;
	fluid_synth_chorus_on : function(synth : PFluidSynth; fx_group, on_ : longint) : longint;
	//fluid_synth_count_audio_channels
	//fluid_synth_count_audio_groups
	//fluid_synth_count_effects_channels
	//fluid_synth_count_effects_groups
	//fluid_synth_count_midi_channels
	//fluid_synth_deactivate_tuning
	fluid_synth_error : function(synth : PFluidSynth) : pchar;
	//fluid_synth_get_active_voice_count
	//fluid_synth_get_bank_offset
	//fluid_synth_get_basic_channel
	//fluid_synth_get_breath_mode
	fluid_synth_get_cc : function(synth : PFluidSynth; chan, num : longint; out pval : longint) : longint;
	//fluid_synth_get_channel_info : function(synth : PFluidSynth; chan : longint; info : Pfluid_synth_channel_info_t) : longint;
	//fluid_synth_get_channel_preset
	fluid_synth_get_chorus_depth : function(synth : PFluidSynth) : double;
	//fluid_synth_get_chorus_group_depth
	//fluid_synth_get_chorus_group_level
	//fluid_synth_get_chorus_group_nr
	//fluid_synth_get_chorus_group_speed
	//fluid_synth_get_chorus_group_type
	fluid_synth_get_chorus_level : function(synth : PFluidSynth) : double;
	fluid_synth_get_chorus_nr : function(synth : PFluidSynth) : longint;
	fluid_synth_get_chorus_speed : function(synth : PFluidSynth) : double;
	fluid_synth_get_chorus_type : function(synth : PFluidSynth) : longint;
	fluid_synth_get_cpu_load : function(synth : PFluidSynth) : double;
	fluid_synth_get_gain : function(synth : PFluidSynth) : single;
	//fluid_synth_get_gen
	//fluid_synth_get_internal_bufsize
	//fluid_synth_get_ladspa_fx
	//fluid_synth_get_legato_mode
	fluid_synth_get_pitch_bend : function(synth : PFluidSynth; chan : longint; out ppitch_bend : longint) : longint;
	fluid_synth_get_pitch_wheel_sens : function(synth : PFluidSynth; chan : longint; out pval : longint) : longint;
	//fluid_synth_get_polyphony
	//fluid_synth_get_portamento_mode
	fluid_synth_get_program : function(synth : PFluidSynth; chan : longint; out sfont_id : longint; out bank_num : longint; out preset_num : longint) : longint;
	fluid_synth_get_reverb_damp : function(synth : PFluidSynth) : double;
	//fluid_synth_get_reverb_group_damp
	//fluid_synth_get_reverb_group_level
	//fluid_synth_get_reverb_group_roomsize
	//fluid_synth_get_reverb_group_width
	fluid_synth_get_reverb_level : function(synth : PFluidSynth) : double;
	fluid_synth_get_reverb_roomsize : function(synth : PFluidSynth) : double;
	fluid_synth_get_reverb_width : function(synth : PFluidSynth) : double;
	//fluid_synth_get_settings
	fluid_synth_get_sfont : function(synth : PFluidSynth; num : dword) : PFluidSoundFont;
	fluid_synth_get_sfont_by_id : function(synth : PFluidSynth; id : longint) : PFluidSoundFont;
	fluid_synth_get_sfont_by_name : function(synth : PFluidSynth; name : pchar) : PFluidSoundFont;
	//fluid_synth_get_voicelist
	fluid_synth_handle_midi_event : function(data : pointer; event : PFluidMidiEvent) : longint;
	fluid_synth_key_pressure : function(synth : PFluidSynth; chan, key, val : longint) : longint;
	fluid_synth_noteoff : function(synth : PFluidSynth; chan, key : longint) : longint;
	fluid_synth_noteon : function(synth : PFluidSynth; chan, key, vel : longint) : longint;
	//fluid_synth_nwrite_float
	//fluid_synth_pin_preset
	fluid_synth_pitch_bend : function(synth : PFluidSynth; chan, val : longint) : longint;
	fluid_synth_pitch_wheel_sens : function(synth : PFluidSynth; chan, val : longint) : longint;
	//fluid_synth_process
	fluid_synth_program_change : function(synth : PFluidSynth; chan, prognum : longint) : longint;
	fluid_synth_program_reset : function(synth : PFluidSynth) : longint;
	fluid_synth_program_select : function(synth : PFluidSynth; chan, sfont_id, bank_num, preset_num : longint) : longint;
	fluid_synth_program_select_by_sfont_name : function(synth : PFluidSynth; chan : longint; sfont_name : pchar; bank_num, preset_num : longint) : longint;
	//fluid_synth_remove_default_mod
	fluid_synth_remove_sfont : function(synth : PFluidSynth; sfont : PFluidSoundFont) : longint;
	//fluid_synth_reset_basic_channel
	//fluid_synth_reverb_on
	//fluid_synth_set_bank_offset
	//fluid_synth_set_basic_channel
	//fluid_synth_set_breath_mode
	//fluid_synth_set_channel_type
	fluid_synth_set_chorus : function(synth : PFluidSynth; nr : longint; level, speed, depth_ms : double; type_ : longint) : longint;
	//fluid_synth_set_chorus_depth
	//fluid_synth_set_chorus_full : function(synth : PFluidSynth; set_ : longint; nr : longint; level, speed, depth_ms : double; type_ : longint) : longint;
	//fluid_synth_set_chorus_group_depth
	//fluid_synth_set_chorus_group_level
	//fluid_synth_set_chorus_group_nr
	//fluid_synth_set_chorus_group_speed
	//fluid_synth_set_chorus_group_type
	fluid_synth_set_chorus_level : function(synth : PFluidSynth; level : double) : longint;
	fluid_synth_set_chorus_nr : function(synth : PFluidSynth; nr : longint) : longint;
	//fluid_synth_set_chorus_on // don't use, deprecated! Use fluid_synth_chorus_on instead
	//fluid_synth_set_chorus_speed
	fluid_synth_set_chorus_type : function(synth : PFluidSynth; type_ : longint) : longint;
	//fluid_synth_set_custom_filter
	fluid_synth_set_gain : procedure(synth : PFluidSynth; gain : single);
	//fluid_synth_set_gen
	fluid_synth_set_interp_method : function(synth : PFluidSynth; chan, interp_method : longint) : longint;
	//fluid_synth_set_legato_mode
	//fluid_synth_set_midi_router : procedure(synth : PFluidSynth; router : PFluidMidiRouter);
	fluid_synth_set_polyphony : function(synth : PFluidSynth; polyphony : longint) : longint;
	//fluid_synth_set_portamento_mode
	fluid_synth_set_reverb : function(synth : PFluidSynth; roomsize, damping, width, level : double) : longint;
	fluid_synth_set_reverb_damp : function(synth : PFluidSynth; damping : double) : longint;
	//fluid_synth_set_reverb_full : function(synth : PFluidSynth; set_ : longint; roomsize, damping, width, level : double) : longint;
	//fluid_synth_set_reverb_group_damp
	//fluid_synth_set_reverb_group_level
	//fluid_synth_set_reverb_group_roomsize
	//fluid_synth_set_reverb_group_width
	fluid_synth_set_reverb_level : function(synth : PFluidSynth; level : double) : longint;
	//fluid_synth_set_reverb_on // don't use, deprecated! Use fluid_synth_reverb_on instead
	fluid_synth_set_reverb_roomsize : function(synth : PFluidSynth; roomsize : double) : longint;
	fluid_synth_set_reverb_width : function(synth : PFluidSynth; width : double) : longint;
	//fluid_synth_set_sample_rate : procedure(synth : PFluidSynth; sample_rate : single); // don't use! deprecated
	fluid_synth_sfcount : function(synth : PFluidSynth) : longint;
	fluid_synth_sfload : function(synth : PFluidSynth; filename : pchar; reset_presets : longint) : longint;
	fluid_synth_sfont_select : function(synth : PFluidSynth; chan, sfont_id : longint) : longint;
	fluid_synth_sfreload : function(synth : PFluidSynth; id : longint) : longint;
	fluid_synth_sfunload : function(synth : PFluidSynth; id, reset_presets : longint) : longint;
	fluid_synth_start : function(synth : PFluidSynth; id : dword; preset : PFluidPreset; audio_chan, chan, key, vel : longint) : longint;
	fluid_synth_start_voice : procedure(synth : PFluidSynth; voice : PFluidVoice);
	fluid_synth_stop : function(synth : PFluidSynth; id : dword) : longint;
	fluid_synth_sysex : function(synth : PFluidSynth; data: pointer; len : longint; response : pchar; out response_len : longint; out handled : longint; dryrun : longint) : longint;
	fluid_synth_system_reset : function(synth : PFluidSynth) : longint;
	//fluid_synth_tune_notes
	//fluid_synth_tuning_dump
	//fluid_synth_tuning_iteration_next
	//fluid_synth_tuning_iteration_start
	//fluid_synth_unpin_preset
	fluid_synth_unset_program : function(synth : PFluidSynth; chan : longint) : longint;
	fluid_synth_write_float : function(synth : PFluidSynth; len : longint; lout : pointer; loff, lincr : longint; rout : pointer; roff, rincr : longint) : pointer;
	fluid_synth_write_s16 : function(synth : PFluidSynth; len : longint; lout : pointer; loff, lincr : longint; rout : pointer; roff, rincr : longint) : pointer;
	//fluid_usershell
	fluid_version : procedure(out major : longint; out minor : longint; out micro : longint);
	fluid_version_str : function() : pchar;
	//fluid_voice_add_mod
	//fluid_voice_gen_get
	//fluid_voice_gen_incr
	//fluid_voice_gen_set
	//fluid_voice_get_actual_key
	//fluid_voice_get_actual_velocity
	//fluid_voice_get_channel
	//fluid_voice_get_id
	//fluid_voice_get_key
	//fluid_voice_get_velocity
	//fluid_voice_is_on
	//fluid_voice_is_playing
	//fluid_voice_is_sostenuto
	//fluid_voice_is_sustained
	//fluid_voice_optimize_sample
	//fluid_voice_update_param
	new_fluid_audio_driver : function(settings : PFluidSettings; synth : PFluidSynth) : PFluidAudioDriver;
	new_fluid_audio_driver2 : function(settings : PFluidSettings; func : fluid_audio_func_t; data : pointer) : PFluidAudioDriver;
	new_fluid_cmd_handler : function(synth : PFluidSynth; router : PFluidMidiRouter) : PFluidCmdHandler;
	new_fluid_cmd_handler2 : function(settings : PFluidSettings; synth : PFluidSynth; router : PFluidMidiRouter; player : PFluidPlayer) : PFluidCmdHandler;
	new_fluid_defsfloader : function(settings : PFluidSettings) : PFluidSoundFontLoader;
	new_fluid_event : function() : PFluidEvent;
	new_fluid_file_renderer : function(synth : PFluidSynth) : PFluidFileRenderer;
	new_fluid_midi_driver : function(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiDriver;
	new_fluid_midi_event : function() : PFluidMidiEvent;
	new_fluid_midi_router : function(settings : PFluidSettings; handler : handle_midi_event_func_t; event_handler_data : pointer) : PFluidMidiRouter;
	new_fluid_midi_router_rule : function() : PFluidMidiRouterRule;
	new_fluid_mod : function() : PFluidMod;
	//new_fluid_note_container
	new_fluid_player : function(synth : PFluidSynth) : PFluidPlayer;
	//new_fluid_preset : function(parent_sfont : PFluidSoundFont; get_name : fluid_preset_get_name_t; get_bank : fluid_preset_get_banknum_t; get_num : fluid_preset_get_num_t; noteon : fluid_preset_noteon_t; free : fluid_preset_free_t) : PFluidPreset;
	new_fluid_sample : function() : PFluidSample;
	//new_fluid_seq_queue
	new_fluid_sequencer : function() : PFluidSequencer;
	new_fluid_sequencer2 : function(use_system_timer : longint) : PFluidSequencer;
	new_fluid_server : function(settings : PFluidSettings; synth : PFluidSynth; router : PFluidMidiRouter) : PFluidServer;
	new_fluid_server2 : function(settings : PFluidSettings; synth : PFluidSynth; router : PFluidMidiRouter; player : PFluidPlayer) : PFluidServer;
	new_fluid_settings : function() : PFluidSettings;
	//new_fluid_sfloader : function(load : fluid_sfloader_load_t; free : fluid_sfloader_free_t) : PFluidSoundFontLoader;
	//new_fluid_sfont : function(get_name : fluid_sfont_get_name_t; get_preset : fluid_sfont_get_preset_t; iter_start : fluid_sfont_iteration_start_t; iter_next : fluid_sfont_iteration_next_t; free : fluid_sfont_free_t) : PFluidSoundFont;
	new_fluid_shell : function(settings : PFluidSettings; handler : PFluidCmdHandler; in_ : fluid_istream_t; out_ : fluid_ostream_t; thread : longint) : PFluidShell;
	new_fluid_synth : function(settings : PFluidSettings) : PFluidSynth;

	private
	lib : PtrInt;
	function _IsLoaded : boolean;

	public
	settings : PFluidSettings;
	synth : PFluidSynth;
	sequencer : PFluidSequencer;
	player : PFluidPlayer;
	audioDriver : PFluidAudioDriver;
	status : UTF8string;
	property isLoaded : boolean read _IsLoaded;
	constructor Create;
	destructor Destroy; override;

        public
        fluid_synth_handle_midi_event_pointer:handle_midi_event_func_t;
        fluid_midi_router_handle_midi_event_pointer:handle_midi_event_func_t;
end;



// ------------------------------------------------------------------

implementation

uses dynlibs;




function TFluidSynth._IsLoaded : boolean;
begin
	result := lib <> 0;
end;

procedure TFluidSynth._GetFunc(dest : pointer; const funcname : ansistring); inline;
begin
		pointer(dest^) := GetProcAddress(lib, funcname);
		{$ifdef DEBUG}
		if pointer(dest^) = NIL then writeln('GET FAIL: ',funcname);
		{$endif}
                if pointer(dest^) = NIL then Log.LogStatus('pasfluidsynth: GET FAIL: ',funcname);
	end;



constructor TFluidSynth.Create;

var libname : ansistring;
begin
	settings := NIL;
	synth := NIL;
	libname := 'libfluidsynth.' + SharedSuffix;
        Log.LogStatus('pasfluidsynth', 'Loading '+libname);
	lib := SafeLoadLibrary(libname);
        Log.LogStatus('pasfluidsynth', 'Loading '+libname+' 1 attempt');
	if lib = 0 then begin
		libname := 'libfluidsynth-3.' + SharedSuffix;
		lib := SafeLoadLibrary(libname);
                Log.LogStatus('pasfluidsynth', 'Loading '+libname+' 2 attempts');
                if lib = 0 then begin
                    libname := 'libfluidsynth.3.'+SharedSuffix;
			lib := SafeLoadLibrary(libname);
                        Log.LogStatus('pasfluidsynth', 'Loading '+libname+' 3.5 attempts');


    	if lib = 0 then begin
			libname := 'libfluidsynth.' + SharedSuffix + '.3';
			lib := SafeLoadLibrary(libname);
                        Log.LogStatus('pasfluidsynth', 'Loading '+libname+' 3 attempts');
	    	if lib = 0 then begin
				libname := 'libfluidsynth-2.' + SharedSuffix;
				lib := SafeLoadLibrary(libname);
                                Log.LogStatus('pasfluidsynth', 'Loading '+libname+' 4 attempts');
				if lib = 0 then begin
					libname := 'libfluidsynth.' + SharedSuffix + '.2';
					lib := SafeLoadLibrary(libname);
                                        Log.LogStatus('pasfluidsynth', 'Loading '+libname+' 5 attempts');
					if lib = 0 then begin
						libname := 'fluidsynth.' + SharedSuffix;
						lib := SafeLoadLibrary(libname);
						if lib = 0 then begin
							status := 'Failed to load fluidsynth.' + SharedSuffix;
							exit;
						end;
					end;
				end;
			end;
		end;
	end;

        end;
        status := 'Loaded ' + libname;
        Log.LogStatus('pasfluidsynth', status);

        _GetFuncs();

end;




destructor TFluidSynth.Destroy;
begin
	if lib <> 0 then FreeLibrary(lib);
	inherited;
end;



procedure TFluidSynth._GetFuncs();
begin
        _GetFunc(@delete_fluid_audio_driver, 'delete_fluid_audio_driver');
	_GetFunc(@delete_fluid_cmd_handler, 'delete_fluid_cmd_handler');
	_GetFunc(@delete_fluid_event, 'delete_fluid_event');
	_GetFunc(@delete_fluid_file_renderer, 'delete_fluid_file_renderer');
	_GetFunc(@delete_fluid_midi_driver, 'delete_fluid_midi_driver');
	_GetFunc(@delete_fluid_midi_event, 'delete_fluid_midi_event');
	_GetFunc(@delete_fluid_midi_router, 'delete_fluid_midi_router');
	_GetFunc(@delete_fluid_midi_router_rule, 'delete_fluid_midi_router_rule');
	_GetFunc(@delete_fluid_mod, 'delete_fluid_mod');
	_GetFunc(@delete_fluid_player, 'delete_fluid_player');
	_GetFunc(@delete_fluid_preset, 'delete_fluid_preset');
	_GetFunc(@delete_fluid_sample, 'delete_fluid_sample');
	_GetFunc(@delete_fluid_sequencer, 'delete_fluid_sequencer');
	_GetFunc(@delete_fluid_server, 'delete_fluid_server');
	_GetFunc(@delete_fluid_settings, 'delete_fluid_settings');
	_GetFunc(@delete_fluid_sfloader, 'delete_fluid_sfloader');
	_GetFunc(@delete_fluid_sfont, 'delete_fluid_sfont');
	_GetFunc(@delete_fluid_shell, 'delete_fluid_shell');
	_GetFunc(@delete_fluid_synth, 'delete_fluid_synth');
	_GetFunc(@fluid_audio_driver_register, 'fluid_audio_driver_register');
	_GetFunc(@fluid_command, 'fluid_command');
	_GetFunc(@fluid_default_log_function, 'fluid_default_log_function');
	_GetFunc(@fluid_event_all_notes_off, 'fluid_event_all_notes_off');
	_GetFunc(@fluid_event_all_sounds_off, 'fluid_event_all_sounds_off');
	_GetFunc(@fluid_event_bank_select, 'fluid_event_bank_select');
	_GetFunc(@fluid_event_channel_pressure, 'fluid_event_channel_pressure');
	_GetFunc(@fluid_event_chorus_send, 'fluid_event_chorus_send');
	_GetFunc(@fluid_event_control_change, 'fluid_event_control_change');
	_GetFunc(@fluid_event_from_midi_event, 'fluid_event_from_midi_event');
	_GetFunc(@fluid_event_key_pressure, 'fluid_event_key_pressure');
	_GetFunc(@fluid_event_modulation, 'fluid_event_modulation');
	_GetFunc(@fluid_event_note, 'fluid_event_note');
	_GetFunc(@fluid_event_noteoff, 'fluid_event_noteoff');
	_GetFunc(@fluid_event_noteon, 'fluid_event_noteon');
	_GetFunc(@fluid_event_pan, 'fluid_event_pan');
	_GetFunc(@fluid_event_pitch_bend, 'fluid_event_pitch_bend');
	_GetFunc(@fluid_event_pitch_wheelsens, 'fluid_event_pitch_wheelsens');
	_GetFunc(@fluid_event_program_change, 'fluid_event_program_change');
	_GetFunc(@fluid_event_program_select, 'fluid_event_program_select');
	_GetFunc(@fluid_event_reverb_send, 'fluid_event_reverb_send');
	_GetFunc(@fluid_event_scale, 'fluid_event_scale');
	_GetFunc(@fluid_event_set_dest, 'fluid_event_set_dest');
	_GetFunc(@fluid_event_set_source, 'fluid_event_set_source');
	_GetFunc(@fluid_event_sustain, 'fluid_event_sustain');
	_GetFunc(@fluid_event_system_reset, 'fluid_event_system_reset');
	_GetFunc(@fluid_event_timer, 'fluid_event_timer');
	_GetFunc(@fluid_event_unregistering, 'fluid_event_unregistering');
	_GetFunc(@fluid_event_volume, 'fluid_event_volume');
	_GetFunc(@fluid_file_renderer_process_block, 'fluid_file_renderer_process_block');
	_GetFunc(@fluid_file_set_encoding_quality, 'fluid_file_set_encoding_quality');
	_GetFunc(@fluid_free, 'fluid_free');
	_GetFunc(@fluid_is_midifile, 'fluid_is_midifile');
	_GetFunc(@fluid_is_soundfont, 'fluid_is_soundfont');
	_GetFunc(@fluid_midi_event_get_channel, 'fluid_midi_event_get_channel');
	_GetFunc(@fluid_midi_event_get_control, 'fluid_midi_event_get_control');
	_GetFunc(@fluid_midi_event_get_key, 'fluid_midi_event_get_key');
	_GetFunc(@fluid_midi_event_get_lyrics, 'fluid_midi_event_get_lyrics');
	_GetFunc(@fluid_midi_event_get_pitch, 'fluid_midi_event_get_pitch');
	_GetFunc(@fluid_midi_event_get_program, 'fluid_midi_event_get_program');
	_GetFunc(@fluid_midi_event_get_text, 'fluid_midi_event_get_text');
	_GetFunc(@fluid_midi_event_get_type, 'fluid_midi_event_get_type');
	_GetFunc(@fluid_midi_event_get_value, 'fluid_midi_event_get_value');
	_GetFunc(@fluid_midi_event_get_velocity, 'fluid_midi_event_get_velocity');
	_GetFunc(@fluid_midi_router_add_rule, 'fluid_midi_router_add_rule');
	_GetFunc(@fluid_midi_router_clear_rules, 'fluid_midi_router_clear_rules');
	_GetFunc(@fluid_midi_router_handle_midi_event, 'fluid_midi_router_handle_midi_event');
	_GetFunc(@fluid_midi_router_rule_set_chan, 'fluid_midi_router_rule_set_chan');
	_GetFunc(@fluid_midi_router_rule_set_param1, 'fluid_midi_router_rule_set_param1');
	_GetFunc(@fluid_midi_router_rule_set_param2, 'fluid_midi_router_rule_set_param2');
	_GetFunc(@fluid_midi_router_set_default_rules, 'fluid_midi_router_set_default_rules');
	_GetFunc(@fluid_player_add, 'fluid_player_add');
	_GetFunc(@fluid_player_add_mem, 'fluid_player_add_mem');
	_GetFunc(@fluid_player_get_bpm, 'fluid_player_get_bpm');
	_GetFunc(@fluid_player_get_current_tick, 'fluid_player_get_current_tick');
	_GetFunc(@fluid_player_get_midi_tempo, 'fluid_player_get_midi_tempo');
	_GetFunc(@fluid_player_get_status, 'fluid_player_get_status');
	_GetFunc(@fluid_player_get_total_ticks, 'fluid_player_get_total_ticks');
	_GetFunc(@fluid_player_join, 'fluid_player_join');
	_GetFunc(@fluid_player_play, 'fluid_player_play');
	_GetFunc(@fluid_player_seek, 'fluid_player_seek');
	_GetFunc(@fluid_player_set_bpm, 'fluid_player_set_bpm');
	_GetFunc(@fluid_player_set_loop, 'fluid_player_set_loop');
	_GetFunc(@fluid_player_set_midi_tempo, 'fluid_player_set_midi_tempo');
	_GetFunc(@fluid_player_set_playback_callback, 'fluid_player_set_playback_callback');
	_GetFunc(@fluid_player_set_tempo, 'fluid_player_set_tempo');
	_GetFunc(@fluid_player_set_tick_callback, 'fluid_player_set_tick_callback');
	_GetFunc(@fluid_player_stop, 'fluid_player_stop');
	_GetFunc(@fluid_preset_get_name, 'fluid_preset_get_name');
	_GetFunc(@fluid_sequencer_add_midi_event_to_buffer, 'fluid_sequencer_add_midi_event_to_buffer');
	_GetFunc(@fluid_sequencer_get_tick, 'fluid_sequencer_get_tick');
	_GetFunc(@fluid_sequencer_get_time_scale, 'fluid_sequencer_get_time_scale');
	_GetFunc(@fluid_sequencer_process, 'fluid_sequencer_process');
	_GetFunc(@fluid_sequencer_register_client, 'fluid_sequencer_register_client');
	_GetFunc(@fluid_sequencer_register_fluidsynth, 'fluid_sequencer_register_fluidsynth');
	_GetFunc(@fluid_sequencer_remove_events, 'fluid_sequencer_remove_events');
	_GetFunc(@fluid_sequencer_send_at, 'fluid_sequencer_send_at');
	_GetFunc(@fluid_sequencer_send_now, 'fluid_sequencer_send_now');
	_GetFunc(@fluid_sequencer_set_time_scale, 'fluid_sequencer_set_time_scale');
	_GetFunc(@fluid_sequencer_unregister_client, 'fluid_sequencer_unregister_client');
	_GetFunc(@fluid_set_log_function, 'fluid_set_log_function');
	_GetFunc(@fluid_settings_copystr, 'fluid_settings_copystr');
	_GetFunc(@fluid_settings_dupstr, 'fluid_settings_dupstr');
	_GetFunc(@fluid_settings_foreach, 'fluid_settings_foreach');
	_GetFunc(@fluid_settings_foreach_option, 'fluid_settings_foreach_option');
	_GetFunc(@fluid_settings_getint, 'fluid_settings_getint');
	_GetFunc(@fluid_settings_getint_default, 'fluid_settings_getint_default');
	_GetFunc(@fluid_settings_getnum, 'fluid_settings_getnum');
	_GetFunc(@fluid_settings_getnum_default, 'fluid_settings_getnum_default');
	_GetFunc(@fluid_settings_getstr_default, 'fluid_settings_getstr_default');
	_GetFunc(@fluid_settings_get_type, 'fluid_settings_get_type');
	_GetFunc(@fluid_settings_setint, 'fluid_settings_setint');
	_GetFunc(@fluid_settings_setnum, 'fluid_settings_setnum');
	_GetFunc(@fluid_settings_setstr, 'fluid_settings_setstr');
	_GetFunc(@fluid_settings_str_equal, 'fluid_settings_str_equal');
	_GetFunc(@fluid_sfont_get_data, 'fluid_sfont_get_data');
	_GetFunc(@fluid_sfont_get_id, 'fluid_sfont_get_id');
	_GetFunc(@fluid_sfont_get_name, 'fluid_sfont_get_name');
	_GetFunc(@fluid_sfont_get_preset, 'fluid_sfont_get_preset');
	_GetFunc(@fluid_sfont_iteration_next, 'fluid_sfont_iteration_next');
	_GetFunc(@fluid_sfont_iteration_start, 'fluid_sfont_iteration_start');
	_GetFunc(@fluid_sfont_set_data, 'fluid_sfont_set_data');
	_GetFunc(@fluid_source, 'fluid_source');
        _GetFunc(@fluid_synth_activate_octave_tuning, 'fluid_synth_activate_octave_tuning');
        _GetFunc(@fluid_synth_activate_tuning, 'fluid_synth_activate_tuning');
	_GetFunc(@fluid_synth_add_sfloader, 'fluid_synth_add_sfloader');
	_GetFunc(@fluid_synth_add_sfont, 'fluid_synth_add_sfont');
	_GetFunc(@fluid_synth_all_notes_off, 'fluid_synth_all_notes_off');
	_GetFunc(@fluid_synth_all_sounds_off, 'fluid_synth_all_sounds_off');
	_GetFunc(@fluid_synth_bank_select, 'fluid_synth_bank_select');
	_GetFunc(@fluid_synth_cc, 'fluid_synth_cc');
	_GetFunc(@fluid_synth_channel_pressure, 'fluid_synth_channel_pressure');
	_GetFunc(@fluid_synth_chorus_on, 'fluid_synth_chorus_on');
	_GetFunc(@fluid_synth_error, 'fluid_synth_error');
	_GetFunc(@fluid_synth_get_cc, 'fluid_synth_get_cc');
	_GetFunc(@fluid_synth_get_chorus_depth, 'fluid_synth_get_chorus_depth');
	_GetFunc(@fluid_synth_get_chorus_level, 'fluid_synth_get_chorus_level');
	_GetFunc(@fluid_synth_get_chorus_nr, 'fluid_synth_get_chorus_nr');
	_GetFunc(@fluid_synth_get_chorus_speed, 'fluid_synth_get_chorus_speed');
	_GetFunc(@fluid_synth_get_chorus_type, 'fluid_synth_get_chorus_type');
	_GetFunc(@fluid_synth_get_cpu_load, 'fluid_synth_get_cpu_load');
	_GetFunc(@fluid_synth_get_gain, 'fluid_synth_get_gain');
	_GetFunc(@fluid_synth_get_pitch_bend, 'fluid_synth_get_pitch_bend');
	_GetFunc(@fluid_synth_get_pitch_wheel_sens, 'fluid_synth_get_pitch_wheel_sens');
	_GetFunc(@fluid_synth_get_program, 'fluid_synth_get_program');
	_GetFunc(@fluid_synth_get_reverb_damp, 'fluid_synth_get_reverb_damp');
	_GetFunc(@fluid_synth_get_reverb_level, 'fluid_synth_get_reverb_level');
	_GetFunc(@fluid_synth_get_reverb_roomsize, 'fluid_synth_get_reverb_roomsize');
	_GetFunc(@fluid_synth_get_reverb_width, 'fluid_synth_get_reverb_width');
	_GetFunc(@fluid_synth_get_sfont, 'fluid_synth_get_sfont');
	_GetFunc(@fluid_synth_get_sfont_by_id, 'fluid_synth_get_sfont_by_id');
	_GetFunc(@fluid_synth_get_sfont_by_name, 'fluid_synth_get_sfont_by_name');
	_GetFunc(@fluid_synth_handle_midi_event, 'fluid_synth_handle_midi_event');
	_GetFunc(@fluid_synth_key_pressure, 'fluid_synth_key_pressure');
	_GetFunc(@fluid_synth_noteoff, 'fluid_synth_noteoff');
	_GetFunc(@fluid_synth_noteon, 'fluid_synth_noteon');
	_GetFunc(@fluid_synth_pitch_bend, 'fluid_synth_pitch_bend');
	_GetFunc(@fluid_synth_pitch_wheel_sens, 'fluid_synth_pitch_wheel_sens');
	_GetFunc(@fluid_synth_program_change, 'fluid_synth_program_change');
	_GetFunc(@fluid_synth_program_reset, 'fluid_synth_program_reset');
	_GetFunc(@fluid_synth_program_select, 'fluid_synth_program_select');
	_GetFunc(@fluid_synth_program_select_by_sfont_name, 'fluid_synth_program_select_by_sfont_name');
	_GetFunc(@fluid_synth_remove_sfont, 'fluid_synth_remove_sfont');
	_GetFunc(@fluid_synth_set_chorus, 'fluid_synth_set_chorus');
	_GetFunc(@fluid_synth_set_chorus_level, 'fluid_synth_set_chorus_level');
	_GetFunc(@fluid_synth_set_chorus_nr, 'fluid_synth_set_chorus_nr');
	_GetFunc(@fluid_synth_set_chorus_type, 'fluid_synth_set_chorus_type');
	_GetFunc(@fluid_synth_set_gain, 'fluid_synth_set_gain');
	_GetFunc(@fluid_synth_set_interp_method, 'fluid_synth_set_interp_method');
	_GetFunc(@fluid_synth_set_polyphony, 'fluid_synth_set_polyphony');
	_GetFunc(@fluid_synth_set_reverb, 'fluid_synth_set_reverb');
	_GetFunc(@fluid_synth_set_reverb_damp, 'fluid_synth_set_reverb_damp');
	_GetFunc(@fluid_synth_set_reverb_level, 'fluid_synth_set_reverb_level');
	_GetFunc(@fluid_synth_set_reverb_roomsize, 'fluid_synth_set_reverb_roomsize');
	_GetFunc(@fluid_synth_set_reverb_width, 'fluid_synth_set_reverb_width');
	_GetFunc(@fluid_synth_sfcount, 'fluid_synth_sfcount');
	_GetFunc(@fluid_synth_sfload, 'fluid_synth_sfload');
	_GetFunc(@fluid_synth_sfont_select, 'fluid_synth_sfont_select');
	_GetFunc(@fluid_synth_sfreload, 'fluid_synth_sfreload');
	_GetFunc(@fluid_synth_sfunload, 'fluid_synth_sfunload');
	_GetFunc(@fluid_synth_start, 'fluid_synth_start');
	_GetFunc(@fluid_synth_start_voice, 'fluid_synth_start_voice');
	_GetFunc(@fluid_synth_stop, 'fluid_synth_stop');
	_GetFunc(@fluid_synth_sysex, 'fluid_synth_sysex');
	_GetFunc(@fluid_synth_system_reset, 'fluid_synth_system_reset');
	_GetFunc(@fluid_synth_unset_program, 'fluid_synth_unset_program');
	_GetFunc(@fluid_synth_write_float, 'fluid_synth_write_float');
	_GetFunc(@fluid_synth_write_s16, 'fluid_synth_write_s16');
        //_GetFunc(@fluid_synth_set_midi_router,'fluid_synth_set_midi_router');
	_GetFunc(@fluid_version, 'fluid_version');
	_GetFunc(@fluid_version_str, 'fluid_version_str');
	_GetFunc(@new_fluid_audio_driver, 'new_fluid_audio_driver');
	_GetFunc(@new_fluid_audio_driver2, 'new_fluid_audio_driver2');
	_GetFunc(@new_fluid_cmd_handler, 'new_fluid_cmd_handler');
	_GetFunc(@new_fluid_cmd_handler2, 'new_fluid_cmd_handler2');
	_GetFunc(@new_fluid_defsfloader, 'new_fluid_defsfloader');
	_GetFunc(@new_fluid_event, 'new_fluid_event');
	_GetFunc(@new_fluid_file_renderer, 'new_fluid_file_renderer');
	_GetFunc(@new_fluid_midi_driver, 'new_fluid_midi_driver');
	_GetFunc(@new_fluid_midi_event, 'new_fluid_midi_event');
	_GetFunc(@new_fluid_midi_router, 'new_fluid_midi_router');
	_GetFunc(@new_fluid_midi_router_rule, 'new_fluid_midi_router_rule');
	_GetFunc(@new_fluid_mod, 'new_fluid_mod');
	_GetFunc(@new_fluid_player, 'new_fluid_player');
	_GetFunc(@new_fluid_sample, 'new_fluid_sample');
	_GetFunc(@new_fluid_sequencer, 'new_fluid_sequencer');
	_GetFunc(@new_fluid_sequencer2, 'new_fluid_sequencer2');
	_GetFunc(@new_fluid_server, 'new_fluid_server');
	_GetFunc(@new_fluid_server2, 'new_fluid_server2');
	_GetFunc(@new_fluid_settings, 'new_fluid_settings');
	_GetFunc(@new_fluid_shell, 'new_fluid_shell');
	_GetFunc(@new_fluid_synth, 'new_fluid_synth');

end;

end.

