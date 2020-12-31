// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF to embed a chromium-based
// browser in Delphi applications.
//
// The original license of DCEF3 still applies to CEF4Delphi.
//
// For more information about CEF4Delphi visit :
//         https://www.briskbard.com/index.php?lang=en&pageid=cef
//
//        Copyright © 2020 Salvador Diaz Fau. All rights reserved.
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

unit uSimpleOSRBrowser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LCLType, ComCtrls, Types, SyncObjs,
  uCEFChromium, uCEFTypes, uCEFInterfaces, uCEFConstants, uCEFBufferPanel,
  uCEFChromiumEvents;

type
  { TForm1 }
  TForm1 = class(TForm)
    AddressEdt: TEdit;
    SaveDialog1: TSaveDialog;
    SnapshotBtn: TButton;
    GoBtn: TButton;
    Panel1: TBufferPanel;
    Chromium1: TChromium;
    AddressPnl: TPanel;
    Panel2: TPanel;
    Timer1: TTimer;

    procedure Panel1Click(Sender: TObject);
    procedure Panel1Enter(Sender: TObject);
    procedure Panel1Exit(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Panel1Resize(Sender: TObject);

    procedure Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure Chromium1BeforePopup(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean; const popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings; var extra_info: ICefDictionaryValue; var noJavascriptAccess: Boolean; var Result: Boolean);
    procedure Chromium1CursorChange(Sender: TObject; const browser: ICefBrowser; cursor_: TCefCursorHandle; cursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo; var aResult : boolean);
    procedure Chromium1GetScreenInfo(Sender: TObject; const browser: ICefBrowser; var screenInfo: TCefScreenInfo; out Result: Boolean);
    procedure Chromium1GetScreenPoint(Sender: TObject; const browser: ICefBrowser; viewX, viewY: Integer; var screenX, screenY: Integer; out Result: Boolean);
    procedure Chromium1GetViewRect(Sender: TObject; const browser: ICefBrowser; var rect: TCefRect);
    procedure Chromium1OpenUrlFromTab(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean; out Result: Boolean);
    procedure Chromium1Paint(Sender: TObject; const browser: ICefBrowser; type_: TCefPaintElementType; dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray; const buffer: Pointer; aWidth, aHeight: Integer);
    procedure Chromium1PopupShow(Sender: TObject; const browser: ICefBrowser; aShow: Boolean);
    procedure Chromium1PopupSize(Sender: TObject; const browser: ICefBrowser; const rect: PCefRect);
    procedure Chromium1Tooltip(Sender: TObject; const browser: ICefBrowser; var aText: ustring; out Result: Boolean);

    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure GoBtnClick(Sender: TObject);
    procedure GoBtnEnter(Sender: TObject);
    procedure SnapshotBtnClick(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);  
    procedure AddressEdtEnter(Sender: TObject);
  private             

  protected
    FPopUpRect       : TRect;
    FShowPopUp       : boolean;
    FResizing        : boolean;
    FPendingResize   : boolean;
    FCanClose        : boolean;
    FClosing         : boolean;
    FResizeCS        : TCriticalSection;     
    FBrowserCS       : TCriticalSection;
    FPanelCursor     : TCursor;
    FPanelHint       : ustring;

    function  GetPanelCursor : TCursor;
    function  GetPanelHint : ustring;

    procedure SetPanelCursor(aValue : TCursor);
    procedure SetPanelHint(const aValue : ustring);

    procedure SendCompMessage(aMsg : cardinal);
    function  getModifiers(Shift: TShiftState): TCefEventFlags;
    function  GetButton(Button: TMouseButton): TCefMouseButtonType;
    procedure DoResize;

    procedure BrowserCreatedMsg(Data: PtrInt);
    procedure BrowserCloseFormMsg(Data: PtrInt);
    procedure PendingResizeMsg(Data: PtrInt);
    procedure PendingInvalidateMsg(Data: PtrInt);
    procedure PendingCursorUpdateMsg(Data: PtrInt);
    procedure PendingHintUpdateMsg(Data: PtrInt);

    property PanelCursor  : TCursor   read GetPanelCursor   write SetPanelCursor;
    property PanelHint    : ustring   read GetPanelHint     write SetPanelHint;

  public
    procedure SendCEFKeyEvent(const aCefEvent : TCefKeyEvent);
  end;

var
  Form1: TForm1;

procedure CreateGlobalCEFApp;

implementation

{$R *.lfm}

// This is a simple CEF browser in "off-screen rendering" mode (a.k.a OSR mode)

// It uses the default CEF configuration with a multithreaded message loop and
// that means that the TChromium events are executed in a CEF thread.

// GTK is not thread safe so we have to save all the information given in the
// TChromium events and use it later in the main application thread. We use
// critical sections to protect all that information.

// For example, the browser updates the mouse cursor in the
// TChromium.OnCursorChange event so we have to save the cursor in FPanelCursor
// and use Application.QueueAsyncCall to update the Panel1.Cursor value in the
// main application thread.

// The raw bitmap information given in the TChromium.OnPaint event also needs to
// be stored in a TCEFBitmapBitBuffer class instead of a simple TBitmap to avoid
// issues with GTK.

// Chromium needs the key press data available in the GDK signals
// "key-press-event" and "key-release-event" but Lazarus doesn't expose that
// information so we have to call g_signal_connect to receive that information
// in the GTKKeyPress function.

// Chromium renders the web contents asynchronously. It uses multiple processes
// and threads which makes it complicated to keep the correct browser size.

// In one hand you have the main application thread where the form is resized by
// the user. On the other hand, Chromium renders the contents asynchronously
// with the last browser size available, which may have changed by the time
// Chromium renders the page.

// For this reason we need to keep checking the real size and call
// TChromium.WasResized when we detect that Chromium has an incorrect size.

// TChromium.WasResized triggers the TChromium.OnGetViewRect event to let CEF
// read the current browser size and then it triggers TChromium.OnPaint when the
// contents are finally rendered.

// TChromium.WasResized --> (time passes) --> TChromium.OnGetViewRect --> (time passes) --> TChromium.OnPaint

// You have to assume that the real browser size can change between those calls
// and events.

// This demo uses a couple of fields called "FResizing" and "FPendingResize" to
// reduce the number of TChromium.WasResized calls.

// FResizing is set to True before the TChromium.WasResized call and it's set to
// False at the end of the TChromium.OnPaint event.

// FPendingResize is set to True when the browser changed its size while
// FResizing was True. The FPendingResize value is checked at the end of
// TChromium.OnPaint to check the browser size again because it changed while
// Chromium was rendering the page.

// The TChromium.OnPaint event in the demo also calls
// TBufferPanel.UpdateBufferDimensions and TBufferPanel.BufferIsResized to check
// the width and height of the buffer parameter, and the internal buffer size in
// the TBufferPanel component.

// Lazarus usually initializes the GTK WidgetSet in the initialization section
// of the "Interfaces" unit which is included in the LPR file. This causes
// initialization problems in CEF and we need to call "CreateWidgetset" after
// the GlobalCEFApp.StartMainProcess call.

// Lazarus shows a warning if we remove the "Interfaces" unit from the LPR file
// so we created a custom unit with the same name that includes two procedures
// to initialize and finalize the WidgetSet at the right time.

// This is the destruction sequence in OSR mode :
// 1- FormCloseQuery sets CanClose to the initial FCanClose value (False) and calls Chromium1.CloseBrowser(True).
// 2- Chromium1.CloseBrowser(True) will trigger chrmosr.OnClose and we have to
//    set "Result" to false and CEF will destroy the internal browser immediately.
// 3- chrmosr.OnBeforeClose is triggered because the internal browser was destroyed.
//    FCanClose is set to True and calls SendCompMessage(CEF_BEFORECLOSE) to
//    close the form asynchronously.

uses
  Math, gtk2, glib2, gdk2, gtk2proc, gtk2int,
  uCEFMiscFunctions, uCEFApplication, uCEFBitmapBitBuffer;

const
  CEF_UPDATE_CURSOR = $A0D;
  CEF_UPDATE_HINT   = $A0E;

procedure CreateGlobalCEFApp;
begin
  GlobalCEFApp                            := TCefApplication.Create;
  GlobalCEFApp.WindowlessRenderingEnabled := True;
  GlobalCEFApp.EnableHighDPISupport       := True;
  GlobalCEFApp.BackgroundColor            := CefColorSetARGB($FF, $FF, $FF, $FF);

  //GlobalCEFApp.LogFile             := 'debug.log';
  //GlobalCEFApp.LogSeverity         := LOGSEVERITY_INFO;
end;

function GTKKeyPress(Widget: PGtkWidget; Event: PGdkEventKey; Data: gPointer) : GBoolean; cdecl;
var
  TempCefEvent : TCefKeyEvent;
begin
  GdkEventKeyToCEFKeyEvent(Event, TempCefEvent);

  if (Event^._type = GDK_KEY_PRESS) then
    begin
      TempCefEvent.kind := KEYEVENT_RAWKEYDOWN;
      Form1.SendCEFKeyEvent(TempCefEvent);
      TempCefEvent.kind := KEYEVENT_CHAR;
      Form1.SendCEFKeyEvent(TempCefEvent);
    end
   else
    begin
      TempCefEvent.kind := KEYEVENT_KEYUP;
      Form1.SendCEFKeyEvent(TempCefEvent);
    end;

  Result := True;
end;

procedure ConnectKeyPressReleaseEvents(const aWidget : PGtkWidget);
begin
  g_signal_connect(aWidget, 'key-press-event',   TGTKSignalFunc(@GTKKeyPress), nil);
  g_signal_connect(aWidget, 'key-release-event', TGTKSignalFunc(@GTKKeyPress), nil);
end;

{ TForm1 }

procedure TForm1.SendCEFKeyEvent(const aCefEvent : TCefKeyEvent);
begin
  Chromium1.SendKeyEvent(@aCefEvent);
end;

procedure TForm1.GoBtnClick(Sender: TObject);
begin
  FResizeCS.Acquire;
  FResizing      := False;
  FPendingResize := False;
  FResizeCS.Release;

  Chromium1.LoadURL(AddressEdt.Text);
end;

procedure TForm1.Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  // Now the browser is fully initialized we can initialize the UI.
  SendCompMessage(CEF_AFTERCREATED);
end;

procedure TForm1.AddressEdtEnter(Sender: TObject);
begin
  Chromium1.SendFocusEvent(False);
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin
  Panel1.SetFocus;
end;

procedure TForm1.Panel1Enter(Sender: TObject);
begin
  Chromium1.SendFocusEvent(True);
end;

procedure TForm1.Panel1Exit(Sender: TObject);
begin
  Chromium1.SendFocusEvent(False);
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TempEvent : TCefMouseEvent;
  TempTime  : integer;
begin
  Panel1.SetFocus;

  TempEvent.x         := X;
  TempEvent.y         := Y;
  TempEvent.modifiers := getModifiers(Shift);
  DeviceToLogical(TempEvent, Panel1.ScreenScale);
  Chromium1.SendMouseClickEvent(@TempEvent, GetButton(Button), False, 1);
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  TempEvent : TCefMouseEvent;
  TempTime  : integer;
begin
  TempEvent.x         := x;
  TempEvent.y         := y;
  TempEvent.modifiers := getModifiers(Shift);
  DeviceToLogical(TempEvent, Panel1.ScreenScale);
  Chromium1.SendMouseMoveEvent(@TempEvent, False);
end;

procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TempEvent : TCefMouseEvent;
begin
  TempEvent.x         := X;
  TempEvent.y         := Y;
  TempEvent.modifiers := getModifiers(Shift);
  DeviceToLogical(TempEvent, Panel1.ScreenScale);
  Chromium1.SendMouseClickEvent(@TempEvent, GetButton(Button), True, 1);
end;

procedure TForm1.Panel1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  TempEvent  : TCefMouseEvent;
begin
  TempEvent.x         := MousePos.x;
  TempEvent.y         := MousePos.y;
  TempEvent.modifiers := getModifiers(Shift);
  DeviceToLogical(TempEvent, Panel1.ScreenScale);
  Chromium1.SendMouseWheelEvent(@TempEvent, 0, WheelDelta);
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
  DoResize;
end;

function TForm1.getModifiers(Shift: TShiftState): TCefEventFlags;
begin
  Result := EVENTFLAG_NONE;

  if (ssShift  in Shift) then Result := Result or EVENTFLAG_SHIFT_DOWN;
  if (ssAlt    in Shift) then Result := Result or EVENTFLAG_ALT_DOWN;
  if (ssCtrl   in Shift) then Result := Result or EVENTFLAG_CONTROL_DOWN;
  if (ssLeft   in Shift) then Result := Result or EVENTFLAG_LEFT_MOUSE_BUTTON;
  if (ssRight  in Shift) then Result := Result or EVENTFLAG_RIGHT_MOUSE_BUTTON;
  if (ssMiddle in Shift) then Result := Result or EVENTFLAG_MIDDLE_MOUSE_BUTTON;
end;       

function TForm1.GetButton(Button: TMouseButton): TCefMouseButtonType;
begin
  case Button of
    TMouseButton.mbRight  : Result := MBT_RIGHT;
    TMouseButton.mbMiddle : Result := MBT_MIDDLE;
    else                    Result := MBT_LEFT;
  end;
end;

procedure TForm1.Chromium1BeforeClose(Sender: TObject;
  const browser: ICefBrowser);
begin
  FCanClose := True;
  SendCompMessage(CEF_BEFORECLOSE);
end;

procedure TForm1.Chromium1BeforePopup(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
  targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
  userGesture: Boolean; const popupFeatures: TCefPopupFeatures;
  var windowInfo: TCefWindowInfo; var client: ICefClient;
  var settings: TCefBrowserSettings; var extra_info: ICefDictionaryValue;
  var noJavascriptAccess: Boolean; var Result: Boolean);
begin
  // For simplicity, this demo blocks all popup windows and new tabs
  Result := (targetDisposition in [WOD_NEW_FOREGROUND_TAB, WOD_NEW_BACKGROUND_TAB, WOD_NEW_POPUP, WOD_NEW_WINDOW]);
end;

procedure TForm1.Chromium1CursorChange(Sender: TObject;
  const browser: ICefBrowser; cursor_: TCefCursorHandle;
  cursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo; 
  var aResult : boolean);
begin
  PanelCursor := CefCursorToWindowsCursor(cursorType);
  aResult     := True;

  SendCompMessage(CEF_UPDATE_CURSOR);
end;

procedure TForm1.Chromium1GetScreenInfo(Sender: TObject;
  const browser: ICefBrowser; var screenInfo: TCefScreenInfo; out
  Result: Boolean);
var
  TempRect  : TCEFRect;
  TempScale : single;
begin           
  TempScale       := Panel1.ScreenScale;
  TempRect.x      := 0;
  TempRect.y      := 0;
  TempRect.width  := DeviceToLogical(Panel1.Width,  TempScale);
  TempRect.height := DeviceToLogical(Panel1.Height, TempScale);

  screenInfo.device_scale_factor := TempScale;
  screenInfo.depth               := 0;
  screenInfo.depth_per_component := 0;
  screenInfo.is_monochrome       := Ord(False);
  screenInfo.rect                := TempRect;
  screenInfo.available_rect      := TempRect;

  Result := True;
end;

procedure TForm1.Chromium1GetScreenPoint(Sender: TObject;
  const browser: ICefBrowser; viewX, viewY: Integer; var screenX,
  screenY: Integer; out Result: Boolean);
var
  TempScreenPt, TempViewPt : TPoint;
  TempScale : single;
begin
  TempScale    := Panel1.ScreenScale;
  TempViewPt.x := LogicalToDevice(viewX, TempScale);
  TempViewPt.y := LogicalToDevice(viewY, TempScale);
  TempScreenPt := Panel1.ClientToScreen(TempViewPt);
  screenX      := TempScreenPt.x;
  screenY      := TempScreenPt.y;
  Result       := True;
end;

procedure TForm1.Chromium1GetViewRect(Sender: TObject;
  const browser: ICefBrowser; var rect: TCefRect);
var
  TempScale : single;
begin                     
  TempScale   := Panel1.ScreenScale;
  rect.x      := 0;
  rect.y      := 0;
  rect.width  := DeviceToLogical(Panel1.Width,  TempScale);
  rect.height := DeviceToLogical(Panel1.Height, TempScale);
end;

procedure TForm1.Chromium1OpenUrlFromTab(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const targetUrl: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean; out
  Result: Boolean);
begin
  // For simplicity, this demo blocks all popup windows and new tabs
  Result := (targetDisposition in [WOD_NEW_FOREGROUND_TAB, WOD_NEW_BACKGROUND_TAB, WOD_NEW_POPUP, WOD_NEW_WINDOW]);
end;

procedure TForm1.Chromium1Paint(Sender: TObject; const browser: ICefBrowser;
  type_: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; aWidth, aHeight: Integer
  );
var
  src, dst: PByte;
  i, j, TempLineSize, TempSrcOffset, TempDstOffset, SrcStride : Integer;
  n : NativeUInt;
  TempWidth, TempHeight : integer;
  TempBufferBits : Pointer;
  TempForcedResize : boolean;
  TempBitmap : TCEFBitmapBitBuffer;
  TempSrcRect : TRect;
begin
  try
    FResizeCS.Acquire;
    TempForcedResize := False;

    if Panel1.BeginBufferDraw then
      begin
        if (type_ = PET_POPUP) then
          begin
            Panel1.UpdatePopupBufferDimensions(aWidth, aHeight);

            TempBitmap := Panel1.PopupBuffer;
            TempWidth  := Panel1.PopupBufferWidth;
            TempHeight := Panel1.PopupBufferHeight;
          end
         else
          begin
            TempForcedResize := Panel1.UpdateBufferDimensions(aWidth, aHeight) or
                                not(Panel1.BufferIsResized(False));

            TempBitmap := Panel1.Buffer;
            TempWidth  := Panel1.BufferWidth;
            TempHeight := Panel1.BufferHeight;
          end;

        SrcStride := aWidth * SizeOf(TRGBQuad);
        n         := 0;

        while (n < dirtyRectsCount) do
          begin
            if (dirtyRects^[n].x >= 0) and (dirtyRects^[n].y >= 0) then
              begin
                TempLineSize := min(dirtyRects^[n].width, TempWidth - dirtyRects^[n].x) * SizeOf(TRGBQuad);

                if (TempLineSize > 0) then
                  begin
                    TempSrcOffset := ((dirtyRects^[n].y * aWidth) + dirtyRects^[n].x) * SizeOf(TRGBQuad);
                    TempDstOffset := (dirtyRects^[n].x * SizeOf(TRGBQuad));

                    src := @PByte(buffer)[TempSrcOffset];

                    i := 0;
                    j := min(dirtyRects^[n].height, TempHeight - dirtyRects^[n].y);

                    while (i < j) do
                      begin
                        TempBufferBits := TempBitmap.Scanline[dirtyRects^[n].y + i];
                        dst            := @PByte(TempBufferBits)[TempDstOffset];

                        Move(src^, dst^, TempLineSize);

                        Inc(src, SrcStride);
                        inc(i);
                      end;
                  end;
              end;

            inc(n);
          end;

        if FShowPopup then
          begin
            TempSrcRect := Rect(0, 0,
                                FPopUpRect.Right  - FPopUpRect.Left,
                                FPopUpRect.Bottom - FPopUpRect.Top);

            Panel1.DrawPopupBuffer(TempSrcRect, FPopUpRect);
          end;

        Panel1.EndBufferDraw;

        SendCompMessage(CEF_PENDINGINVALIDATE);

        if (type_ = PET_VIEW) then
          begin
            if TempForcedResize or FPendingResize then
              SendCompMessage(CEF_PENDINGRESIZE);

            FResizing      := False;
            FPendingResize := False;
          end;
      end;
  finally
    FResizeCS.Release;
  end;
end;

procedure TForm1.Chromium1PopupShow(Sender: TObject; const browser: ICefBrowser; aShow: Boolean);
begin
  if aShow then
    FShowPopUp := True
   else
    begin
      FShowPopUp := False;
      FPopUpRect := rect(0, 0, 0, 0);

      if (Chromium1 <> nil) then Chromium1.Invalidate(PET_VIEW);
    end;
end;

procedure TForm1.Chromium1PopupSize(Sender: TObject; const browser: ICefBrowser; const rect: PCefRect);
begin
  LogicalToDevice(rect^, Panel1.ScreenScale);

  FPopUpRect.Left   := rect^.x;
  FPopUpRect.Top    := rect^.y;
  FPopUpRect.Right  := rect^.x + rect^.width  - 1;
  FPopUpRect.Bottom := rect^.y + rect^.height - 1;
end;

procedure TForm1.Chromium1Tooltip(Sender: TObject; const browser: ICefBrowser; var aText: ustring; out Result: Boolean);
begin
  PanelHint := aText;
  Result    := True;

  SendCompMessage(CEF_UPDATE_HINT);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := FCanClose;

  if not(FClosing) then
    begin
      FClosing := True;
      Visible  := False;
      Chromium1.CloseBrowser(True);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FPopUpRect      := rect(0, 0, 0, 0);
  FShowPopUp      := False;
  FResizing       := False;
  FPendingResize  := False;
  FCanClose       := False;
  FClosing        := False;
  FResizeCS       := TCriticalSection.Create;
  FBrowserCS      := TCriticalSection.Create;

  ConnectKeyPressReleaseEvents(PGtkWidget(Panel1.Handle));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if (FResizeCS  <> nil) then FreeAndNil(FResizeCS);
  if (FBrowserCS <> nil) then FreeAndNil(FBrowserCS);
end;

procedure TForm1.FormHide(Sender: TObject);
begin
  Chromium1.SendFocusEvent(False);
  Chromium1.WasHidden(True);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  if Chromium1.Initialized then
    begin
      Chromium1.WasHidden(False);
      Chromium1.SendFocusEvent(True);
    end
   else
    begin
      // We have to update the DeviceScaleFactor here to get the scale of the
      // monitor where the main application form is located.
      GlobalCEFApp.UpdateDeviceScaleFactor;

      // opaque white background color
      Chromium1.Options.BackgroundColor := CefColorSetARGB($FF, $FF, $FF, $FF);  
      Chromium1.DefaultURL              := UTF8Decode(AddressEdt.Text);

      if not(Chromium1.CreateBrowser) then Timer1.Enabled := True;
    end;
end;

procedure TForm1.GoBtnEnter(Sender: TObject);
begin
  Chromium1.SendFocusEvent(False);
end;

procedure TForm1.SnapshotBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Panel1.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  if not(Chromium1.CreateBrowser) and not(Chromium1.Initialized) then
    Timer1.Enabled := True;
end;

procedure TForm1.BrowserCreatedMsg(Data: PtrInt);
begin
  Caption            := 'Simple OSR Browser';
  AddressPnl.Enabled := True;
end;

procedure TForm1.BrowserCloseFormMsg(Data: PtrInt);
begin
  Close;
end;  

procedure TForm1.PendingResizeMsg(Data: PtrInt);
begin
  DoResize;
end;

procedure TForm1.PendingInvalidateMsg(Data: PtrInt);
begin
  Panel1.Invalidate;
end;

procedure TForm1.PendingCursorUpdateMsg(Data: PtrInt);
begin
  Panel1.Cursor := PanelCursor;
end;

procedure TForm1.PendingHintUpdateMsg(Data: PtrInt);
begin
  Panel1.hint     := PanelHint;
  Panel1.ShowHint := (length(Panel1.hint) > 0);
end;

procedure TForm1.SendCompMessage(aMsg : cardinal);
begin
  case aMsg of
    CEF_AFTERCREATED      : Application.QueueAsyncCall(@BrowserCreatedMsg, 0);
    CEF_BEFORECLOSE       : Application.QueueAsyncCall(@BrowserCloseFormMsg, 0);
    CEF_PENDINGRESIZE     : Application.QueueAsyncCall(@PendingResizeMsg, 0);
    CEF_PENDINGINVALIDATE : Application.QueueAsyncCall(@PendingInvalidateMsg, 0);
    CEF_UPDATE_CURSOR     : Application.QueueAsyncCall(@PendingCursorUpdateMsg, 0);
    CEF_UPDATE_HINT       : Application.QueueAsyncCall(@PendingHintUpdateMsg, 0);
  end;
end;    

procedure TForm1.DoResize;
begin
  try
    FResizeCS.Acquire;

    if FResizing then
      FPendingResize := True
     else
      if Panel1.BufferIsResized then
        Chromium1.Invalidate(PET_VIEW)
       else
        begin
          FResizing := True;
          Chromium1.WasResized;
        end;
  finally
    FResizeCS.Release;
  end;
end;     

function TForm1.GetPanelCursor : TCursor;
begin
  try
    FBrowserCS.Acquire;
    Result := FPanelCursor;
  finally
    FBrowserCS.Release;
  end;
end;

function TForm1.GetPanelHint : ustring;
begin
  try
    FBrowserCS.Acquire;
    Result := FPanelHint;
  finally
    FBrowserCS.Release;
  end;
end;

procedure TForm1.SetPanelCursor(aValue : TCursor);
begin
  try
    FBrowserCS.Acquire;
    FPanelCursor := aValue;
  finally
    FBrowserCS.Release;
  end;
end;

procedure TForm1.SetPanelHint(const aValue : ustring);
begin
  try
    FBrowserCS.Acquire;
    FPanelHint := aValue;
  finally
    FBrowserCS.Release;
  end;
end;

end.

