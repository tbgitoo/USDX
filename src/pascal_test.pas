program helloWorld(output);

{$IFDEF MSWINDOWS}
  {$R '..\res\link.res' '..\res\link.rc'}
{$ENDIF}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

{$IFDEF MSWINDOWS}
  // Set global application-type (GUI/CONSOLE) switch for Windows.
  // CONSOLE is the default for FPC, GUI for Delphi, so we have
  // to specify one of the two in any case.
  {$IFDEF CONSOLE}
    {$APPTYPE CONSOLE}
  {$ELSE}
    {$APPTYPE GUI}
  {$ENDIF}
{$ENDIF}

uses
  //heaptrc,
  {$IFDEF Unix}
  cthreads,            // THIS MUST be the first used unit in FPC if Threads are used!!
                       // (see http://wiki.lazarus.freepascal.org/Multithreaded_Application_Tutorial)
  cwstring,            // Enable Unicode support
  {$ENDIF}

{$IFNDEF FPC}
  ctypes                 in 'lib\ctypes\ctypes.pas', // FPC compatibility types for C libs
  {$ENDIF}

UMainThread              in 'base\UMainThread.pas',

  //------------------------------
  //Includes - 3rd Party Libraries
  //------------------------------
  AnyAscii               in 'lib\anyascii\anyascii.pas',
  SQLiteTable3  in 'lib\SQLite\SQLiteTable3.pas',
  SQLite3       in 'lib\SQLite\SQLite3.pas',
  sdl2                   in 'lib\SDL2\sdl2.pas',
  SDL2_image             in 'lib\SDL2\SDL2_image.pas',
  //new work on current OpenGL implementation
  dglOpenGL              in 'lib\dglOpenGL\dglOpenGL.pas',
  UMediaCore_SDL         in 'media\UMediaCore_SDL.pas',

  zlib                   in 'lib\zlib\zlib.pas',
  freetype               in 'lib\freetype\freetype.pas',

  {$IFDEF UseBass}
  BASS                   in 'lib\bass\delphi\bass.pas',
  BASS_FX                in 'lib\bass_fx\bass_fx.pas',
  UAudioCore_Bass        in 'media\UAudioCore_Bass.pas',
  {$ENDIF}
  {$IFDEF UsePortaudio}
  portaudio              in 'lib\portaudio\portaudio.pas',
  UAudioCore_Portaudio   in 'media\UAudioCore_Portaudio.pas',
  {$ENDIF}
  {$IFDEF UsePortmixer}
  portmixer              in 'lib\portmixer\portmixer.pas',
  {$ENDIF}
   {$IFDEF UseMIDIPort}
  {$IFNDEF HaveAMidi}
  portmidi               in 'lib\portmidi\portmidi.pp',
  {$ENDIF}
  {$ENDIF}
  {$IFDEF HaveAMidi}
  amidi               in 'lib\amidi\amidi.pp',
  {$ENDIF}
  {$IFDEF UsePortTime}
  porttime               in 'lib\portmidi\porttime.pp',
  {$ENDIF}

