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

unit UMidiNote;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UCommon,
  UScreenSingController,
  UMusic,
  USong,
  SysUtils,
  UIni,
  UMidiInputStream,
  UMidiTransfer,
  ULyrics;



type



  TMidiNoteHandler=class
    public
    midiKeyboardStreams: array of TMidiKeyboardPressedStream; // There will be a keyboard recording stream per active player
    midiInputDeviceMessaging: array of TmidiInputDeviceMessaging; // There will be a midi message capturing instance per active player
    midiOutputDeviceMessaging: array of TmidiOutputDeviceMessaging; // There will be an midi output stream for addressin the synthesizer per player
    constructor Create;
    procedure updateForCurrentPlayers;
    procedure stopMidiHandling(stopFluidSynth: boolean);

  end;


  procedure createMidiNoteHandler();

 // global singleton for the TBeatNoteTimerState class
var midiNoteHandler : TMidiNoteHandler;



procedure handleMidiNotes(Screen: TScreenSingController; CP: integer); // General handler called at every cycle. This is NewBeatDetect from
// UNote with adaptation

function noteHit(availableTones: array of integer; actualTone: integer): boolean;

implementation

uses
  UNote,UFluidSynth;

procedure createMidiNoteHandler();
begin
  if  midiNoteHandler=nil then midiNoteHandler:=TMidiNoteHandler.create;
end;



procedure handleMidiNotes(Screen: TScreenSingController;CP: integer );
   var
       NotesAvailable: array of PLineFragment; // contains the presently playing midi notes
       TonesAvailable: array of Integer;
       countNotesAvailable: integer;
       ActualBeat:          integer;
       PlayerIndex:         integer;
       SentenceMin:         integer;
       SentenceMax:         integer;
       SentenceDetected:    Integer; // Highest sentence that was already started
       SentenceIndex:       integer;
       CurrentLineFragment: PLineFragment;
       Line: 	       PLine;
       LineFragmentIndex:   integer;
       CurrentMidiKeyboardStream: TMidiKeyboardPressedStream;
       CurrentPlayer:       PPlayer;
       KeysCurrentlyPlayed: array of integer;
       countKeysPlayed: integer;
       countNotesPlayer: integer;
       countTones: integer;
       NewNote: boolean;
