{***************************************************************** 
 * Configuration file for ultrastardx 2024.10.0+dev
 * src/config-win.inc.  Generated from config.inc.in by configure.
 *****************************************************************}

{* Libraries *}

{$IF Defined(IncludeConstants)}
  lua_lib_name = 'lua51';
  LUA_VERSION_INT     = 5001005;
  LUA_VERSION_RELEASE = '5';
  LUA_VERSION_MINOR   = '1';
  LUA_VERSION_MAJOR   = '5';
  LUA_VERSION         = '5.1.5';
  LUA_INTEGER_BITS    = 64;
{$IFEND}

{$DEFINE HaveFFmpeg}
{$IF Defined(HaveFFmpeg)}
  {$MACRO ON}
  {$IFNDEF FFMPEG_DIR}
    {$IF (0 > 0) or (7 > 0)}
      {$DEFINE FFMPEG_DIR := 'ffmpeg-7.0'}
      {$DEFINE FF_API_OLD_DECODE_AUDIO}
    {$ELSE}
      {$DEFINE FFMPEG_DIR := 'ffmpeg'}
      {$DEFINE useOLD_FFMPEG}
    {$IFEND}
  {$ENDIF}
  {$IF Defined(IncludeConstants)}
    FFMPEG_VERSION_INT = 7000000;

  av__codec = 'libavcodec';
  LIBAVCODEC_VERSION_MAJOR   = 61;
  LIBAVCODEC_VERSION_MINOR   = 19;
  LIBAVCODEC_VERSION_RELEASE = 100;

  av__format = 'libavformat';
  LIBAVFORMAT_VERSION_MAJOR   = 61;
  LIBAVFORMAT_VERSION_MINOR   = 7;
  LIBAVFORMAT_VERSION_RELEASE = 100;

  av__util = 'libavutil';
  LIBAVUTIL_VERSION_MAJOR   = 59;
  LIBAVUTIL_VERSION_MINOR   = 39;
  LIBAVUTIL_VERSION_RELEASE = 100;
  {$IFEND}

  {$IF (7 < 4)}
    {$DEFINE UseFFmpegResample}
  {$IFEND}

{$IFEND}

{$DEFINE HaveSWScale}
{$IF Defined(HaveSWScale) and Defined(IncludeConstants)}
  sw__scale = 'libswscale';
  LIBSWSCALE_VERSION_MAJOR   = 8;
  LIBSWSCALE_VERSION_MINOR   = 3;
  LIBSWSCALE_VERSION_RELEASE = 100;
{$IFEND}

{* libswresample was introduced with FFmpeg 0.9 *}
{$DEFINE HaveSWResample}
{$IF Defined(HaveSWResample) and Defined(IncludeConstants)}
  sw__resample = 'libswresample';
  LIBSWRESAMPLE_VERSION_MAJOR   = 5;
  LIBSWRESAMPLE_VERSION_MINOR   = 3;
  LIBSWRESAMPLE_VERSION_RELEASE = 100;
{$IFEND}

{$UNDEF HaveProjectM}
{$UNDEF UseLocalProjectMPresets}
{$IF Defined(HaveProjectM) and Defined(IncludeConstants)}
  {$IF Defined(UseLocalProjectMPresets)}
    ProjectM_DataDir = 'visuals/projectM';
  {$ELSE}
    ProjectM_DataDir = '';
  {$IFEND}
  PROJECTM_VERSION_MAJOR   = 0;
  PROJECTM_VERSION_MINOR   = 0;
  PROJECTM_VERSION_RELEASE = 0;
{$IFEND}

{$DEFINE HavePortaudio}
{$IF Defined(HavePortaudio) and Defined(IncludeConstants)}
  PORTAUDIO_VERSION_MAJOR   = 19;
  PORTAUDIO_VERSION_MINOR   = 0;
  PORTAUDIO_VERSION_RELEASE = 0;
{$IFEND}

{$UNDEF HaveAMidi}
{$UNDEF HavePortmixer}
{$DEFINE UsePortMidi}
{$IF Defined(UsePortMidi)}
  {$DEFINE UseMIDIPort}
{$IFEND}
{$UNDEF UsePortTime}
{$UNDEF PortTime_in_}
{$IF Defined(IncludeConstants)}
  porttime_lib_name = '';
{$IFEND}

{$UNDEF UseOpenCVWrapper}
{$UNDEF OpenCVCoreStandalone}
{$UNDEF OpenCVImgprocStandalone}
{$UNDEF OpenCVVideoioStandalone}
