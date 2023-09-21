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
 *}

unit UPlatformAndroid;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  Classes,
  UPlatform,
  UConfig,
  UPath;

type
  TPlatformAndroid = class(TPlatform)
    private
      UseLocalDirs: boolean;

      AndroidDataRoot: string;


      procedure DetectLocalExecution();
      function GetHomeDir(): IPath;
    public

      procedure Init; override;
      
      function GetLogPath        : IPath; override;
      function GetGameSharedPath : IPath; override;
      function GetGameUserPath   : IPath; override;

      function GetExecutionDir(): IPath; override;

  end;



implementation

uses
  UCommandLine,
  BaseUnix,
  SysUtils,
  ULog,
  UJniCallback;



procedure TPlatformAndroid.Init;
begin
  inherited Init();
  DetectLocalExecution();
  AndroidDataRoot:=storageRoot_fromJava();
  debug_message_to_android('PlatformAndroid: Android data directory: '+AndroidDataRoot);
end;

{**
 * Detects whether the game was executed locally or globally.
 * - It is local if it was not installed and directly executed from
 *   within the game folder. In this case resources (themes, language-files)
 *   reside in the directory of the executable.
 * - It is global if the game was installed (e.g. to /usr/bin) and
 *   the resources are in a separate folder (e.g. /usr/share/ultrastardx)
 *   which name is stored in the INSTALL_DATADIR constant in paths.inc.
 *
 * Sets UseLocalDirs to true if the game is executed locally, false otherwise.
 *}
procedure TPlatformAndroid.DetectLocalExecution();
begin
  UseLocalDirs := False;
end;

function TPlatformAndroid.GetLogPath: IPath;
begin
   Result := GetGameUserPath().Append('logs', pdAppend);

  // create non-existing directories
  Result.CreateDirectory(true);
end;

function TPlatformAndroid.GetGameSharedPath: IPath;
begin
  Result := GetExecutionDir();
end;

function TPlatformAndroid.GetGameUserPath: IPath;
begin
    Result := GetExecutionDir()
end;

{**
 * Returns the user's home directory terminated by a path delimiter
 *}
function TPlatformAndroid.GetHomeDir(): IPath;
begin
  Result := GetExecutionDir();

end;

function TPlatformAndroid.GetExecutionDir(): IPath;
begin
  GetExecutionDir := Path(AndroidDataRoot);

end;

end.
