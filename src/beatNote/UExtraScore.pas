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

unit UExtraScore;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UIni;


function ExtraScoreFactor(): real; // As a function of the difficulty, get the extra score factor



implementation



function ExtraScoreFactor(): real;

begin
     //IAdvanceDrawNotes:   array[0..3] of UTF8String = ('Off', 'On', 'End', 'Hide');

     Result:=1.0;
     if((Ini.AdvanceDrawNotes=0)) then
          Result:=1.1;
     if((Ini.AdvanceDrawNotes=2)) then
          Result:=1.2;
     if(Ini.AdvanceDrawNotes=3) then
          Result:=1.3;




end;



end.

