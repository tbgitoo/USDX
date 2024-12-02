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
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/base/UPlaylist.pas $
 * $Id: $
 *}

unit UWebcam;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  Classes,
  UTexture,
  {$IFDEF UseSDL3}
  sdl3,
  {$ELSE}
  sdl2,
  {$ENDIF}
  opencv_highgui,
  opencv_core,
  opencv_imgproc,
  opencv_types;

type

  TWebcam = class
    private
      IsEnabled:     Boolean;
      Interval:      integer;
      LastTickFrame: integer;
      LastFrame:     PIplImage;
      CurrentFrame:  PIplImage;
      Mutex:         PSDL_Mutex;
      StopCond:      PSDL_Cond;
      CaptureThread: PSDL_Thread;
      BGR2YUV:       PCvMat;
      YUV2BGR:       PCvMat;
      Mat1:          PCvMat;
      Mat2:          PCvMat;

      function CaptureLoop: integer;
      class function CaptureThreadMain(Data: Pointer): integer; cdecl; static;
    public
      Capture: PCvCapture;
      TextureCam: TTexture;

      constructor Create;
      destructor Destroy; override;
      procedure Start;
      procedure Release;
      procedure Restart;
      procedure GetWebcamFrame();
      function FrameEffect(Nr_Effect: integer; Frame: PIplImage): PIplImage;
      function FrameAdjust(Frame: PIplImage): PIplImage;
   end;

var
  Webcam:    TWebcam;


implementation

uses
  {$IFDEF UseOpenGLES}
  dglOpenGLES,
  {$ELSE}
  dglOpenGL,
  {$ENDIF}
  SysUtils,
  ULog,
  UIni;

//----------
//Create - Construct Class
//----------
constructor TWebcam.Create;
begin
  inherited;
  Mutex := SDL_CreateMutex();
  StopCond := SDL_CreateCond();
  IsEnabled := false;
  if @cvCreateMat <> nil then
  begin
    BGR2YUV := cvCreateMat(3, 3, CV_32FC1);
    YUV2BGR := cvCreateMat(3, 3, CV_32FC1);
    Mat1 := cvCreateMat(3, 3, CV_32FC1);
    Mat2 := cvCreateMat(3, 3, CV_32FC1);

    cvSetReal2D(PCvArr(BGR2YUV), 0, 0, 0.114);
    cvSetReal2D(PCvArr(BGR2YUV), 0, 1, 0.587);
    cvSetReal2D(PCvArr(BGR2YUV), 0, 2, 0.299);
    cvSetReal2D(PCvArr(BGR2YUV), 1, 0, 1);
    cvSetReal2D(PCvArr(BGR2YUV), 1, 1, -0.587/(1-0.114));
    cvSetReal2D(PCvArr(BGR2YUV), 1, 2, -0.299/(1-0.114));
    cvSetReal2D(PCvArr(BGR2YUV), 2, 0, -0.114/(1-0.299));
    cvSetReal2D(PCvArr(BGR2YUV), 2, 1, -0.587/(1-0.299));
    cvSetReal2D(PCvArr(BGR2YUV), 2, 2, 1);
    cvInvert(PCvArr(BGR2YUV), PCvArr(YUV2BGR));
  end;
end;

destructor TWebcam.Destroy;
begin
  Release;
  if @cvReleaseMat <> nil then
  begin
    cvReleaseMat(@Mat2);
    cvReleaseMat(@Mat1);
    cvReleaseMat(@YUV2BGR);
    cvReleaseMat(@BGR2YUV);
  end;
  SDL_DestroyCond(StopCond);
  SDL_DestroyMutex(Mutex);
  inherited;
end;

procedure TWebcam.Start;
var
  H, W, I: integer;
  s: string;
begin

  if (Ini.WebCamID <> 0) then
  begin
    try
      Capture := cvCreateCameraCapture(Ini.WebCamID - 1);
      IsEnabled := true;
    except
      IsEnabled:=false;
    end;

    if (IsEnabled = true) and (Capture <> nil) then
    begin
      S := IWebcamResolution[Ini.WebcamResolution];

      I := Pos('x', S);
      W := StrToInt(Copy(S, 1, I-1));
      H := StrToInt(Copy(S, I+1, 1000));

      cvSetCaptureProperty(Capture, CV_CAP_PROP_FRAME_WIDTH, W);
      cvSetCaptureProperty(Capture, CV_CAP_PROP_FRAME_HEIGHT, H);

      Interval := 1000 div StrToInt(IWebcamFPS[Ini.WebCamFPS]);
      CaptureThread := SDL_CreateThread(@TWebcam.CaptureThreadMain, nil, Self);
    end;
  end;

