

library test;

{$IFDEF MSWINDOWS}
  {$R '..\res\link.res' '..\res\link.rc'}
{$ENDIF}

{$IFDEF FPC}
  {$MODE OBJFPC}
{$ENDIF}

{$I switches.inc}



uses
  //heaptrc,
    //heaptrc,
  {$IFDEF Unix}
  cthreads,            // THIS MUST be the first used unit in FPC if Threads are used!!
                       // (see http://wiki.lazarus.freepascal.org/Multithreaded_Application_Tutorial)
  cwstring,            // Enable Unicode support
  {$ENDIF}

  {$IFNDEF FPC}
  ctypes                 in 'lib\ctypes\ctypes.pas', // FPC compatibility types for C libs
  {$ENDIF}

  jni,   // For communication with Android Java


  {$IFDEF UseSDL3}
  SDL3 in 'lib\SDL3\sdl3.pas',
  SDL3_image             in 'lib\SDL3\sdl3_image.pas',
  {$ELSE}
  sdl2                   in 'lib\SDL2\sdl2.pas',
  SDL2_image             in 'lib\SDL2\SDL2_image.pas',
  {$ENDIF}
  //new work on current OpenGL implementation

  UMainThread              in 'base\UMainThread.pas',

  UJniCallback            in 'jni\UJniCallback.pas',

  SysUtils,
  // For test purposes only, remove
  dglOpenGLES in 'lib\dglOpenGL\dglOpenGLES.pas',

  SQLiteTable3  in 'lib\SQLite\SQLiteTable3.pas',
  SQLite3       in 'lib\SQLite\SQLite3.pas',

  UCommon in 'base\UCommon.pas',
  anyascii in 'lib\anyascii\anyascii.pas',
  UUnicodeUtils in 'base\UUnicodeUtils.pas',
  UConfig in 'base\UConfig.pas',
  UTime in 'base\UTime.pas',
  UTextEncoding in 'base\UTextEncoding.pas',
  IniFiles,
  UUnicodeStringHelper in 'base\UUnicodeStringHelper.pas',
  UPath in 'base\UPath.pas',
  UPathUtils in 'base\UPathUtils.pas',
  UFilesystem in 'base\UFilesystem.pas',
  ULog in 'base\ULog.pas',
  UPlatform in 'base\UPlatform.pas',
  UPlatformAndroid in 'base\UPlatformAndroid.pas',
  UCommandLine in 'base\UCommandLine.pas',
  UTexture in 'base\UTexture.pas',
  FreeType in 'lib\freetype\freetype.pas',
  UFont in 'base\UFont.pas',
  UImage in 'base\UImage.pas',
  zlib in 'lib\zlib\zlib.pas',
  TextGL in 'base\TextGL.pas',
  UWebSDK                 in 'webSDK\UWebSDK.pas',
  UBeatTimer        in 'base\UBeatTimer.pas', // Up to here things are fine, UBeatTimer needs fixing

  UIni in 'base\UIni.pas',
  UMidiInputStream in 'midi_input\UMidiInputStream.pas',
  UMidiTransfer in 'midi_input\UMidiTransfer.pas',
  Amidi in 'lib\amidi\amidi.pas',
  UFluidSynth in 'lib\fluidsynth\UFluidSynth.pas',
  pasfluidsynth_android in 'lib\fluidsynth\pasfluidsynth_android.pas',
  UWebcam in 'base\UWebcam.pas',
  UMusic in 'base\UMusic.pas',
  URecord in 'base\URecord.pas',
  UMidiPlayback in 'midi_input\UMidiPlayback.pas',
  MidiFile          in 'lib\midi\MidiFile.pas',
  ULanguage in 'base\ULanguage.pas',
  USkins in 'base\USkins.pas',
  UCatCovers in 'base\UCatCovers.pas',
  USong in 'base\USong.pas',
  UThemes in 'base\UThemes.pas',
  UHelp in 'base\UHelp.pas',
  USingScores in 'base\USingScores.pas',
  {$IFDEF UseFFmpegVideo}
  UVideo                    in 'media\UVideo.pas',
  UDLLManager               in 'base\UDLLManager.pas',
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

  UGraphicClasses   in 'base\UGraphicClasses.pas',
  UDataBase         in 'base\UDataBase.pas',

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



  UPlaylist in 'base\UPlaylist.pas',
  USongs in 'base\USongs.pas',
  UCovers in 'base\UCovers.pas',
  UFiles in 'base\UFiles.pas',
  UNote in 'base\UNote.pas',
  UGraphic in 'base\UGraphic.pas',
  UAvatars in 'base\UAvatars.pas',
  ULyrics in 'base\ULyrics.pas',
  UEditorLyrics     in 'base\UEditorLyrics.pas',
  UDraw in 'base\UDraw.pas',
  UParty in 'base\UParty.pas',

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

  //---------------------------------
  // Midi stuff

  // --------

  UMidiNote in 'midi_input\UMidiNote.pas',

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

