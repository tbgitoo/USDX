unit dglOpenGLES;

 {$mode objfpc}

interface



uses
    // LoadLibrary functions
  SysUtils;

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


 const

        gles_lib = 'libGLESv3.so';
        GL_COMPILE_STATUS = $8B81;
        GL_INFO_LOG_LENGTH = $8B84;
        GL_VERTEX_SHADER = $8B31;
        GL_ARRAY_BUFFER = $8892;
        GL_FRAGMENT_SHADER = $8B30;
        GL_FALSE = 0;
        GL_TRUE = 1;
        GL_LINK_STATUS  = $8B82;
        GL_VERSION = $1F02;
        GL_VENDOR = $1F00;
        GL_RENDERER = $1F01;
        GL_EXTENSIONS = $1F03;
        GL_DEPTH_BUFFER_BIT = $00000100;
        GL_COLOR_BUFFER_BIT = $00004000;
        GL_FLOAT = $1406;
        GL_TRIANGLES = $0004;
        GL_STATIC_DRAW = $88E4;




type
  GLenum = Cardinal;
  GLuint = Cardinal;
  PGLuint = ^GLuint;
  GLsizei = Integer;
  PGLsizei = ^GLsizei;
  GLint = Integer;
  PGlint  = ^Glint;
  GLfloat = Single;
  GLbitfield = Cardinal;
  GLboolean = BYTEBOOL;
  GLchar = AnsiChar;
  PGLchar = PAnsiChar;
  PPGLchar = ^PGLChar;

function glGetString(name: GLenum): String;

procedure checkGlError(tag: string);

