// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF3 to embed a chromium-based
// browser in Delphi applications.
//
// The original license of DCEF3 still applies to CEF4Delphi.
//
// For more information about CEF4Delphi visit :
//         https://www.briskbard.com/index.php?lang=en&pageid=cef
//
//        Copyright © 2018 Salvador Díaz Fau. All rights reserved.
//
// ************************************************************************
// ************ vvvv Original license and comments below vvvv *************
// ************************************************************************
(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)


program MiniBrowser;

{$MODE Delphi}

{$I cef.inc}

uses
  {$IFDEF DELPHI16_UP}
  Vcl.Forms,
  WinApi.Windows,
  {$ELSE}
  Forms, Windows,
  LCLIntf, LCLType, LMessages, Interfaces,
  {$ENDIF }
  uCEFApplication,
  uCEFTypes,
  uCEFConstants,
  uMiniBrowser in 'uMiniBrowser.pas' {MiniBrowserFrm},
  uPreferences in 'uPreferences.pas' {PreferencesFrm},
  uSimpleTextViewer in 'uSimpleTextViewer.pas' {SimpleTextViewerFrm};

{.$R *.res}

{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

begin
  GlobalCEFApp := TCefApplication.Create;

  GlobalCEFApp.LogFile              := 'debug.log';
  GlobalCEFApp.LogSeverity          := LOGSEVERITY_INFO;

  if GlobalCEFApp.StartMainProcess then
    begin
      Application.Initialize;
      {$IFDEF DELPHI11_UP}
      Application.MainFormOnTaskbar := True;
      {$ENDIF}
      Application.CreateForm(TMiniBrowserFrm, MiniBrowserFrm);
      Application.CreateForm(TPreferencesFrm, PreferencesFrm);
      Application.CreateForm(TSimpleTextViewerFrm, SimpleTextViewerFrm);
      Application.Run;
    end;

  DestroyGlobalCEFApp;
end.