UJoystick         in 'base\UJoystick.pas',

   //------------------------------
  //Includes - Media
  //------------------------------


  URingBuffer       in 'base\URingBuffer.pas',
   UMediaCore_SDL         in 'media\UMediaCore_SDL.pas',

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

  //Additional option screens
  UScreenOptionsSoundfont in 'midi_input\UScreenOptionsSoundfont.pas',



  //BassMIDI                in 'lib\bassmidi\bassmidi.pas',

  UMenuStaticList in 'menu\UMenuStaticList.pas',




  UPartyTournament              in 'base\UPartyTournament.pas',
  UScreenPartyTournamentRounds  in 'screens\UScreenPartyTournamentRounds.pas',
  UScreenPartyTournamentPlayer  in 'screens\UScreenPartyTournamentPlayer.pas',
  UScreenPartyTournamentOptions in 'screens\UScreenPartyTournamentOptions.pas',
  UScreenPartyTournamentWin     in 'screens\UScreenPartyTournamentWin.pas',
  UScreenJukeboxOptions         in 'screens\UScreenJukeboxOptions.pas',
  UScreenJukeboxPlaylist        in 'screens\UScreenJukeboxPlaylist.pas',



  UScreenOptionsBeatPlay   in 'beatNote\UScreenOptionsBeatPlay.pas',
  UScreenOptionsBeatPlayPeakAnalysis          in 'beatNote\UScreenOptionsBeatPlayPeakAnalysis.pas',
  UScreenOptionsMidiInput          in 'midi_input\UScreenOptionsMidiInput.pas',


  UScreenAbout            in 'screens\UScreenAbout.pas';



var

  gVertexArrayObject: GLuint;
  glVertexBufferObject: GLuint;
  gGraphicsPipelineShaderProgram: GLuint;
  vertexPosition: array [1..9] of GLfloat =
    (-0.8, -0.8, 0.0,
      0.8, -0.8, 0.0,
      0.0, 0.8, 0.0);
  gVertexShaderSource: PAnsiChar =
        '#version 300 es'#13#10+
        'in vec4 position;'#13#10+
        'void main()'#13#10+
        '{'#13#10+
        '   gl_Position = vec4(position);'#13#10+
        '}'#13#10;

  gFragmentShaderSource: PAnsiChar =
        '#version 300 es'#13#10#13#10+
        'precision mediump float;'#13#10#13#10+
        'out vec4 outcolor;'#13#10+
        'void main()'#13#10+
        '{'#13#10+
        '   outcolor = vec4(1.0f, 0.5f, 0.0f, 1.0f);'#13#10+
        '}'#13#10;
  gQuit: boolean;





procedure InitializeProgram();
begin
       SDL_SetHint(SDL_HINT_WINDOWS_DISABLE_THREAD_NAMING, '1');

        //SDL_EnableUnicode(1);  //not necessary in SDL2 any more
       // initialize SDL
       // without SDL_INIT_TIMER SDL_GetTicks() might return strange values


      if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_TIMER)<0 then debug_message_to_android('SDL not loaded');



      SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION,3);
      SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION,0);
      SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK,SDL_GL_CONTEXT_PROFILE_ES);
      SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER,1);

      Screen:=SDL_CreateWindow('USDX',SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,640,480,
      SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL);


      glcontext := SDL_GL_CreateContext(Screen);




      gladLoadGLES2(@SDL_GL_GetProcAddress_wrapper);
end;

procedure VertexSpecification();
begin
      glGenVertexArrays(1,@gVertexArrayObject);
      glBindVertexArray(gVertexArrayObject);
      glGenBuffers(1,@glVertexBufferObject);
      glBindBuffer(GL_ARRAY_BUFFER, glVertexBufferObject);
      glBufferData(GL_ARRAY_BUFFER,
                 (high(vertexPosition)-low(vertexPosition)+1)*sizeof(GLfloat),
                 @vertexPosition,
                 GL_STATIC_DRAW);
      glEnableVertexAttribArray(0);
      glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,0,nil);
      glBindVertexArray(0);
      glDisableVertexAttribArray(0);
end;

function CompileShader(shaderType:GLuint; shadersource: PAnsiChar): GLuint;
var success,logSize: GLint;
    errorLog: PAnsiChar;
begin
    CompileShader:=0;
    if shaderType=GL_VERTEX_SHADER then
     begin
        CompileShader:=glCreateShader(GL_VERTEX_SHADER)
     end
     else if  shaderType = GL_FRAGMENT_SHADER then
     begin
         CompileShader:=glCreateShader(GL_FRAGMENT_SHADER);
     end;
     glShaderSource(CompileShader, 1,@shadersource,nil);
     glCompileShader(CompileShader);

     success := 0;

     glGetShaderiv(CompileShader, GL_COMPILE_STATUS, @success);

     if success = GL_FALSE then
     begin
        debug_message_to_android('Compilation of vertex shader failed');
        logSize := 0;
        glGetShaderiv(CompileShader, GL_INFO_LOG_LENGTH, @logSize);
        // The maxLength includes the NULL character
        GetMem(errorLog, logSize);

        glGetShaderInfoLog(CompileShader, logSize, @logSize, errorLog);
        debug_message_to_android('gl_compilation Error:'+errorLog);

        freemem(errorLog);

     end;