{$IFDEF UseFFmpeg}
    {$IFDEF FPC} // This solution is not very elegant, but working
      avcodec             in 'lib\' + FFMPEG_DIR + '\avcodec.pas',
      avformat            in 'lib\' + FFMPEG_DIR + '\avformat.pas',
      avutil              in 'lib\' + FFMPEG_DIR + '\avutil.pas',
      rational            in 'lib\' + FFMPEG_DIR + '\rational.pas',
      avio                in 'lib\' + FFMPEG_DIR + '\avio.pas',
      {$IFDEF UseSWResample}
      swresample          in 'lib\' + FFMPEG_DIR + '\swresample.pas',
      {$ENDIF}
      {$IFDEF useOLD_FFMPEG}
        mathematics       in 'lib\' + FFMPEG_DIR + '\mathematics.pas',
        opt               in 'lib\' + FFMPEG_DIR + '\opt.pas',
      {$ENDIF}
      {$IFDEF UseSWScale}
        swscale           in 'lib\' + FFMPEG_DIR + '\swscale.pas',
      {$ENDIF}
    {$ELSE} // speak: This is for Delphi. Change version as needed!
      avcodec            in 'lib\ffmpeg-0.10\avcodec.pas',
      avformat           in 'lib\ffmpeg-0.10\avformat.pas',
      avutil             in 'lib\ffmpeg-0.10\avutil.pas',
      rational           in 'lib\ffmpeg-0.10\rational.pas',
      avio               in 'lib\ffmpeg-0.10\avio.pas',
      {$IFDEF UseSWResample}
      swresample         in 'lib\ffmpeg-0.10\swresample.pas',
      {$ENDIF}
      {$IFDEF UseSWScale}
        swscale          in 'lib\ffmpeg-0.10\swscale.pas',
      {$ENDIF}
    {$ENDIF}
    UMediaCore_FFmpeg    in 'media\UMediaCore_FFmpeg.pas',
  {$ENDIF}  // UseFFmpeg

  {$IFDEF UseSRCResample}
  samplerate             in 'lib\samplerate\samplerate.pas',
  {$ENDIF}

  {$IFDEF UseProjectM}
  projectM      in 'lib\projectM\projectM.pas',
  {$ENDIF}

  {$IFDEF UseMIDIPort}
    MidiCons          in 'lib\midi\MidiCons.pas',
    MidiFile          in 'lib\midi\MidiFile.pas',

    {$IFDEF MSWINDOWS}
      CircBuf         in 'lib\midi\CircBuf.pas',
      MidiConsWin     in 'lib\midi\MidiConsWin.pas',
      DelphiMcb       in 'lib\midi\DelphiMcb.pas',
      MidiDefs        in 'lib\midi\MidiDefs.pas',
      MidiType        in 'lib\midi\MidiType.pas',
      MidiOut         in 'lib\midi\MidiOut.pas',
    {$ELSE}
      {$IFDEF UsePortMidi}
        MidiOut       in 'lib\portmidi\MidiOut.pas',
      {$ENDIF}
    {$ENDIF}
  {$ELSE}
     {$IFDEF HaveAMidi}
  	MidiFile          in 'lib\midi\MidiFile.pas',
     {$ENDIF}
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  {$IFDEF FPC}
  // FPC compatibility file for Allocate/DeallocateHWnd
  WinAllocation in 'lib\other\WinAllocation.pas',
  Windows,
  {$ENDIF}
  {$ENDIF}

  {$IFDEF DARWIN}
  PseudoThread  in 'macosx\PseudoThread.pas',
  {$ENDIF}

  //------------------------------
  //Includes - Lua Support
  //------------------------------
  ULua           in 'lib\Lua\ULua.pas',
  ULuaUtils      in 'lua\ULuaUtils.pas',
  ULuaGl         in 'lua\ULuaGl.pas',
  ULuaLog        in 'lua\ULuaLog.pas',
  ULuaTextGL     in 'lua\ULuaTextGL.pas',
  ULuaTexture    in 'lua\ULuaTexture.pas',
  UHookableEvent in 'lua\UHookableEvent.pas',
  ULuaCore       in 'lua\ULuaCore.pas',
  ULuaUsdx       in 'lua\ULuaUsdx.pas',
  ULuaParty      in 'lua\ULuaParty.pas',
  ULuaScreenSing in 'lua\ULuaScreenSing.pas',

  //------------------------------
  //Includes - Menu System
  //------------------------------
  UDisplay               in 'menu\UDisplay.pas',
  UMenu                  in 'menu\UMenu.pas',
  UMenuStatic            in 'menu\UMenuStatic.pas',
  UMenuText              in 'menu\UMenuText.pas',
  UMenuButton            in 'menu\UMenuButton.pas',
  UMenuInteract          in 'menu\UMenuInteract.pas',
  UMenuSelectSlide       in 'menu\UMenuSelectSlide.pas',
  UMenuEqualizer         in 'menu\UMenuEqualizer.pas',
  UDrawTexture           in 'menu\UDrawTexture.pas',
  UMenuButtonCollection  in 'menu\UMenuButtonCollection.pas',

  UMenuBackground        in 'menu\UMenuBackground.pas',
  UMenuBackgroundNone    in 'menu\UMenuBackgroundNone.pas',
  UMenuBackgroundColor   in 'menu\UMenuBackgroundColor.pas',
  UMenuBackgroundTexture in 'menu\UMenuBackgroundTexture.pas',
  UMenuBackgroundVideo   in 'menu\UMenuBackgroundVideo.pas',
  UMenuBackgroundFade    in 'menu\UMenuBackgroundFade.pas',

  //------------------------------
  //Includes - base
  //------------------------------
  UConfig           in 'base\UConfig.pas',

  UCommon           in 'base\UCommon.pas',
  UGraphic          in 'base\UGraphic.pas',
  UTexture          in 'base\UTexture.pas',
  ULanguage         in 'base\ULanguage.pas',
  UMain             in 'base\UMain.pas',
  UDraw             in 'base\UDraw.pas',
  URecord           in 'base\URecord.pas',
  UTime             in 'base\UTime.pas',
  USong             in 'base\USong.pas',
  USongs            in 'base\USongs.pas',
  UIni              in 'base\UIni.pas',
  UImage            in 'base\UImage.pas',
  ULyrics           in 'base\ULyrics.pas',
  UEditorLyrics     in 'base\UEditorLyrics.pas',
  USkins            in 'base\USkins.pas',
  UThemes           in 'base\UThemes.pas',
  ULog              in 'base\ULog.pas',
  UJoystick         in 'base\UJoystick.pas',
  UDataBase         in 'base\UDataBase.pas',
  UCovers           in 'base\UCovers.pas',
  UCatCovers        in 'base\UCatCovers.pas',
  UFiles            in 'base\UFiles.pas',
  UGraphicClasses   in 'base\UGraphicClasses.pas',
  UPlaylist         in 'base\UPlaylist.pas',
  UCommandLine      in 'base\UCommandLine.pas',
  URingBuffer       in 'base\URingBuffer.pas',
  USingScores       in 'base\USingScores.pas',
  USingNotes        in 'base\USingNotes.pas',
  UPathUtils        in 'base\UPathUtils.pas',
  UNote             in 'base\UNote.pas',
  UBeatTimer        in 'base\UBeatTimer.pas',

  TextGL            in 'base\TextGL.pas',
  UUnicodeUtils     in 'base\UUnicodeUtils.pas',
  UUnicodeStringHelper in 'base\uunicodestringhelper',
  UFont             in 'base\UFont.pas',
  UTextEncoding     in 'base\UTextEncoding.pas',

  UPath             in 'base\UPath.pas',
  UFilesystem       in 'base\UFilesystem.pas',

  UHelp             in 'base\UHelp.pas',


  //------------------------------
  //Includes -Beat Playing
  //------------------------------

  UBeatNote             in 'beatNote\UBeatNote.pas',
  UBeatNoteTimer        in 'beatNote\UBeatNoteTimer.pas',
  UExtraScore           in 'beatNote\UExtraScore.pas',

  //------------------------------
  //Includes -Keyboard Playing
  //-----

  UKeyboardRecording in 'beatNote\UKeyboardRecording.pas',

  //------------------------------
  //Includes Midi input and synthesiging (fluidsynth)
  //------------------------------

  UMidiInputStream in 'midi_input\UMidiInputStream.pas',
  pasfluidsynth in 'lib\fluidsynth\pasfluidsynth.pas',
  UFluidSynth in 'lib\fluidsynth\UFluidSynth.pas',
  UMidiTransfer in 'midi_input\UMidiTransfer.pas',
  UMidiNote in 'midi_input\UMidiNote.pas',
  UScreenOptionsSoundfont in 'midi_input\UScreenOptionsSoundfont.pas',
  UMidiPlayback in 'midi_input\UMidiPlayback.pas',

  //------------------------------
  //Includes - Plugin Support
  //------------------------------
  UParty            in 'base\UParty.pas',            // TODO: rewrite Party Manager as Module, reomplent ability to offer party Mody by Plugin

  //------------------------------
  //Includes - Platform
  //------------------------------

  UPlatform         in 'base\UPlatform.pas',
{$IF Defined(MSWINDOWS)}
  UPlatformWindows  in 'base\UPlatformWindows.pas',
{$ELSEIF Defined(DARWIN)}
  UPlatformMacOSX   in 'base\UPlatformMacOSX.pas',
{$ELSEIF Defined(ANDROID)}
UPlatformAndroid   in 'base\UPlatformAndroid.pas',
{$ELSEIF Defined(UNIX)}
  UPlatformLinux    in 'base\UPlatformLinux.pas',
{$IFEND}

  //------------------------------
  //Includes - Media
  //------------------------------

  UMusic                    in 'base\UMusic.pas',
  UAudioPlaybackBase        in 'media\UAudioPlaybackBase.pas',
{$IF Defined(UsePortaudioPlayback) or Defined(UseSDLPlayback)}
  UFFT                      in 'lib\fft\UFFT.pas',
  UAudioPlayback_SoftMixer  in 'media\UAudioPlayback_SoftMixer.pas',
{$IFEND}
  UAudioConverter           in 'media\UAudioConverter.pas',

  //******************************
  //Pluggable media modules
  // The modules are prioritized as in the include list below.
  // This means the first entry has highest priority, the last lowest.
  //******************************