end;

procedure TWebcam.Release;
begin
  if (IsEnabled = true) and (Capture <> nil) then
  begin
    SDL_LockMutex(Mutex);
    IsEnabled := false;
    SDL_CondSignal(StopCond);
    SDL_UnlockMutex(Mutex);
    SDL_WaitThread(CaptureThread, nil);
    try
      cvReleaseCapture(@Capture);
    except
      ;
    end;
  end;
end;

procedure TWebcam.Restart;
begin
  Release;
  try
    Start
  except
    ;
  end;
end;

function TWebcam.CaptureLoop: integer;
var
  WebcamFrame: PIplImage;
  Now: integer;
begin
  SDL_LockMutex(Mutex);
  while IsEnabled do
  begin
    SDL_UnlockMutex(Mutex);

    LastTickFrame := SDL_GetTicks();
    WebcamFrame := cvQueryFrame(Capture);

    if WebcamFrame <> nil then
      WebcamFrame := cvCloneImage(WebcamFrame);

    SDL_LockMutex(Mutex);
    if WebcamFrame <> nil then
    begin
      cvReleaseImage(@CurrentFrame);
      CurrentFrame := WebcamFrame;
    end;

    Now := SDL_GetTicks();
    if IsEnabled and (Now - LastTickFrame < Interval) then
    begin
      SDL_CondWaitTimeout(StopCond, Mutex, Interval - (Now - LastTickFrame));
    end
  end;
  SDL_UnlockMutex(Mutex);
  Result := 0;
end;

class function TWebcam.CaptureThreadMain(Data: Pointer): integer; cdecl; static;
begin
  Result := TWebcam(Data).CaptureLoop;
end;

procedure TWebcam.GetWebcamFrame();
var
  WebcamFrame: PIplImage;
begin
  WebcamFrame := nil;

  if IsEnabled then
  begin
    SDL_LockMutex(Mutex);
    WebcamFrame := CurrentFrame;
    CurrentFrame := nil;
    Interval := 1000 div StrToInt(IWebcamFPS[Ini.WebCamFPS]);
    SDL_UnlockMutex(Mutex);
  end;

  if WebcamFrame <> nil then
  begin
    if (TextureCam.TexNum > 0) then
    begin
      glDeleteTextures(1, PGLuint(@TextureCam.TexNum));
      TextureCam.TexNum := 0;
    end;

    if (Ini.WebCamFlip = 0) then
      cvFlip(WebcamFrame, nil, 1);

    WebcamFrame := FrameAdjust(WebcamFrame);
    WebcamFrame := FrameEffect(Ini.WebCamEffect, WebcamFrame);

    TextureCam := Texture.CreateTexture(WebcamFrame.imageData, nil, WebcamFrame.Width, WebcamFrame.Height);

    cvReleaseImage(@WebcamFrame);
  end;

end;

// 0  -> NORMAL
// 1  -> GRAYSCALE
// 2  -> BLACK & WHITE
// 3  -> NEGATIVE
// 4  -> BINARY IMAGE
// 5  -> DILATE
// 6  -> THRESHOLD
// 7  -> EDGES
// 8  -> GAUSSIAN BLUR
// 9  -> EQUALIZED
// 10 -> ERODE
function TWebcam.FrameEffect(Nr_Effect: integer; Frame: PIplImage): PIplImage;
var
  Size: CvSize;
  CamEffectParam: integer;
  ImageFrame, EffectFrame, DiffFrame, RGBFrame: PIplImage;