end;



function CreateShaderProgram(vertexshadersource,fragmentshadersource: PAnsiChar): GLuint;
var myVertexShader,
    myFragmentShader: GLuint;
    log_length : GLsizei;
    log: PAnsiChar;

begin
      CreateShaderProgram:=glCreateProgram();
      myVertexShader:=CompileShader(GL_VERTEX_SHADER,vertexshadersource);
      myFragmentShader:=  CompileShader(GL_FRAGMENT_SHADER,fragmentshadersource);
      glAttachShader(CreateShaderProgram,myVertexShader);
      glAttachShader(CreateShaderProgram,myFragmentShader);
      glLinkProgram(CreateShaderProgram);
      GetMem(log,1000);
      glGetProgramInfoLog(CreateShaderProgram, 1000, @log_length, log);
      debug_message_to_android('Compiling gl program: '+log);

      glValidateProgram(CreateShaderProgram);
      glGetProgramInfoLog(CreateShaderProgram, 1000, @log_length, log);
      debug_message_to_android('Valdiating gl program: '+log);

      Freemem(log);


end;

procedure CreateGraphicsPipeline();
begin
  gGraphicsPipelineShaderProgram:=CreateShaderProgram(gVertexShaderSource,gFragmentShaderSource);
end;

procedure SDL_draw_test();
var renderer: PSDL_Renderer = nil;
    r: TSDL_rect;
begin
  // Setup renderer

    renderer :=  SDL_CreateRenderer( Screen, -1, SDL_RENDERER_ACCELERATED);


    // Set render color to red ( background will be rendered in this color )
    SDL_SetRenderDrawColor( renderer, 255, 0, 0, 255 );

    // Clear window
    SDL_RenderClear( renderer );
    SDL_RenderPresent(renderer);

    // Creat a rect at pos ( 50, 50 ) that's 50 pixels wide and 50 pixels high.

    r.x := 50;
    r.y := 50;
    r.w := 50;
    r.h := 50;

    // Set render color to blue ( rect will be rendered in this color )
    SDL_SetRenderDrawColor( renderer, 0, 0, 255, 255 );

    // Render rect
    SDL_RenderFillRect( renderer, @r );

    // Render the rect to the screen
    SDL_RenderPresent(renderer);

    // Wait for 1 sec
    SDL_Delay( 1000 );

    r.x := 100;
    r.y := 100;
    r.w := 50;
    r.h := 50;

    SDL_RenderFillRect( renderer, @r );
    SDL_RenderPresent(renderer);

    SDL_Delay( 1000 );

    r.x := 200;
    r.y := 200;
    r.w := 50;
    r.h := 50;

    SDL_RenderFillRect( renderer, @r );
    SDL_RenderPresent(renderer);


    SDL_Delay(10);
end;

procedure Input();
var e: TSDL_Event;
begin
    while SDL_PollEvent( @e) <> 0 do begin
        if e.type_ = SDL_QUITEV  then begin
           gQuit:=true;
        end;

    end;

end;

procedure PreDraw();
var Disp: TSDL_DisplayMode;
begin

    SDL_GL_MakeCurrent(Screen, glcontext);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);

    SDL_GetDesktopDisplayMode(0, @disp);

    glViewport(0,0,disp.w,disp.h );
    glClearColor(1.0, 1.0, 0.0,1.0);

    glUseProgram(gGraphicsPipelineShaderProgram);

end;

procedure Draw();
begin
    glBindVertexArray(gVertexArrayObject);
    glBindBuffer(GL_ARRAY_BUFFER,glVertexBufferObject);
    glDrawArrays(GL_TRIANGLES,0,3);
end;



procedure MainLoop();
begin
  gQuit:=false;
  while not gQuit do begin
      Input;
      PreDraw;
      Draw;
      SDL_GL_SwapWindow(Screen);
      SDL_Delay(10);

  end;


end;



procedure CleanUp();
begin
   SDL_DestroyWindow(Screen);
   SDL_Quit();
end;


function SDL_main(argc: integer; argv: PPChar): integer;
var index: GLint;
    WindowTitle: string;
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




    SDL_SetHint(SDL_HINT_WINDOWS_DISABLE_THREAD_NAMING, '1');

        //SDL_EnableUnicode(1);  //not necessary in SDL2 any more
       // initialize SDL
       // without SDL_INIT_TIMER SDL_GetTicks() might return strange values


    if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_TIMER)<0 then debug_message_to_android('SDL not loaded');

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

    // add const values:
    Language.AddConst('US_VERSION', USDXVersionStr);


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

    Log.LogStatus('Database System',Platform.GetGameUserPath.Append('Ultrastar.db').ToNative());

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
    Initialize3D(WindowTitle);


      // create luacore first so other classes can register their events


     VertexSpecification;

      CreateGraphicsPipeline;

      SDL_draw_test;

      MainLoop;

      CleanUp;





end;






exports SDL_main name 'SDL_main';
exports JNI_OnLoad name 'JNI_OnLoad';





begin

end.
