 {$mode objfpc}
unit dglOpenGLES;



interface



uses
    // LoadLibrary functions
  SysUtils,SDL3;

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


 const
        // Proper opengles constants
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
        GL_TEXTURE_2D = $0DE1;
        GL_TEXTURE_MAG_FILTER = $2800;
        GL_LINEAR = $2601;
        GL_TEXTURE_MIN_FILTER = $2801;
        GL_UNSIGNED_BYTE = $1401;
        GL_NO_ERROR = 0;
        GL_SRC_ALPHA = $0302;
        GL_ONE_MINUS_SRC_ALPHA = $0303;
        GL_BLEND = $0BE2;
        GL_DEPTH_TEST = $0B71;
        GL_PACK_ALIGNMENT = $0D05;
        GL_RGB = $1907;
        GL_TEXTURE_WRAP_S=$2802;
        GL_CLAMP_TO_EDGE=$812F;
        GL_TEXTURE_WRAP_T=$2803;
        GL_VIEWPORT = $0BA2;
        GL_LEQUAL = $0203;
        GL_UNPACK_ALIGNMENT = $0CF5;
        GL_ALPHA = $1906;
        GL_SCISSOR_TEST = $0C11;
        GL_LINES = $0001;
        GL_LINE_LOOP  = $0002;
        GL_UNPACK_ROW_LENGTH=$0CF2;
        GL_RGBA=$1908;


        // Re-implementation of functionality dropped from opengles
        GL_QUADS = $0007;
        GL_TEXTURE_ENV_MODE = $2200;
        GL_TEXTURE_ENV_COLOR = $2201;
        GL_TEXTURE_ENV = $2300;

        GL_REPLACE = $1E01;
        GL_MODULATE = $2100;

        GL_LINE_STRIP = $0003;

        GL_REPEAT = $2901;

        GL_MODELVIEW = $1700;

        GL_CLIP_PLANE0 = $3000;

        // GL_ARB_pixel_buffer_object
  GL_PIXEL_PACK_BUFFER_ARB = $88EB;
  GL_PIXEL_UNPACK_BUFFER_ARB = $88EC;
  GL_PIXEL_PACK_BUFFER_BINDING_ARB = $88ED;
  GL_PIXEL_UNPACK_BUFFER_BINDING_ARB = $88EF;

  // GL_ARB_depth_buffer_float
  GL_DEPTH_COMPONENT32F = $8CAC;
  GL_DEPTH32F_STENCIL8 = $8CAD;
  GL_FLOAT_32_UNSIGNED_INT_24_8_REV = $8DAD;

  // GL_ARB_vertex_buffer_object
  GL_BUFFER_SIZE_ARB = $8764;
  GL_BUFFER_USAGE_ARB = $8765;
  GL_ARRAY_BUFFER_ARB = $8892;
  GL_ELEMENT_ARRAY_BUFFER_ARB = $8893;
  GL_ARRAY_BUFFER_BINDING_ARB = $8894;
  GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB = $8895;
  GL_VERTEX_ARRAY_BUFFER_BINDING_ARB = $8896;
  GL_NORMAL_ARRAY_BUFFER_BINDING_ARB = $8897;
  GL_COLOR_ARRAY_BUFFER_BINDING_ARB = $8898;
  GL_INDEX_ARRAY_BUFFER_BINDING_ARB = $8899;
  GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB = $889A;
  GL_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB = $889B;
  GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB = $889C;
  GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB = $889D;
  GL_WEIGHT_ARRAY_BUFFER_BINDING_ARB = $889E;
  GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB = $889F;
  GL_READ_ONLY_ARB = $88B8;
  GL_WRITE_ONLY_ARB = $88B9;
  GL_READ_WRITE_ARB = $88BA;
  GL_BUFFER_ACCESS_ARB = $88BB;
  GL_BUFFER_MAPPED_ARB = $88BC;
  GL_BUFFER_MAP_POINTER_ARB = $88BD;
  GL_STREAM_DRAW_ARB = $88E0;
  GL_STREAM_READ_ARB = $88E1;
  GL_STREAM_COPY_ARB = $88E2;
  GL_STATIC_DRAW_ARB = $88E4;
  GL_STATIC_READ_ARB = $88E5;
  GL_STATIC_COPY_ARB = $88E6;
  GL_DYNAMIC_DRAW_ARB = $88E8;
  GL_DYNAMIC_READ_ARB = $88E9;
  GL_DYNAMIC_COPY_ARB = $88EA;