begin

  setLength(NotesAvailable,0);

  SentenceDetected:=0;
  countNotesAvailable:=0;
  if CurrentSong.freestyleMidi then begin // We only do something when the song is configured for this
    SentenceMin := Tracks[CP].CurrentLine-1;
    if (SentenceMin < 0) then
       SentenceMin := 0;
    SentenceMax := Tracks[CP].CurrentLine;
    for PlayerIndex := 0 to PlayersPlay-1 do
    begin
      if (Ini.PlayerMidiInputDevice[PlayerIndex]>-1) and (Ini.PlayerMidiSynthesizerOn[PlayerIndex]=1) then
      // also, need midi device and midi device on for the play
      begin
         for ActualBeat := LyricsState.OldBeatD+1 to LyricsState.CurrentBeatD do // Newly covered beats
         // with rapid beats it can happen that we have to treat several beats in a single detection period
         begin
           if (not CurrentSong.isDuet) or (PlayerIndex mod 2 = CP) then
           begin
              setLength(NotesAvailable,0);
              SentenceDetected:=0;
        for SentenceIndex := SentenceMin to SentenceMax do
        begin
          Line := @Tracks[CP].Lines[SentenceIndex];


          for LineFragmentIndex := 0 to Line.HighNote do
          begin
            CurrentLineFragment := @Line.Notes[LineFragmentIndex];
            // check if line is active and freestyle (for which we analyze midi here
            if (CurrentLineFragment.StartBeat <= ActualBeat) and
              (CurrentLineFragment.StartBeat + CurrentLineFragment.Duration-1 >= ActualBeat) and
              (CurrentLineFragment.NoteType = ntFreestyle) and // If beat mode is on, rap notes are handled separately
              (CurrentLineFragment.Duration > 0) then                   // and make sure the note length is at least 1
            begin

              setLength(NotesAvailable, High(NotesAvailable)-Low(NotesAvailable)+2);
               NotesAvailable[countNotesAvailable]:=CurrentLineFragment;
               SentenceDetected:= SentenceIndex;
               countNotesAvailable:=countNotesAvailable+1;
            end;
          end;

        end; // Having gone through the sentences (change of notes shown) adjacent to current beat
        // We should now know all the notes that are supposed to be played on the current beat

        setLength(TonesAvailable,0);

        for countTones:=low(NotesAvailable) to high(NotesAvailable) do begin
          if (not noteHit(TonesAvailable, NotesAvailable[countTones].Tone)) then
          begin
            setLength(TonesAvailable,High(TonesAvailable)-Low(TonesAvailable)+2);
            TonesAvailable[High(TonesAvailable)]:= NotesAvailable[countTones].Tone;
          end;
        end;


        CurrentPlayer := @Player[PlayerIndex];
        CurrentMidiKeyboardStream := midiNoteHandler.midiKeyboardStreams[PlayerIndex];
        // Here I need to go on, recover the players keyboard state, that is, the keys currently playing
        //CurrentMidiKeyboardState := AudioInputProcessor.Sound[PlayerIndex];
        KeysCurrentlyPlayed:=CurrentMidiKeyboardStream.key_currently_pressed();

        // Do the scoring here, we compare NotesAvailable, whish sould be played, to keysCurrentPlayed, which is what is actually
        // played at present

        // Now we need to see whether we can add the currently played notes to some notes already going on or whether we
        // need to start a new one for the purpose of drawing the lines played


        // check if we have to add a new note or extend the note's length
        if (SentenceDetected = SentenceMax) then
        begin
        for countKeysPlayed:=Low(KeysCurrentlyPlayed) to High(KeysCurrentlyPlayed) do
        begin
          newNote:=true;
          for countNotesPlayer := Low(CurrentPlayer.Note) to High(CurrentPlayer.Note) do
          begin // Check whether any of
             if (CurrentPlayer.Note[countNotesPlayer].Tone = KeysCurrentlyPlayed[countKeysPlayed]) and
                ((CurrentPlayer.Note[countNotesPlayer].Start + CurrentPlayer.Note[countNotesPlayer].Duration) = ActualBeat)
                then
                begin
                  // There is still some cases where we need to start a new note
                  // first, if a note had been on spot, but is prolonged beyond the end of the actual note
                  if (CurrentPlayer.Note[countNotesPlayer].Hit) and (not noteHit(TonesAvailable, KeysCurrentlyPlayed[countKeysPlayed]))
                  then
                      NewNote := true
                  else if( not (CurrentPlayer.Note[countNotesPlayer].Hit)) and (noteHit(TonesAvailable, KeysCurrentlyPlayed[countKeysPlayed]))
                  then
                      NewNote := true
                  else // no specific issue, we can continue
                      NewNote := false;
                end;

            // Also, if on the tone on which we are a new note starts
            for LineFragmentIndex := 0 to Line.HighNote do
            begin
              if ((Line.Notes[LineFragmentIndex].StartBeat = ActualBeat) and
                 (Line.Notes[LineFragmentIndex].Tone = CurrentPlayer.Note[countNotesPlayer].Tone)) then
                NewNote := true;
            end;
            // add new note
            if (not NewNote) then
            begin
              // extend note length
              Inc(CurrentPlayer.Note[countNotesPlayer].Duration);
              Break;
            end;
          end;
          if newNote then // Could not inscribe key being played into ongoing player notes
          // so add a new note to the current player's note list
          begin
              // new note
              Inc(CurrentPlayer.LengthNote);
              Inc(CurrentPlayer.HighNote);
              SetLength(CurrentPlayer.Note, CurrentPlayer.LengthNote);

              // update the newly added note
              with CurrentPlayer.Note[CurrentPlayer.HighNote] do
              begin
                Start    := ActualBeat;
                Duration := 1;
                Tone     := KeysCurrentlyPlayed[countKeysPlayed]; // Tone || ToneAbs
                //Detect := LyricsState.MidBeat; // Not used!
                Hit      := noteHit(TonesAvailable, KeysCurrentlyPlayed[countKeysPlayed]);
                NoteType := ntFreestyle;
              end;
          end;



        end; // End going through the keys being actually played

        end; // End we are in the highest available sentence and actually can add to existing notes



       end; // end common conditions required

      end; // End loop over the beats to handle

    end; // End loop over the players to be handled



  end;

  end;

end;