begin

  // params values
  case Nr_Effect of
    4: CamEffectParam := 20; // binary image
    5: CamEffectParam := 2;  // dilate
    6: CamEffectParam := 60; // threshold
    7: CamEffectParam := 70; // edges
    8: CamEffectParam := 11; // gaussian blur
   10: CamEffectParam := 2; // erode
   else
      CamEffectParam := 0;
  end;

  Size  := cvSizeV(Frame.width, Frame.height);

  ImageFrame := cvCreateImage(Size, Frame.depth, 1);
  EffectFrame := cvCreateImage(Size, Frame.depth, 1);
  DiffFrame := cvCreateImage (Size, Frame.depth, 1);
  RGBFrame := cvCreateImage(Size, Frame.depth, 3);

  case Nr_Effect of
    1: begin // Grayscale
         cvCvtColor(Frame, EffectFrame, CV_BGR2GRAY);
         cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
       end;

    2: begin // Black & White
         cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY );
         cvThreshold(ImageFrame, EffectFrame, 128, 255, CV_THRESH_OTSU);
         cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
       end;

    3: begin // Negative
         cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
         cvNot(RGBFrame, RGBFrame);
       end;

    4: begin // Binary Image

         //Convert frame to gray and store in image
         cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
         cvEqualizeHist(ImageFrame, ImageFrame);

         //Copy Image
         if(LastFrame = nil) then
           LastFrame := cvCloneImage(ImageFrame);

         //Differences with actual and last image
         cvAbsDiff(ImageFrame, LastFrame, DiffFrame);

         //threshold image
         cvThreshold(DiffFrame, EffectFrame, CamEffectParam, 255, 0);

         cvReleaseImage(@LastFrame);

         //Change datas;
         LastFrame := cvCloneImage(ImageFrame);

         cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
       end;

    5: begin // Dilate
         cvDilate(Frame, Frame, nil, CamEffectParam);
         cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
       end;

    6: begin //threshold
         cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
         cvThreshold(ImageFrame, EffectFrame, CamEffectParam, 100, 3);
         cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
       end;

    7: begin // Edges
         cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
         cvCanny(ImageFrame, EffectFrame, CamEffectParam, CamEffectParam, 3);
         cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
       end;

    8: begin // Gaussian Blur
         cvSmooth(Frame, Frame, CV_BLUR, CamEffectParam, CamEffectParam);
         cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
       end;

    9: begin // Equalized
         cvCvtColor(Frame, ImageFrame, CV_BGR2GRAY);
         cvEqualizeHist(ImageFrame, EffectFrame);
         cvCvtColor(EffectFrame, RGBFrame, CV_GRAY2RGB);
       end;

    10: begin // Erode
         cvErode(Frame, Frame, nil, CamEffectParam);
         cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
       end;
    {
    11:begin // Color
         RGBFrame := cvCreateImage(Size, Frame.depth, 3);

         cvAddS(Frame, CV_RGB(255, 0, 0), Frame);
         cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
       end;

    12:begin // Value
         ImageFrame := cvCreateImage(Size, Frame.depth, 1);
         RGBFrame := cvCreateImage(Size, Frame.depth, 3);

         // Convert from Red-Green-Blue to Hue-Saturation-Value
         cvCvtColor(Frame, RGBFrame, CV_BGR2HSV );

         // Split hue, saturation and value of hsv on them
         cvSplit(RGBFrame, nil, nil, ImageFrame, 0);
         cvCvtColor(ImageFrame, RGBFrame, CV_GRAY2RGB);
       end;
       }
    else
    begin
      //normal
      cvCvtColor(Frame, RGBFrame, CV_BGR2RGB);
    end;
  end;

  cvReleaseImage(@ImageFrame);
  cvReleaseImage(@DiffFrame);
  cvReleaseImage(@EffectFrame);
  cvReleaseImage(@Frame);
  Result := RGBFrame;

end;

function TWebcam.FrameAdjust(Frame: PIplImage): PIplImage;
var
  BrightValue, SaturationValue, HueValue: integer;
  C, S: real;
begin

  BrightValue := Ini.WebcamBrightness;
  SaturationValue := Ini.WebCamSaturation;
  HueValue := Ini.WebCamHue;

  if (BrightValue <> 100) or (SaturationValue <> 100) or (HueValue <> 180) then
  begin
    C := (HueValue - 180) * Pi / 180;
    S := sin(C) * SaturationValue / 100;
    C := cos(C) * SaturationValue / 100;
    cvSetZero(PCvArr(Mat1));
    cvSetReal2D(PCvArr(Mat1), 0, 0, BrightValue / 100);
    cvSetReal2D(PCvArr(Mat1), 1, 1, C);
    cvSetReal2D(PCvArr(Mat1), 1, 2, S);
    cvSetReal2D(PCvArr(Mat1), 2, 1, -S);
    cvSetReal2D(PCvArr(Mat1), 2, 2, C);
    cvGEMM(PCvArr(Mat1), PCvArr(BGR2YUV), 1, nil, 0, PCvArr(Mat2));
    cvGEMM(PCvArr(YUV2BGR), PCvArr(Mat2), 1, nil, 0, PCvArr(Mat1));
    cvTransform(PCvArr(Frame), PCvArr(Frame), Mat1);
  end;

  Result := Frame;
end;

//----------

end.