{$IFDEF UseFFmpegVideo}
  UVideo                    in 'media\UVideo.pas',
{$ENDIF}
{$IFDEF UseProjectM}
  // must be after UVideo, so it will not be the default video module
  UVisualizer               in 'media\UVisualizer.pas',
{$ENDIF}
{$IFDEF UseBASSInput}
  UAudioInput_Bass          in 'media\UAudioInput_Bass.pas',
{$ENDIF}
{$IFDEF UseBASSDecoder}
  // prefer Bass to FFmpeg if possible
  UAudioDecoder_Bass        in 'media\UAudioDecoder_Bass.pas',
{$ENDIF}
{$IFDEF UseBASSPlayback}
  UAudioPlayback_Bass       in 'media\UAudioPlayback_Bass.pas',
{$ENDIF}
{$IFDEF UseSDLInput}
  UAudioInput_SDL           in 'media\UAudioInput_SDL.pas',
{$ENDIF}
{$IFDEF UseSDLPlayback}
  UAudioPlayback_SDL        in 'media\UAudioPlayback_SDL.pas',
{$ENDIF}
{$IFDEF UsePortaudioInput}
  UAudioInput_Portaudio     in 'media\UAudioInput_Portaudio.pas',
{$ENDIF}
{$IFDEF UsePortaudioPlayback}
  UAudioPlayback_Portaudio  in 'media\UAudioPlayback_Portaudio.pas',
{$ENDIF}
{$IFDEF UseFFmpegDecoder}
  UAudioDecoder_FFmpeg      in 'media\UAudioDecoder_FFmpeg.pas',
{$ENDIF}
  // fallback dummy, must be last
  UMedia_dummy              in 'media\UMedia_dummy.pas',


  //------------------------------
  //Includes - Screens
  //------------------------------
  UScreenLoading          in 'screens\UScreenLoading.pas',
  UScreenMain             in 'screens\UScreenMain.pas',
  UScreenName             in 'screens\UScreenName.pas',
  UScreenLevel            in 'screens\UScreenLevel.pas',
  UScreenSong             in 'screens\UScreenSong.pas',
  UScreenSingController   in 'screens\controllers\UScreenSingController.pas',
  UScreenSingView         in 'screens\views\UScreenSingView.pas',
  UScreenScore            in 'screens\UScreenScore.pas',
  UScreenJukebox          in 'screens\UScreenJukebox.pas',
  UScreenOptions          in 'screens\UScreenOptions.pas',
  UScreenOptionsGame      in 'screens\UScreenOptionsGame.pas',
  UScreenOptionsGraphics  in 'screens\UScreenOptionsGraphics.pas',
  UScreenOptionsSound     in 'screens\UScreenOptionsSound.pas',
  UScreenOptionsInput     in 'screens\UScreenOptionsInput.pas',
  UScreenOptionsLyrics    in 'screens\UScreenOptionsLyrics.pas',
  UScreenOptionsThemes    in 'screens\UScreenOptionsThemes.pas',
  UScreenOptionsRecord    in 'screens\UScreenOptionsRecord.pas',
  UScreenOptionsAdvanced  in 'screens\UScreenOptionsAdvanced.pas',
  UScreenOptionsNetwork   in 'screens\UScreenOptionsNetwork.pas',
  UScreenOptionsWebcam    in 'screens\UScreenOptionsWebcam.pas',
  UScreenOptionsJukebox   in 'screens\UScreenOptionsJukebox.pas',
  UScreenEditSub          in 'screens\UScreenEditSub.pas',
  UScreenEdit             in 'screens\UScreenEdit.pas',
  UScreenEditConvert      in 'screens\UScreenEditConvert.pas',
  UScreenOpen             in 'screens\UScreenOpen.pas',
  UScreenTop5             in 'screens\UScreenTop5.pas',
  UScreenSongMenu         in 'screens\UScreenSongMenu.pas',
  UScreenSongJumpto       in 'screens\UScreenSongJumpto.pas',
  UScreenStatMain         in 'screens\UScreenStatMain.pas',
  UScreenStatDetail       in 'screens\UScreenStatDetail.pas',
  UScreenCredits          in 'screens\UScreenCredits.pas',
  UScreenPopup            in 'screens\UScreenPopup.pas',

  //Includes - Screens PartyMode
  UScreenPartyNewRound    in 'screens\UScreenPartyNewRound.pas',
  UScreenPartyScore       in 'screens\UScreenPartyScore.pas',
  UScreenPartyPlayer      in 'screens\UScreenPartyPlayer.pas',
  UScreenPartyOptions     in 'screens\UScreenPartyOptions.pas',
  UScreenPartyRounds      in 'screens\UScreenPartyRounds.pas',
  UScreenPartyWin         in 'screens\UScreenPartyWin.pas',

  UWebSDK                 in 'webSDK\UWebSDK.pas',
  //curlobj                 in 'webSDK\cURL\src\curlobj.pas',

