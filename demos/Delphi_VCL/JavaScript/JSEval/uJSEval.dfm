object JSEvalFrm: TJSEvalFrm
  Left = 0
  Top = 0
  Caption = 'JSEval'
  ClientHeight = 571
  ClientWidth = 878
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 30
    Width = 878
    Height = 541
    Align = alClient
    TabOrder = 0
  end
  object AddressBarPnl: TPanel
    Left = 0
    Top = 0
    Width = 878
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    DoubleBuffered = True
    Enabled = False
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    ParentDoubleBuffered = False
    TabOrder = 1
    object GoBtn: TButton
      Left = 842
      Top = 5
      Width = 31
      Height = 20
      Margins.Left = 5
      Align = alRight
      Caption = 'Go'
      TabOrder = 0
      OnClick = GoBtnClick
    end
    object AddressEdt: TEdit
      Left = 5
      Top = 5
      Width = 837
      Height = 20
      Align = alClient
      TabOrder = 1
      Text = 'https://www.google.com'
      ExplicitHeight = 21
    end
  end
  object Chromium1: TChromium
    OnProcessMessageReceived = Chromium1ProcessMessageReceived
    OnBeforeContextMenu = Chromium1BeforeContextMenu
    OnContextMenuCommand = Chromium1ContextMenuCommand
    OnBeforePopup = Chromium1BeforePopup
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnClose = Chromium1Close
    Left = 16
    Top = 40
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 16
    Top = 96
  end
  object CEFSentinel1: TCEFSentinel
    OnClose = CEFSentinel1Close
    Left = 16
    Top = 160
  end
end
