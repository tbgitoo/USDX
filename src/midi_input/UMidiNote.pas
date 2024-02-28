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

 // global singleton for the TMidiNoteHandler class
var midiNoteHandler : TMidiNoteHandler;



procedure handleMidiNotes(Screen: TScreenSingController; CP: integer); // General handler called at every cycle. This is NewBeatDetect from
// UNote with adaptation

function noteHit(availableTones: array of integer; actualTone: integer): boolean;

procedure scoreNotesMidi(TonesAvailable: array of Integer;KeysCurrentlyPlayed: array of Integer;CP: integer);

procedure prepareScoresForMidi;

implementation

uses
  UNote,UFluidSynth,Math,
  UExtraScore;

procedure createMidiNoteHandler();
begin
  if  midiNoteHandler=nil then midiNoteHandler:=TMidiNoteHandler.create;
end;

procedure prepareScoresForMidi;
var
    MaxCP:Integer;
    localScoreFactor: array[TNoteType] of integer = (0, 1, 2, 1, 2);
    CP: Integer;
    countLine:integer;
    countNote:integer;

begin

  localScoreFactor[ntFreestyle]:=scoreFactor[ntFreestyle];
  localScoreFactor[ntNormal]:=scoreFactor[ntNormal];
  localScoreFactor[ntGolden]:=scoreFactor[ntGolden];
  localScoreFactor[ntRap]:=scoreFactor[ntRap];
  localScoreFactor[ntRapGolden]:=scoreFactor[ntRapGolden];


  MaxCP := 0;
  if (CurrentSong.isDuet) and (PlayersPlay <> 1) then
    MaxCP := 1;
    for CP := 0 to MaxCP do begin
        Tracks[CP].ScoreValue:=0;
        if CurrentSong.freestyleMidi
             and (Ini.PlayerMidiInputDevice[CP]>-1) then begin
                 localScoreFactor[ntFreestyle] := 1;
             end else begin
                 localScoreFactor[ntFreestyle] := 0;
             end;
         for countLine:=Low(Tracks[CP].Lines) to High(Tracks[CP].Lines) do begin
             for countNote:=Low(Tracks[CP].Lines[countLine].Notes) to High (Tracks[CP].Lines[countLine].Notes) do begin
                Inc(Tracks[CP].ScoreValue, Tracks[CP].Lines[countLine].Notes[countNote].Duration *
                  localScoreFactor[Tracks[CP].Lines[countLine].Notes[countNote].NoteType]);
                Inc(Tracks[CP].Lines[countLine].ScoreValue, Tracks[CP].Lines[countLine].Notes[countNote].Duration *
                  localScoreFactor[Tracks[CP].Lines[countLine].Notes[countNote].NoteType]);

             end;

         end;

    end;





end;

procedure handleMidiNotes(Screen: TScreenSingController;CP: integer );
   var
       NotesAvailable: array of TLineFragment; // contains the presently playing midi notes
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
      if (Ini.PlayerMidiInputDevice[PlayerIndex]>-1) then
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
            if (CurrentLineFragment^.StartBeat <= ActualBeat) and
              (CurrentLineFragment^.StartBeat + CurrentLineFragment^.Duration-1 >= ActualBeat) and
              (CurrentLineFragment^.NoteType = ntFreestyle) and // If beat mode is on, rap notes are handled separately
              (CurrentLineFragment^.Duration > 0) then                   // and make sure the note length is at least 1
            begin

              setLength(NotesAvailable, length(NotesAvailable)+1);


               NotesAvailable[countNotesAvailable].StartBeat:=CurrentLineFragment^.StartBeat;
               NotesAvailable[countNotesAvailable].Duration:=CurrentLineFragment^.Duration;
               NotesAvailable[countNotesAvailable].Tone:=CurrentLineFragment^.Tone;
               NotesAvailable[countNotesAvailable].Text:=CurrentLineFragment^.Text;
               NotesAvailable[countNotesAvailable].NoteType:=CurrentLineFragment^.NoteType;
               NotesAvailable[countNotesAvailable].IsMedley:=CurrentLineFragment^.IsMedley;
               NotesAvailable[countNotesAvailable].IsStartPreview:=CurrentLineFragment^.IsStartPreview;



               SentenceDetected:= SentenceIndex;
               countNotesAvailable:=countNotesAvailable+1;
            end;
          end;

        end; // Having gone through the sentences (change of notes shown) adjacent to current beat
        // We should now know all the notes that are supposed to be played on the current beat

        setLength(TonesAvailable,0);
        if(Length(NotesAvailable)>0) then begin
          for countTones:=low(NotesAvailable) to high(NotesAvailable) do begin
            if (not noteHit(TonesAvailable, NotesAvailable[countTones].Tone)) then
            begin
              setLength(TonesAvailable,length(TonesAvailable)+1);
              TonesAvailable[High(TonesAvailable)]:= NotesAvailable[countTones].Tone;
            end;
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

        // We are still within the song, that is it's not the last sentence (aka Line with regards to notes)
        // and if it is, we are still in the line.
        // in this case, we need to do scoring
        if ((not Line.LastLine) or (ActualBeat<Line.EndBeat)) then
           scoreNotesMidi(TonesAvailable,KeysCurrentlyPlayed,CP);



        // check if we have to add a new note or extend the note's length
        if (SentenceDetected = SentenceMax) or (SentenceDetected = 0) then // We also want to score when no notes could be detected
        begin

        for countKeysPlayed:=Low(KeysCurrentlyPlayed) to High(KeysCurrentlyPlayed) do
        begin
          newNote:=true;
          for countNotesPlayer := Low(CurrentPlayer.Note) to High(CurrentPlayer.Note) do
          begin // Check whether any of the tones already registered correspond to the ones being play
             if (CurrentPlayer.Note[countNotesPlayer].Tone = KeysCurrentlyPlayed[countKeysPlayed]) and
                ((CurrentPlayer.Note[countNotesPlayer].Start + CurrentPlayer.Note[countNotesPlayer].Duration) = ActualBeat)
                then
                begin

                  // There is still some cases where we need to start a new note
                  // first, if a note had been on spot, but is prolonged beyond the end of the actual note

                  if (CurrentPlayer.Note[countNotesPlayer].Hit) and (not noteHit(TonesAvailable, KeysCurrentlyPlayed[countKeysPlayed]))
                  then
                      begin NewNote := true;  end
                  else if( not (CurrentPlayer.Note[countNotesPlayer].Hit)) and (noteHit(TonesAvailable, KeysCurrentlyPlayed[countKeysPlayed]))
                  then begin
                      NewNote := true
                  end
                  else // no specific issue, we can continue
                      begin
                      NewNote := false;

                      end;
                end;

            // Also, if on the tone on which we are a new note starts
            for LineFragmentIndex := 0 to Line.HighNote do
            begin
              if ((Line.Notes[LineFragmentIndex].StartBeat = ActualBeat) and
                 (Line.Notes[LineFragmentIndex].Tone = CurrentPlayer.Note[countNotesPlayer].Tone)) then
                NewNote := true;
            end;
            // not a add new note
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
                if (length(TonesAvailable)>0) and (countKeysPlayed >= low(KeysCurrentlyPlayed)) and (countKeysPlayed<=high(KeysCurrentlyPlayed)) then
                Hit      := noteHit(TonesAvailable, KeysCurrentlyPlayed[countKeysPlayed]) else
                Hit      := False;

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