{$IFDEF UseOpenCVWrapper}
  opencv_highgui          in 'lib\openCV3\opencv_highgui.pas',
  opencv_core             in 'lib\openCV3\opencv_core.pas',
  opencv_imgproc          in 'lib\openCV3\opencv_imgproc.pas',
  opencv_types            in 'lib\openCV3\opencv_types.pas',
{$ELSE}
  opencv_highgui          in 'lib\openCV\opencv_highgui.pas',
  opencv_core             in 'lib\openCV\opencv_core.pas',
  opencv_imgproc          in 'lib\openCV\opencv_imgproc.pas',
  opencv_types            in 'lib\openCV\opencv_types.pas',
{$ENDIF}

  UMenuStaticList in 'menu\UMenuStaticList.pas',
  UWebcam                 in 'base\UWebcam.pas',

  UDLLManager             in 'base\UDLLManager.pas',

  UPartyTournament              in 'base\UPartyTournament.pas',
  UScreenPartyTournamentRounds  in 'screens\UScreenPartyTournamentRounds.pas',
  UScreenPartyTournamentPlayer  in 'screens\UScreenPartyTournamentPlayer.pas',
  UScreenPartyTournamentOptions in 'screens\UScreenPartyTournamentOptions.pas',
  UScreenPartyTournamentWin     in 'screens\UScreenPartyTournamentWin.pas',
  UScreenJukeboxOptions         in 'screens\UScreenJukeboxOptions.pas',
  UScreenJukeboxPlaylist        in 'screens\UScreenJukeboxPlaylist.pas',

  UAvatars                in 'base\UAvatars.pas',

  UScreenOptionsBeatPlay   in 'beatNote\UScreenOptionsBeatPlay.pas',
  UScreenOptionsBeatPlayPeakAnalysis          in 'beatNote\UScreenOptionsBeatPlayPeakAnalysis.pas',
  UScreenOptionsMidiInput          in 'midi_input\UScreenOptionsMidiInput.pas',


  UScreenAbout            in 'screens\UScreenAbout.pas',

  SysUtils;


