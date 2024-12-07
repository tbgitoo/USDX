

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
  UThemes in 'base\UThemes.pas',
  ULanguage in 'base\ULanguage.pas',






  {$IFDEF UseOpenCVWrapper}
  opencv_highgui          in 'lib\openCV3\opencv_highgui.pas',
  opencv_core             in 'lib\openCV3\opencv_core.pas',
  opencv_imgproc          in 'lib\openCV3\opencv_imgproc.pas',
  opencv_types            in 'lib\openCV3\opencv_types.pas';
{$ELSE}
  opencv_highgui          in 'lib\openCV\opencv_highgui.pas',
  opencv_core             in 'lib\openCV\opencv_core.pas',
  opencv_imgproc          in 'lib\openCV\opencv_imgproc.pas',
  opencv_types            in 'lib\openCV\opencv_types.pas';
{$ENDIF}

  //Amidi in 'lib\amidi\amidi.pas',
  //UFluidSynth in 'lib\fluidsynth\UFluidSynth.pas',
  //pasfluidsynth_android in 'lib\fluidsynth\pasfluidsynth_android.pas',
  //UMidiInputStream in 'midi_input\UMidiInputStream.pas',
  //UMidiTransfer in 'midi_input\UMidiTransfer.pas',
  //UIni in 'base\UIni.pas',
  //UMusic in 'base\UMusic.pas',


  //UDataBase in 'base\UDataBase.pas',
  //UFiles in 'base\UFiles.pas',
  //UDllManager in 'base\UDLLManager.pas';

  //UWebcam in 'base\UWebcam.pas',
  //ULanguage in 'base\ULanguage.pas',















var    window: PSDL_Window;
  maincontext: TSDL_GLContext;
  mode: TSDL_DisplayMode;
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





function SDL_GL_GetProcAddress_wrapper(load: PAnsiChar): Pointer;
begin
   SDL_GL_GetProcAddress_wrapper:=SDL_GL_GetProcAddress(load);

end;

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

      window:=SDL_CreateWindow('USDX',SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,640,480,
      SDL_WINDOW_SHOWN or SDL_WINDOW_OPENGL);


      maincontext := SDL_GL_CreateContext(window);

      SDL_GetDesktopDisplayMode(0, @mode);


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

    renderer :=  SDL_CreateRenderer( window, -1, SDL_RENDERER_ACCELERATED);


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
begin

    SDL_GL_MakeCurrent(window, maincontext);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);

    glViewport(0,0,mode.w,mode.h );
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
      SDL_GL_SwapWindow(window);
      SDL_Delay(10);

  end;


end;



procedure CleanUp();
begin
   SDL_DestroyWindow(window);
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


     Platform.init;
     InitializePaths;

     // Commandline Parameter Parser
    Params := TCMDParams.Create;

    // fix floating-point exceptions (FPE)
    DisableFloatingPointExceptions();

    // fix the locale for string-to-float parsing in C-libs
    SetDefaultNumericLocale();

        // setup separators for parsing
    // Note: ThousandSeparator must be set because of a bug in TIniFile.ReadFloat
    DefaultFormatSettings.ThousandSeparator := ',';
    DefaultFormatSettings.DecimalSeparator := '.';




     InitializeProgram;

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