type
  GLenum = Cardinal;
  GLuint = Cardinal;
  PGLuint = ^GLuint;
  GLsizei = Integer;
  PGLsizei = ^GLsizei;
  GLint = Integer;
  PGlint  = ^Glint;
  GLfloat = Single;
  PGLfloat = ^GLfloat;
  GLbitfield = Cardinal;
  GLboolean = BYTEBOOL;
  GLchar = AnsiChar;
  PGLchar = PAnsiChar;
  PPGLchar = ^PGLChar;
  GLubyte = Byte;

  // Extra stuff not implemented in OpenGLES anymore

  TGLMatrixf4  = array[0..3, 0..3] of GLfloat;

  TGLVectori4  = array[0..3] of GLint;

  GLsizeiptrARB = GLsizei;

  PGLvoid = Pointer;

  GLshort = SmallInt;
  GLdouble = Double;
  PGLdouble = ^GLdouble;

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


function createProgram(vertexSource, fragmentSource: String): GLuint;

function glGetAttribLocation(prog: GLuint; name: String): GLint;

procedure printGLString(name: String; s: GLenum);

procedure glGenVertexArrays (n: GLsizei; arrays: PGLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGenVertexArrays';

procedure glBindVertexArray(array_ : GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBindVertexArray';

procedure glGenBuffers (n: GLsizei; buffers: PGLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGenBuffers';

procedure glBindBuffer(target: GLenum; array_ : GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBindBuffer';

procedure glBufferData (target: GLenum; size_:GLsizei; data: Pointer; usage: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBufferData';


procedure glShaderSource (shader: GLuint; count: GLsizei;  source_code_string_array: PPGLChar; length_array: pglint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glShaderSource';

procedure glCompileShader(shader: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCompileShader';


procedure glGetShaderiv (shader: GLuint; pname: GLenum; params: PGLint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetShaderiv';

function loadShader(shaderType: GLenum; sourceCode: String): GLuint;

function PCharFromString(s: string): PChar;

function glCreateProgram(): GLuint;  {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCreateProgram';

procedure glAttachShader(prog,shader: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glAttachShader';


procedure glLinkProgram (prog: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glLinkProgram';


procedure glGetProgramiv(prog: GLuint; pname: GLenum; params: PGLint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetProgramiv';

procedure glGetProgramInfoLog(prog: GLuint; bufSize: GLsizei ; len: PGLsizei; infoLog: PByte); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetProgramInfoLog';

procedure glDeleteProgram(prog: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDeleteProgram';


procedure glDeleteShader(shader: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDeleteShader';

procedure glGenTextures (n:GLsizei; textures: PGLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGenTextures';

procedure glDeleteTextures (n:GLsizei; textures: PGLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDeleteTextures';

procedure glBindTexture (target: GLenum; texture: GLuint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBindTexture';

procedure glTexParameteri (target: GLenum; pname: GLenum; param: GLint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glTexParameteri';

procedure glTexImage2D (target: GLenum; level,internalformat: GLint; width,height: GLsizei; border: GLint; format,type_: GLenum; pixels: pointer); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glTexImage2D';

procedure glCopyTexSubImage2D (target: GLenum; level, xoffset, yoffset, x, y: GLint; width,height: GLsizei); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCopyTexSubImage2D';

procedure glEnable (cap: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glEnable';

procedure glBlendFunc (sfactor, dfactor: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glBlendFunc';

procedure glDisable (cap: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDisable';

procedure glGetIntegerv (pname: GLenum; data: PGlint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetIntegerv';

procedure glReadPixels (x,y: GLint; widht, height: GLsizei; format,type_: GLenum; pixels: pointer); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glReadPixels';


procedure glTexSubImage2D (target: GLenum; level,xoffset,yoffset: GLint; width,height: GLsizei; format,type_: GLenum;pixels: pointer); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glTexSubImage2D';

procedure glGetFloatv (pname: GLenum; data: PGLfloat); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetFloatv';

procedure glPixelStorei (pname: GLenum; param: GLint); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glPixelStorei';

procedure glDepthRangef (n,f: GLfloat);  {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDepthRangef';

procedure glDepthFunc (func: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glDepthFunc';


procedure glScissor (x,y: GLint; width,height: GLsizei); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glScissor';

procedure glLineWidth (width: GLfloat); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glLineWidth';

procedure glTexParameterf (target,pname: GLenum; param:GLfloat); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glTexParameterf';

procedure glCullFace(mode: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glCullFace';

procedure glFinish (); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glFinish';
procedure glFlush (); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glFlush';

procedure glFrontFace (mode: GLenum); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glFrontFace';

// Exta functions

procedure draw_rectangle_quads_opengles(left: GLFloat; top: GLFloat; right: GLFloat; bottom: GLFloat;
  tx1: GLfloat; ty1: GLfloat; tx2: GLFloat; ty2: GLFloat; tex_num: GLenum);

procedure draw_rectangle_quads_opengles_color(left: GLFloat; top: GLFloat; right: GLFloat; bottom: GLFloat;
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4: GLFloat;
  tx1: GLfloat; ty1: GLfloat; tx2: GLFloat; ty2: GLFloat; tex_num: GLenum);

procedure draw_quads_opengles_z(x1,y1,x2,y2,x3,y3,x4,y4, z: GLFloat;
  tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4: GLFloat; tex_num:  GLenum);


procedure draw_quads_opengles_z_color(x1,y1,z1,x2,y2,z2,
  x3,y3,z3,x4,y4, z4: GLFloat;
  tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4: GLFloat;
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4: GLFloat;
  tex_num:  GLenum);

procedure draw_quads_opengles_color(x1,y1,x2,y2,
  x3,y3,x4,y4: GLFloat;
  tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4: GLFloat;
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4: GLFloat;
  tex_num:  GLenum);


function setupGraphicsAndroid: boolean;

function openGLESexampleProgram: boolean;

procedure openGLESexampleProgramRenderFrame();

// Procedure to be re-implemented because they were dropped from openGLES

procedure glColor4f(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);

procedure glbegin(mode: GLenum);

procedure glEnd();

procedure glVertex2f(x,y: GLfloat);

procedure glColor3f(red,green,blue: GLfloat);

procedure glTexEnvf(target: GLenum; pname: GLenum; param: GLfloat);

procedure glTexCoord2f(s: GLfloat; t: GLfloat);

procedure glTexEnvi(target: GLenum; pname: GLenum; param: GLint);

procedure glVertex3f (x: GLfloat; y: GLfloat; z: GLfloat);

procedure glGenBuffersARB(n: GLsizei; buffers: PGLuint);

procedure glBindBufferARB(target: GLenum; buffer: GLuint);

procedure glDeleteBuffersARB (n: GLsizei; const buffers: PGLuint);


procedure glBufferDataARB(target: GLenum; size: GLsizeiptrARB; const data: PGLvoid; usage: GLenum);

function glMapBufferARB (target: GLenum; access: GLenum): PGLvoid;

function glUnmapBufferARB (target: GLenum): GLboolean;

procedure glDepthRange (n,f: GLfloat);

procedure glMatrixMode (mode: GLenum);

procedure glPushMatrix();

procedure glTranslatef(x: GLfloat; y: GLfloat; z: GLfloat);

procedure glScalef(x: GLfloat; y: GLfloat; z: GLfloat);

procedure glVertex2s(x: GLshort; y: GLshort);

procedure glPopMatrix();


procedure glClipPlane(plane: GLenum; const equation: PGLdouble);

procedure glClearAccum(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);

procedure glColor3d(red: GLdouble; green: GLdouble; blue: GLdouble);
procedure glColor4d(red: GLdouble; green: GLdouble; blue: GLdouble; alpha: GLdouble);

procedure glDisableClientState(_array: GLenum);

procedure glDrawBuffer(mode: GLenum);

procedure glEnableClientState(_array: GLenum);

procedure glEndList();

procedure glInitNames();

procedure glLoadIdentity();

procedure glLogicOp(opcode: GLenum);

var

  Screen: PSDL_Window;




implementation

{$IF Defined(ANDROID)}
uses

      UJniCallback;
{$IFEND}

var
  actualScreen: TSDL_Window;  // To ensure persistance of the data behind PDSL_Window
  sdl_wait_event: TSDL_Event;  // This can't be local, otherwise we get a segmentation fault
  glesContext: TSDL_GLContext;  // This too has to be persistent
  screenSurface: PSDL_Surface;  // For accessing the native surace
  shader_fragments : array of PGLChar = ();  // to guarantee the persistence of the shader code


  // This is a bit more experimental stuff
  gvPositionHandle, gProgram: GLuint;
  grey: GLfloat;
  gTriangleVertices: array[0..5] of GLfloat = (0.0, 0.5, -0.5, -0.5, 0.5, -0.5);



// Internal call to gl function for glGetString
function __glGetString(name: GLenum): PAnsiChar; {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetString';






procedure __glGetShaderInfoLog(shader: GLuint; bufSize: GLsizei; length:PGLsizei; infoLog: PByte); {$IFDEF WINDOWS}stdcall; {$ELSE}cdecl; {$ENDIF} external gles_lib name 'glGetShaderInfoLog';









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

  retBuffer: array of Byte;
  ind: integer;
  compiled: GLint;
  shader: GLUint;
  infoLen: GLint;
  length_for_length_array: GLint;

begin
  setLength(shader_fragments,length(shader_fragments)+1);

  shader_fragments[length(shader_fragments)]:=PCharFromString(sourceCode);

  shader:=glCreateShader(shaderType);

  if shader>0 then begin

  length_for_length_array:=length(sourceCode);

   glShaderSource(shader, 1, PPGLchar(@shader_fragments[length(shader_fragments)]), @length_for_length_array);
   glCompileShader(shader);


   compiled := 0;
   glGetShaderiv(shader, GL_COMPILE_STATUS, @compiled);

   if compiled = 0 then begin
     {$IF Defined(ANDROID)}
      debug_message_to_android('Compilation of shader failed: '+sourceCode);
      {$IFEND}
     infoLen:=0;
     glGetShaderiv(shader, GL_INFO_LOG_LENGTH, @infoLen);
     if (infoLen>0) then begin
       setLength(retBuffer,infoLen);
       __glGetShaderInfoLog(shader, infoLen, nil, @retBuffer[0]);
       {$IF Defined(ANDROID)}
      debug_message_to_android(String(TEncoding.ANSI.GetString(retBuffer)));
      {$IFEND}

      glDeleteShader(shader);
      shader := 0;
     end;
   end;

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
    glAttachShader(prog, vertexShader);
    checkGlError('glAttachShader');
    glAttachShader(prog, pixelShader);
    checkGlError('glAttachShader');
    glLinkProgram(prog);
    linkStatus := GL_FALSE;
    glGetProgramiv(prog, GL_LINK_STATUS, @linkStatus);
    if (linkStatus <> GL_TRUE) then begin
      bufLength := 0;
      glGetProgramiv(prog, GL_INFO_LOG_LENGTH, @bufLength);
      if (bufLength > 0) then begin
       setLength(buf,bufLength);
       glGetProgramInfoLog(prog, bufLength, nil, @buf[0]);
       {$IF Defined(ANDROID)}
      debug_message_to_android('Could not link program, error='+String(TEncoding.ANSI.GetString(buf)));
      {$IFEND}
       setlength(buf,0);

      end;
      glDeleteProgram(prog);
      prog := 0;
  end;
end;

  createProgram:=prog;







end;



function setupGraphicsAndroid: boolean;
    var

    displayID: TSDL_DisplayID;
    displayMode: TSDL_DisplayMode;


    go_on: boolean;


begin



  if(SDL_Init(SDL_INIT_VIDEO)<0) then begin
    debug_message_to_android('Failed to launch SDL');
    exit(false);
  end;

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
   SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK,    SDL_GL_CONTEXT_PROFILE_ES);
   SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
   SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
   SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL,1);

   displayID:=SDL_GetPrimaryDisplay();
   displayMode:=SDL_GetCurrentDisplayMode(displayID)^;



   debug_message_to_android('Detected display w='+IntToStr(displayMode.w)+' h='+IntToStr(displayMode.h));


    // Create our window centered at display resolution
    Screen := SDL_CreateWindow('title',displayMode.w, displayMode.h, SDL_WINDOW_OPENGL or SDL_WINDOW_SHOWN or SDL_WINDOW_FULLSCREEN);
    if Screen=nil then begin
        debug_message_to_android('Could not create window.');
        exit(false);
        end;

    actualScreen:=Screen^;

    screenSurface := SDL_GetWindowSurface( Screen );
    if(screenSurface=nil) then begin
        debug_message_to_android('Could not get screen surface');
        exit(false);
        end;

    debug_message_to_android('drawing surface w='+IntToStr((screenSurface^).w)+' h='+IntToStr((screenSurface^).h));


    go_on:=false;

    while ((SDL_WaitEvent(@sdl_wait_event) <> 0) and not go_on) do begin

       if(sdl_wait_event.type_ and SDL_WINDOWEVENT > 0) then begin
          go_on:=true;
          end;
    end;

    glesContext := SDL_GL_CreateContext(Screen);
    if(glesContext=nil) then begin
       debug_message_to_android('could not create GL context: '+SDL_GetError());
       exit(false);
       end;

    glViewport(0, 0, displayMode.w, displayMode.h);


    printGLString('Version', GL_VERSION);
    printGLString('Vendor', GL_VENDOR);
    printGLString('Renderer', GL_RENDERER);
    printGLString('Extensions', GL_EXTENSIONS);

    SDL_GL_SetSwapInterval(1);

   setupGraphicsAndroid:=true;






    end;



   function openGLESexampleProgram: boolean;
    var gVertexShader, gFragmentShader : String;
    begin


      gVertexShader:='attribute vec4 vPosition; '+
        'void main() { '+
        '  gl_Position = vPosition; '+
        '} ';


      gFragmentShader :=
        'precision mediump float; '+
        'void main() { '+
        '  gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0); '+
        '} ';

      gProgram := createProgram(gVertexShader, gFragmentShader);
      if gProgram = 0 then begin
      {$IF Defined(ANDROID)}
          debug_message_to_android('Could not create program.');
      {$IFEND}
       exit(False);
       end;
      gvPositionHandle := glGetAttribLocation(gProgram, 'vPosition');
      checkGlError('glGetAttribLocation');


      openGLESexampleProgram:=True;
    end;


procedure openGLESexampleProgramRenderFrame();
begin
  grey := grey+0.01;
  if grey > 1 then grey:=0;

  glClearColor(grey, grey, grey, 1.0);
  checkGlError('glClearColor');
  glClear(GL_DEPTH_BUFFER_BIT + GL_COLOR_BUFFER_BIT);
  checkGlError('glClear');
  glUseProgram(gProgram);
  checkGlError('glUseProgram');

  glVertexAttribPointer(gvPositionHandle, 2, GL_FLOAT, Bytebool(GL_FALSE), 0,
                        @gTriangleVertices[0]);
  checkGlError('glVertexAttribPointer');
  glEnableVertexAttribArray(gvPositionHandle);
  checkGlError('glEnableVertexAttribArray');
  glDrawArrays(GL_TRIANGLES, 0, 3);
  checkGlError('glDrawArrays');
end;


procedure glColor4f(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
begin

end;

procedure glbegin(mode: GLenum);
begin

end;


procedure glEnd();
begin

end;


procedure glVertex2f(x,y: GLfloat);
begin

end;

procedure glColor3f(red,green,blue: GLfloat);
begin

end;

procedure glTexEnvf(target: GLenum; pname: GLenum; param: GLfloat);
begin

end;

procedure glTexCoord2f(s: GLfloat; t: GLfloat);
begin

end;

procedure glTexEnvi(target: GLenum; pname: GLenum; param: GLint);
begin

end;

procedure glVertex3f (x: GLfloat; y: GLfloat; z: GLfloat);
begin

end;

procedure glGenBuffersARB(n: GLsizei; buffers: PGLuint);
begin

end;

procedure glBindBufferARB(target: GLenum; buffer: GLuint);
begin

end;

procedure glDeleteBuffersARB (n: GLsizei; const buffers: PGLuint);
begin

end;

procedure glBufferDataARB(target: GLenum; size: GLsizeiptrARB; const data: PGLvoid; usage: GLenum);
begin

end;

function glMapBufferARB (target: GLenum; access: GLenum): PGLvoid;
begin
  glMapBufferARB:=nil;
end;

function glUnmapBufferARB (target: GLenum): GLboolean;
begin
  glUnmapBufferARB:=True;
end;

procedure glDepthRange (n,f: GLfloat);
begin
  glDepthRangef(n,f);
end;


procedure glMatrixMode (mode: GLenum);
begin

end;

procedure glPushMatrix();
begin

end;

procedure glTranslatef(x: GLfloat; y: GLfloat; z: GLfloat);
begin

end;

procedure glScalef(x: GLfloat; y: GLfloat; z: GLfloat);
begin

end;

procedure glVertex2s(x: GLshort; y: GLshort);
begin

end;

procedure glPopMatrix();
begin

end;


procedure glClipPlane(plane: GLenum; const equation: PGLdouble);
begin

end;

procedure glClearAccum(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
begin

end;

procedure glColor3d(red: GLdouble; green: GLdouble; blue: GLdouble);
begin

end;

procedure glColor4d(red: GLdouble; green: GLdouble; blue: GLdouble; alpha: GLdouble);
begin
   glColor4d(red,green,blue,alpha);
end;

procedure glDisableClientState(_array: GLenum);
begin

end;

procedure glDrawBuffer(mode: GLenum);
begin

end;

procedure glEnableClientState(_array: GLenum);
begin

end;

procedure glEndList();
begin

end;

procedure glInitNames();
begin

end;

procedure glLoadIdentity();
begin

end;

procedure glLogicOp(opcode: GLenum);
begin

end;

procedure draw_rectangle_quads_opengles(left: GLFloat; top: GLFloat; right: GLFloat; bottom: GLFloat;
  tx1: GLfloat; ty1: GLfloat; tx2: GLFloat; ty2: GLFloat; tex_num: GLenum);
var
  vertex_coords: array[0..7] of GLfloat;
  texcoords: array[0..7] of GLfloat;
begin

  {vertex_coords[0]:=left;  vertex_coords[1]:=top;
  vertex_coords[2]:=left;  vertex_coords[3]:=bottom;
  vertex_coords[4]:=right;  vertex_coords[5]:=bottom;
  vertex_coords[6]:=right;  vertex_coords[7]:=top;

  texcoords[0]:=tx1; texcoords[1]:=ty1;
  texcoords[2]:=tx1; texcoords[3]:=ty2;
  texcoords[4]:=tx2; texcoords[5]:=ty2;
  texcoords[6]:=tx2; texcoords[7]:=ty1;
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glVertexPointer(2, GL_FLOAT, 0, @vertex_coords[0]);
  glClientActiveTexture(GL_TEXTURE0 + tex_num);
  glTexCoordPointer(2, GL_FLOAT, 0, @texcoords[0]);
  //glDisableVertexAttribArray(0);

  glDrawArrays(GL_TRIANGLE_FAN,0,4);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);   }

  end;


procedure draw_rectangle_quads_opengles_color(left: GLFloat; top: GLFloat; right: GLFloat; bottom: GLFloat;
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4: GLFloat;
  tx1: GLfloat; ty1: GLfloat; tx2: GLFloat; ty2: GLFloat; tex_num: GLenum);
begin
  draw_quads_opengles_color(left,top,right,top,
  right,bottom,left,bottom,tx1,ty1,tx2,ty1,tx2,ty2,tx1,ty2,
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4,
  tex_num);
end;

procedure draw_quads_opengles_z(x1,y1,x2,y2,x3,y3,x4,y4, z: GLFloat;
  tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4: GLFloat; tex_num:  GLenum);
var
  vertex_coords: array[0..11] of GLfloat;
  texcoords: array[0..7] of GLfloat;
begin

  {vertex_coords[0]:=x1;  vertex_coords[1]:=y1; vertex_coords[2]:=z;
  vertex_coords[3]:=x2;  vertex_coords[4]:=y2; vertex_coords[5]:=z;
  vertex_coords[6]:=x3;  vertex_coords[7]:=y3; vertex_coords[8]:=z;
  vertex_coords[9]:=x4;  vertex_coords[10]:=y4; vertex_coords[11]:=z;

  texcoords[0]:=tx1; texcoords[1]:=ty1;
  texcoords[2]:=tx2; texcoords[3]:=ty2;
  texcoords[4]:=tx3; texcoords[5]:=ty3;
  texcoords[6]:=tx4; texcoords[7]:=ty4;
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, @vertex_coords[0]);
  glClientActiveTexture(GL_TEXTURE0 + tex_num);
  glTexCoordPointer(2, GL_FLOAT, 0, @texcoords[0]);
  //glDisableVertexAttribArray(0);

  glDrawArrays(GL_TRIANGLE_FAN,0,4);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY); }

  end;


procedure draw_quads_opengles_z_color(x1,y1,z1,x2,y2,z2,
  x3,y3,z3,x4,y4, z4: GLFloat;
  tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4: GLFloat;
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4: GLFloat;
  tex_num:  GLenum);
var
  vertex_coords: array[0..11] of GLfloat;
  color_coords: array[0..15] of GLfloat;
  texcoords: array[0..7] of GLfloat;
begin

  {vertex_coords[0]:=x1;  vertex_coords[1]:=y1; vertex_coords[2]:=z1;
  vertex_coords[3]:=x2;  vertex_coords[4]:=y2; vertex_coords[5]:=z2;
  vertex_coords[6]:=x3;  vertex_coords[7]:=y3; vertex_coords[8]:=z3;
  vertex_coords[9]:=x4;  vertex_coords[10]:=y4; vertex_coords[11]:=z4;

  texcoords[0]:=tx1; texcoords[1]:=ty1;
  texcoords[2]:=tx2; texcoords[3]:=ty2;
  texcoords[4]:=tx3; texcoords[5]:=ty3;
  texcoords[6]:=tx4; texcoords[7]:=ty4;

  color_coords[0]:=r1;  color_coords[1]:=g1; color_coords[2]:=b1; color_coords[3]:=alpha1;
  color_coords[4]:=r2;  color_coords[5]:=g2; color_coords[6]:=b2; color_coords[7]:=alpha2;
  color_coords[8]:=r3;  color_coords[9]:=g3; color_coords[10]:=b3; color_coords[11]:=alpha3;
  color_coords[12]:=r4;  color_coords[13]:=g4; color_coords[14]:=b4; color_coords[15]:=alpha4;

  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, @vertex_coords[0]);
  glClientActiveTexture(GL_TEXTURE0 + tex_num);
  glTexCoordPointer(2, GL_FLOAT, 0, @texcoords[0]);
  glColorPointer(4, GL_FLOAT, 0, @color_coords[0]);
  //glDisableVertexAttribArray(0);

  glDrawArrays(GL_TRIANGLE_FAN,0,4);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);  }

  end;

procedure draw_quads_opengles_color(x1,y1,x2,y2,
  x3,y3,x4,y4: GLFloat;
  tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4: GLFloat;
  r1,g1,b1,alpha1,r2,g2,b2,alpha2,r3,g3,b3,alpha3,r4,g4,b4,alpha4: GLFloat;
  tex_num:  GLenum);
var
  vertex_coords: array[0..7] of GLfloat;
  color_coords: array[0..15] of GLfloat;
  texcoords: array[0..7] of GLfloat;
begin
{
  vertex_coords[0]:=x1;  vertex_coords[1]:=y1;
  vertex_coords[2]:=x2;  vertex_coords[3]:=y2;
  vertex_coords[4]:=x3;  vertex_coords[5]:=y3;
  vertex_coords[6]:=x4;  vertex_coords[7]:=y4;

  texcoords[0]:=tx1; texcoords[1]:=ty1;
  texcoords[2]:=tx2; texcoords[3]:=ty2;
  texcoords[4]:=tx3; texcoords[5]:=ty3;
  texcoords[6]:=tx4; texcoords[7]:=ty4;

  color_coords[0]:=r1;  color_coords[1]:=g1; color_coords[2]:=b1; color_coords[3]:=alpha1;
  color_coords[4]:=r2;  color_coords[5]:=g2; color_coords[6]:=b2; color_coords[7]:=alpha2;
  color_coords[8]:=r3;  color_coords[9]:=g3; color_coords[10]:=b3; color_coords[11]:=alpha3;
  color_coords[12]:=r4;  color_coords[13]:=g4; color_coords[14]:=b4; color_coords[15]:=alpha4;

  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glVertexPointer(2, GL_FLOAT, 0, @vertex_coords[0]);
  glClientActiveTexture(GL_TEXTURE0 + tex_num);
  glTexCoordPointer(2, GL_FLOAT, 0, @texcoords[0]);
  glColorPointer(4, GL_FLOAT, 0, @color_coords[0]);
  //glDisableVertexAttribArray(0);

  glDrawArrays(GL_TRIANGLE_FAN,0,4);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY); }

  end;



end.