var
  WindowTitle: string;
  BadPlayer: integer;

const
  WINDOW_ICON = 'icons/ultrastardx-icon.png';

  procedure LoadFontTextures;
begin

  BuildFonts;
end;
procedure LoadLoadingScreen_test;
begin

  ScreenLoading := TScreenLoading.Create;


  ScreenLoading.OnShow;
  Display.CurrentScreen := @ScreenLoading;

  SwapBuffers;

  ScreenLoading.Draw;
  Log.logStatus('UGraphic','LoadLoadingScreen Drawing done' );

  Log.logStatus('test',LUA_LIB_NAME);
  luaL_newstate;


end;


procedure Initialize3D_test (Title: string);
var
  Icon: PSDL_Surface;
begin



  if ( SDL_InitSubSystem(SDL_INIT_VIDEO) = -1 ) then
  begin
    Log.LogCritical('SDL_Init Failed', 'UGraphic.Initialize3D');
  end;

  InitializeScreen;


  // load icon image (must be 32x32 for win32)
  Icon := LoadImage(ResourcesPath.Append(WINDOW_ICON));
  if (Icon <> nil) then
  begin
    SDL_SetWindowIcon(Screen, Icon);
    SDL_FreeSurface(Icon);
  end;

  SDL_SetWindowTitle(Screen, PChar(Title));

  { workaround for buggy Intel 3D driver on Linux }
  //SDL_putenv('texture_tiling=false');  //ToDo: on linux, check if this is still necessary with SDL 2

  SDL_SetWindowTitle(Screen, PChar(Title + ' - Initializing screen'));


  SDL_SetWindowTitle(Screen, PChar(Title + ' - Initializing texturizer'));
  Texture := TTextureUnit.Create;
  Texture.Limit :=1920; //currently, Full HD is all we want. switch to 64bit target before going further up

  //LoadTextures;
  SDL_SetWindowTitle(Screen, PChar(Title + ' - Initializing video modules'));
  // Note: do not initialize video modules earlier. They might depend on some
  // SDL video functions or OpenGL extensions initialized in InitializeScreen()
  InitializeVideo();

  SDL_SetWindowTitle(Screen, PChar(Title + ' - Initializing 3D'));
  Display := TDisplay.Create;
  //Display.SetCursor;

  SDL_SetWindowTitle(Screen, PChar(Title + ' - Loading font textures'));

  LoadFontTextures();

  // Show the Loading Screen
  SDL_SetWindowTitle(Screen, PChar(Title + ' - Loading first screen'));

  LoadLoadingScreen_test;