function noteHit(availableTones: array of integer; actualTone: integer): boolean;
var count : integer;
begin
  result:=false;
  for count:=low(availableTones) to high(availableTones) do
  begin
    if actualTone=availableTones[count] then
      result:=true;
  end;
end;

constructor TMidiNoteHandler.create;
begin
  setLength(midiKeyboardStreams,0);
  setLength(midiInputDeviceMessaging,0);
  setLength(midiOutputDeviceMessaging,0);
  createfluidSynthHandler();
end;

procedure TMidiNoteHandler.stopMidiHandling(stopFluidSynth: boolean);
var count: Integer;
begin
  for count:=Low(midiInputDeviceMessaging) to High(midiInputDeviceMessaging) do
  begin
    if not (midiInputDeviceMessaging[count]=nil) then begin
         midiInputDeviceMessaging[count].stopTransfer;
         midiInputDeviceMessaging[count].free;
         midiInputDeviceMessaging[count]:=nil;
   end;
  end;
  for count:=Low(midiKeyboardStreams) to High(midiKeyboardStreams) do
  begin
    if not (midiKeyboardStreams[count]=nil) then begin
         midiKeyboardStreams[count].free;
         midiKeyboardStreams[count]:=nil;
   end;
  end;
  for count:=Low(midiOutputDeviceMessaging) to High(midiOutputDeviceMessaging) do
  begin
  if not (midiOutputDeviceMessaging[count]=nil) then begin
         midiOutputDeviceMessaging[count].free;
         midiOutputDeviceMessaging[count]:=nil;

   end;
   end;
   if stopFluidSynth then begin
     fluidSynthHandler.StopMidi();
     fluidSynthHandler.StopAudio();
   end;

   setLength(midiInputDeviceMessaging,0);
   setLength(midiKeyboardStreams,0);
   setLength(midiOutputDeviceMessaging,0);

end;

procedure TMidiNoteHandler.updateForCurrentPlayers;
var count : integer;
    cb_array: array of TMidiInputDeviceMessaging.TCallbackProc;
    cb_data_array: array of pointer;
begin
  // Free previous handles (from preceding song), also stop the synthesizer if
  //
  stopMidiHandling((not CurrentSong.freestyleMidi));

   if CurrentSong.freestyleMidi then // The current song actually requires midi playing
   begin
     // In case this has not been initialized elsewhere
     setLength(midiInputDeviceMessaging,PlayersPlay);
     setLength(midiKeyboardStreams,PlayersPlay);
     setLength(midiOutputDeviceMessaging,PlayersPlay);
     for count:=Low(midiInputDeviceMessaging) to High(midiInputDeviceMessaging) do begin
       // We only need an input device if the player actually is using a valid midi device
       if (Ini.PlayerMidiInputDevice[count]>=0) then
       begin
          midiKeyboardStreams[count]:=TMidiKeyboardPressedStream.create;
          if (Ini.PlayerMidiSynthesizerOn[count]=1) then begin // Connect the synthesizer
             fluidSynthHandler.StartAudio(); // In case this has not been initialized elsewhere
             fluidSynthHandler.StartMidi();
             midiOutputDeviceMessaging[count]:=TMidiOutputDeviceMessaging.create(fluidSynthHandler.midi_port_id);
             setLength(cb_array,2);
             setLength(cb_data_array,2);
             cb_array[0]:=@callback_midiKeyboardPressedStream;
             cb_array[1]:=@callback_midiOutputDeviceMessaging;
             cb_data_array[0]:=midiKeyboardStreams[count];
             cb_data_array[1]:=midiOutputDeviceMessaging[count];
             midiInputDeviceMessaging[count]:=TMidiInputDeviceMessaging.create(
               Ini.PlayerMidiInputDevice[count],cb_array,false,cb_data_array);
          end else begin
             midiOutputDeviceMessaging[count]:=nil; // No transmission to the synthesizer
             setLength(cb_array,1);
             setLength(cb_data_array,1);
             cb_array[0]:=@callback_midiKeyboardPressedStream;
             cb_data_array[0]:=midiKeyboardStreams[count];
             midiInputDeviceMessaging[count]:=TMidiInputDeviceMessaging.create(
               Ini.PlayerMidiInputDevice[count],cb_array,false,cb_data_array);
          end;
       end
       else
       begin
         midiInputDeviceMessaging[count]:=nil; // otherwise we set the input-device to nil
       end;
     end;



  end;
end;












end.