function glGetError(): GLenum; {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetError';

function glCreateShader (shader_type: GLenum): GLenum; {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCreateShader';

procedure glViewport (x,y: GLint; width, height: GLsizei); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glViewport';


procedure glClearColor(red, green, blue, alpha: GLfloat); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glClearColor';

procedure glClear (mask: GLbitfield); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glClear';

procedure glUseProgram(prog: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glUseProgram';

procedure glVertexAttribPointer(index: GLuint; size: GLint; typeA: GLenum; normalized: GLboolean; stride: GLsizei; pt: Pointer); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glVertexAttribPointer';

procedure glEnableVertexAttribArray (index: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glEnableVertexAttribArray';

procedure glDrawArrays(mode: GLenum; first: GLint; count: GLsizei); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDrawArrays';

function loadShader(shaderType: GLenum; sourceCode: String): GLuint;

function createProgram(vertexSource, fragmentSource: String): GLuint;

function glGetAttribLocation(prog: GLuint; name: String): GLint;

procedure printGLString(name: String; s: GLenum);

procedure glGenVertexArrays (n: GLsizei; arrays: PGLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGenVertexArrays';

procedure glBindVertexArray(array_ : GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBindVertexArray';

procedure glGenBuffers (n: GLsizei; buffers: PGLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGenBuffers';

procedure glBindBuffer(target: GLenum; array_ : GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBindBuffer';

procedure glBufferData (target: GLenum; size_:GLsizei; data: Pointer; usage: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBufferData';

implementation

{$IF Defined(ANDROID)}
uses

      UJniCallback;
{$IFEND}




// Internal call to gl function for glGetString
function __glGetString(name: GLenum): PAnsiChar; {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetString';



procedure __glShaderSource (shader: GLuint; count: GLsizei;  source_code_string_array: PPGLChar; length_array: pglint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glShaderSource';

procedure __glCompileShader(shader: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCompileShader';

procedure __glGetShaderiv (shader: GLuint; pname: GLenum; params: PGLint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetShaderiv';

procedure __glGetShaderInfoLog(shader: GLuint; bufSize: GLsizei; length:PGLsizei; infoLog: PByte); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetShaderInfoLog';

procedure __glDeleteShader(shader: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDeleteShader';

function glCreateProgram(): GLuint;  {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCreateProgram';

procedure __glAttachShader(prog,shader: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glAttachShader';

procedure __glLinkProgram (prog: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glLinkProgram';

procedure __glGetProgramiv(prog: GLuint; pname: GLenum; params: PGLint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetProgramiv';

procedure __glGetProgramInfoLog(prog: GLuint; bufSize: GLsizei ; len: PGLsizei; infoLog: PByte); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetProgramInfoLog';

procedure __glDeleteProgram(prog: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDeleteProgram';



function __glGetAttribLocation(prog: GLuint; name: PGLChar): GLint; {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetAttribLocation';



// Don't forget FreeMem(Buffer,Length(s) + 1) once you're done with the buffer returned
// by this function
function PCharFromString(s: string): PChar;
begin
    PCharFromString:=PChar(GetMem(Length(s) + 1));
    Move(s[1], PCharFromString[0], Length(s) + 1);
    PCharFromString[Length(s)]:=#0;
end;





procedure printGLString(name: String; s: GLenum);
var
  v : String;
begin
    v:=glGetString(s);
    {$IF Defined(ANDROID)}
      debug_message_to_android('GL '+name+' = '+v);
    {$IFEND}
  end;


function glGetString(name: GLenum): String;
begin
   glGetString:=__glGetString(name);
end;

procedure checkGlError(tag: string);
var theError:  GLint;
begin
  theError:=glGetError();
  while(theError <> 0) do begin
      {$IF Defined(ANDROID)}
      debug_message_to_android(tag+' got GL error number '+IntToStr(theError));
      {$IFEND}
      theError:=glGetError();
  end;

end;


function glGetAttribLocation(prog: GLuint; name: String): GLint;

var
  Buffer: PGLchar;
  ind: integer;
begin
  Buffer:=PCharFromString(name);

   glGetAttribLocation:=__glGetAttribLocation(prog, Buffer);
   FreeMem(Buffer,Length(name) + 1);
end;


function loadShader(shaderType: GLenum; sourceCode: String): GLuint;
var

  Buffer: PGLchar;

  retBuffer: array of Byte;
  ind: integer;
  compiled: GLint;
  shader: GLUint;
  infoLen: GLint;

begin


  shader:=glCreateShader(shaderType);

  if shader>0 then begin


    Buffer:= PCharFromString(sourceCode);
   __glShaderSource(shader, 1, @Buffer, nil);
   __glCompileShader(shader);


   compiled := 0;
   __glGetShaderiv(shader, GL_COMPILE_STATUS, @compiled);

   if compiled = 0 then begin

     infoLen:=0;
     __glGetShaderiv(shader, GL_INFO_LOG_LENGTH, @infoLen);
     if (infoLen>0) then begin
       setLength(retBuffer,infoLen);
       __glGetShaderInfoLog(shader, infoLen, nil, @retBuffer[0]);
       {$IF Defined(ANDROID)}
      debug_message_to_android(String(TEncoding.ANSI.GetString(retBuffer)));
      {$IFEND}
       setLength(retBuffer,0);
      __glDeleteShader(shader);
      shader := 0;
     end;
   end;
   FreeMem(Buffer,Length(sourceCode) + 1);
  end;
  loadShader:=shader;
end;


function createProgram(vertexSource, fragmentSource: String): GLuint;
var
  vertexShader,pixelShader,prog: GLuint;
  linkStatus, bufLength: GLint;
  buf: array of byte;
begin
  vertexShader := loadShader(GL_VERTEX_SHADER, vertexSource);


  if (vertexShader = 0) then exit(0);


  pixelShader := loadShader(GL_FRAGMENT_SHADER, fragmentSource);


  if (pixelShader =0) then exit(0);

  prog := glCreateProgram();
  if (prog <> 0) then begin
    __glAttachShader(prog, vertexShader);
    checkGlError('glAttachShader');
    __glAttachShader(prog, pixelShader);
    checkGlError('glAttachShader');
    __glLinkProgram(prog);
    linkStatus := GL_FALSE;
    __glGetProgramiv(prog, GL_LINK_STATUS, @linkStatus);
    if (linkStatus <> GL_TRUE) then begin
      bufLength := 0;
      __glGetProgramiv(prog, GL_INFO_LOG_LENGTH, @bufLength);
      if (bufLength > 0) then begin
       setLength(buf,bufLength);
       __glGetProgramInfoLog(prog, bufLength, nil, @buf[0]);
       {$IF Defined(ANDROID)}
      debug_message_to_android('Could not link program, error='+String(TEncoding.ANSI.GetString(buf)));
      {$IFEND}
       setlength(buf,0);

      end;
      __glDeleteProgram(prog);
      prog := 0;
  end;
end;

  createProgram:=prog;




end;













end.

