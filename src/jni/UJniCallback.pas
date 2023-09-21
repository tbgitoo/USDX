unit UJniCallback;

interface

uses


  jni,       // For communication with Android Java
  SysUtils;




function android_log_write(prio:longint;tag,text:pchar):longint; cdecl;
procedure debug_message_to_android(str : String);
function JNI_OnLoad(vm:PJavaVM;reserved:pointer):jint; cdecl;
function getJniHandler(env: PJNIEnv):jclass;
function storageRoot_fromJava():String;


var
 theJavaVM:         PJavaVM;



implementation

function android_log_write(prio:longint;tag,text:pchar):longint; cdecl;
         external 'liblog.so' name '__android_log_write';


function convert_two_byte_string_to_one_byte_string(stri:PJChar; len: integer):String;
var chr: JChar;
    ind: integer;
    chr_one_byte: Char;
    stra: AnsiString;
begin
   if len<=0 then
     stra:=''
   else
   begin
        stra:='';
      for ind:=0 to (len-1) do begin
         chr:=stri[ind];
         chr_one_byte:=Char(chr);
         stra:=stra+chr_one_byte;
      end;

   end;
   convert_two_byte_string_to_one_byte_string:=stra;

end;

procedure debug_message_to_android(str : String);
var
  p: PChar;
  stra: AnsiString;
begin
   stra:=AnsiString(str);
   p := PChar(GetMem(Length(stra) + 1));
   Move(stra[1], p[0], Length(stra));
   p[Length(stra)]:=#0;
   android_log_write(4,'JNI_Pascal',p);
   FreeMem(p);
end;


procedure GetJNIEnv(var env:PJNIEnv);
var p:PPointer;
begin
  p:=@(env^);
  theJavaVM^^.GetEnv(theJavaVM, p,JNI_VERSION_1_6);

end;





function JNI_OnLoad(vm:PJavaVM;reserved:pointer):jint; cdecl;
begin
  debug_message_to_android('JNI_OnLoad called');
  theJavaVM:=vm;
  JNI_OnLoad:=JNI_VERSION_1_6;
 end;

function getJniHandler(env: PJNIEnv):jclass;
var
p: PChar;
str: String;
t: Jint;
begin

   if(env^^.FindClass <> nil) then begin
   str:= 'com/tbgitoo/ultrastardx_android/JniHandler';
   p := PChar(GetMem(Length(str) + 1));
   Move(str[1], p[0], Length(str));
   p[Length(str)]:=#0;
   getJniHandler:=env^^.FindClass(env,p);
   FreeMem(p);


   end;

end;

function JStringToString(env: PJNIEnv;str : JString; len: integer): String;
var
IsCopy: JBoolean;  // added for GetStringChars
Chars: PJChar;     // added for GetStringChars
current_chr: jchar;
wd: PWideChar;
begin
   Chars := env^^.GetStringChars(env, str, IsCopy);

   JStringToString:=convert_two_byte_string_to_one_byte_string(Chars,len);
   env^^.ReleaseStringChars(env, str, Chars);
end;


function storageRoot_fromJava():String;
var
 jni_handler: jclass;
 env: PJNIEnv;
 env1: JNIEnv;
 envrec: JNINativeInterface;
 methodID_storageRoot: JMethodID;
 methodID_getStorageRootStrLen: JMethodID;
 ret: JString;
 len: integer;
 Str: String;
 IsCopy: JBoolean;  // added for GetStringChars
 Chars: PJChar;     // added for GetStringChars
begin
   env1:=@envrec;  // This is subtle: in jni.pas JNIEnv is itself declared as a pointer, so in order
   // to have something to work with, we need first to have an actual JNINativeInterface object
   env:=@env1;
   GetJNIEnv(env);
   theJavaVM^^.AttachCurrentThread(theJavaVM,@env,nil);
   jni_handler:=getJniHandler(env);
   methodID_storageRoot:=env^^.GetStaticMethodID(env, jni_handler,'getStorageRoot','()Ljava/lang/String;');
   ret:=env^^.CallStaticObjectMethod(env,jni_handler,methodID_storageRoot);
   methodID_getStorageRootStrLen:=env^^.GetStaticMethodID(env, jni_handler,'getStorageRootStrLen','()I');
   len:=env^^.CallStaticIntMethod(env,jni_handler,methodID_getStorageRootStrLen);


    storageRoot_fromJava:=JStringToString(env,ret,len);

end;

end.