procedure scoreNotesMidi(TonesAvailable: array of Integer;KeysCurrentlyPlayed: array of Integer; CP: integer);
var MaxSongPoints:       integer;
    CurNotePoints:       real;
    countCurrentKeysPlayed: integer;
    countCurrentNotesAvailable: integer;
    penaltyWronglyPlayed, penaltyMissed: real;
begin

  case Ini.PlayerLevel[CP] of
      0: begin penaltyWronglyPlayed:=0.5; penaltyMissed:=0; end;
      1: begin penaltyWronglyPlayed:=4; penaltyMissed:=1; end;
      2: begin penaltyWronglyPlayed:=8; penaltyMissed:=4; end;
  end;

  if (Ini.LineBonus > 0) then
                  MaxSongPoints := MAX_SONG_SCORE - MAX_SONG_LINE_BONUS
                else
                  MaxSongPoints := MAX_SONG_SCORE;

                // Note: ScoreValue is the sum of all note values of the song
                // (MaxSongPoints / ScoreValue) is the points that a player
                // gets for a hit of one beat of a normal note
                // CurNotePoints is the amount of points that is meassured
                // for a hit of the note per full beat
  CurNotePoints := (MaxSongPoints / Tracks[CP].ScoreValue);
  // There are three types of notes: A)notes played, but missed; B) notes played and scored; C) notes that should have been played but were not.
  // We first handle the two cases A (for substraction) and B (for awarding points)
  for countCurrentKeysPlayed:=Low(KeysCurrentlyPlayed) to High(KeysCurrentlyPlayed) do
  begin
    if noteHit(TonesAvailable, KeysCurrentlyPlayed[countCurrentKeysPlayed]) then
       Player[CP].Score       := Player[CP].Score       + CurNotePoints*ExtraScoreFactor()
    else
       begin
       Player[CP].Score       := Player[CP].Score       - penaltyWronglyPlayed*CurNotePoints;
           if Player[CP].Score <0 then Player[CP].Score:=0; // do not go below 0
       end;

  end;
  // And now we can handle the last case, notes that should have been played but are not
  for countCurrentNotesAvailable:=Low(TonesAvailable) to High(TonesAvailable) do
  begin
    if not noteHit(KeysCurrentlyPlayed,TonesAvailable[countCurrentNotesAvailable]) then begin
       Player[CP].Score       := Player[CP].Score       - penaltyMissed*CurNotePoints;
           if Player[CP].Score <0 then Player[CP].Score:=0; // do not go below 0
    end;
  end;

  Player[CP].ScoreInt := round(Player[CP].Score / 10) * 10;

  if (Player[CP].ScoreInt < Player[CP].Score) then
                  //normal score is floored so we have to ceil golden notes score
                  Player[CP].ScoreGoldenInt := ceil(Player[CP].ScoreGolden / 10) * 10
  else
                  //normal score is ceiled so we have to floor golden notes score
                  Player[CP].ScoreGoldenInt := floor(Player[CP].ScoreGolden / 10) * 10;


  Player[CP].ScoreTotalInt := Player[CP].ScoreInt +
                                               Player[CP].ScoreGoldenInt +
                                               Player[CP].ScoreLineInt;



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
         midiOutputDeviceMessaging[count].CloseOutput();
         midiOutputDeviceMessaging[count].free;
         midiOutputDeviceMessaging[count]:=nil;

   end;
   end;
   if stopFluidSynth then begin
     fluidSynthHandler.StopMidi();
     fluidSynthHandler.StopAudio();
     fluidSynthHandler.sendNotesOff();
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
             fluidSynthHandler.applyTuningFromIni();
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