end;


begin
        SetMultiByteConversionCodePage(CP_UTF8);
        WindowTitle := USDXVersionStr;



        Platform.Init;

        Log.Title := WindowTitle;
        Log.FileOutputEnabled := true;

         // Commandline Parameter Parser
         Params := TCMDParams.Create;

         if Platform.TerminateIfAlreadyRunning(WindowTitle) then
      Exit;

    // fix floating-point exceptions (FPE)
    DisableFloatingPointExceptions();
    // fix the locale for string-to-float parsing in C-libs
    SetDefaultNumericLocale();

    // setup separators for parsing
    // Note: ThousandSeparator must be set because of a bug in TIniFile.ReadFloat
    DefaultFormatSettings.ThousandSeparator := ',';
    DefaultFormatSettings.DecimalSeparator := '.';

    //------------------------------
    // StartUp - create classes and load files
    //------------------------------

    // initialize SDL
    // without SDL_INIT_TIMER SDL_GetTicks() might return strange values
    SDL_SetHint(SDL_HINT_WINDOWS_DISABLE_THREAD_NAMING, '1');
    SDL_Init(SDL_INIT_VIDEO or SDL_INIT_TIMER);
    //SDL_EnableUnicode(1);  //not necessary in SDL2 any more

    // create luacore first so other classes can register their events
    LuaCore := TLuaCore.Create;

    USTime := TTime.Create;
    VideoBGTimer := TRelativeTimer.Create;

    // Language
    Log.LogStatus('Initialize Paths', 'Initialization');
    InitializePaths;

    Log.SetLogFileLevel(50);
    Log.LogStatus('Load Language', 'Initialization');
    Language := TLanguage.Create;

    // add const values:
    Language.AddConst('US_VERSION', USDXVersionStr);

    // Skin
    Log.BenchmarkStart(1);
    Log.LogStatus('Loading Skin List', 'Initialization');
    Skin := TSkin.Create;

    Log.LogStatus('Loading Theme List', 'Initialization');
    Theme := TTheme.Create;
    Log.LogStatus('Website-Manager', 'Initialization');
    DLLMan := TDLLMan.Create;   // Load WebsiteList
    Log.LogStatus('DataBase System', 'Initialization');
    DataBase := TDataBaseSystem.Create;

    if (Params.ScoreFile.IsUnset) then
      DataBase.Init(Platform.GetGameUserPath.Append('Ultrastar.db'))
    else
      DataBase.Init(Params.ScoreFile);

    // Ini + Paths
    Log.LogStatus('Load Ini', 'Initialization');
    Ini := TIni.Create;
    Ini.Load;

    // Help
    Log.LogStatus('Load Help', 'Initialization');
    Help := THelp.Create;

    // it is possible that this is the first run, create a .ini file if neccessary
    Log.LogStatus('Write Ini', 'Initialization');
    Ini.Save;

    // Theme
    Theme.LoadTheme(Ini.Theme, Ini.Color);

    // Sound
    InitializeSound();

    // Lyrics-engine with media reference timer
    LyricsState := TLyricsState.Create();

    // Graphics
    Initialize3D_test(WindowTitle);

	writeLn('Hello!');
end.