object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Diff Interface'
  ClientHeight = 413
  ClientWidth = 495
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 19
  object pcDifferences: TPageControl
    Left = 0
    Top = 0
    Width = 495
    Height = 368
    ActivePage = tabComparisons
    Align = alClient
    TabOrder = 0
    object tabDiffLocation: TTabSheet
      Caption = 'tabDiffLocation'
      TabVisible = False
      object lblDiff: TLabel
        Left = 2
        Top = 3
        Width = 108
        Height = 19
        Caption = 'Location of Diff'
      end
      object aslDiffUrl: TASLink
        Left = 3
        Top = 61
        Width = 466
        Height = 20
        Cursor = crHandPoint
        Transparent = True
        Caption = 'http://gnuwin32.sourceforge.net/packages/diffutils.htm'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        URLTypeAdd = False
        URLType = utHttp
      end
      object fneDiff: TJvFilenameEdit
        Left = 2
        Top = 28
        Width = 396
        Height = 27
        Filter = '*.exe|*.exe'
        TabOrder = 0
        Text = '"C:\Program Files\GnuWin32\bin\diff.exe"'
        OnChange = fneDiffChange
      end
    end
    object tabFilesToCompare: TTabSheet
      Caption = 'tabFilesToCompare'
      ImageIndex = 2
      TabVisible = False
      object spltFiles: TSplitter
        Left = 0
        Top = 195
        Width = 487
        Height = 5
        Cursor = crVSplit
        Align = alBottom
        ExplicitTop = 197
      end
      object pnlFilesToCompare: TPanel
        Left = 0
        Top = 0
        Width = 487
        Height = 195
        Align = alClient
        TabOrder = 0
        object spltCompare: TSplitter
          Left = 241
          Top = 1
          Width = 5
          Height = 152
        end
        object pnlTestFiles: TPanel
          Left = 1
          Top = 1
          Width = 240
          Height = 152
          Align = alLeft
          TabOrder = 0
          object lblTestFiles: TLabel
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 232
            Height = 19
            Align = alTop
            Alignment = taCenter
            Caption = 'Test files'
            ExplicitWidth = 63
          end
          object memoTestFiles: TMemo
            Left = 1
            Top = 26
            Width = 238
            Height = 125
            Align = alClient
            TabOrder = 0
            WordWrap = False
          end
        end
        object pnlArchiveFiles: TPanel
          Left = 246
          Top = 1
          Width = 240
          Height = 152
          Align = alClient
          TabOrder = 1
          object lblArchiveFiles: TLabel
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 232
            Height = 19
            Align = alTop
            Alignment = taCenter
            Caption = 'Archive files'
            ExplicitWidth = 86
          end
          object memoArchiveFiles: TMemo
            Left = 1
            Top = 26
            Width = 238
            Height = 125
            Align = alClient
            TabOrder = 0
            WordWrap = False
          end
        end
        object Panel3: TPanel
          Left = 1
          Top = 153
          Width = 485
          Height = 41
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 2
          object btnSelectFiles: TButton
            Left = 4
            Top = 6
            Width = 181
            Height = 25
            Caption = 'Select parent directory'
            TabOrder = 0
            OnClick = btnSelectFilesClick
          end
        end
      end
      object pnlMissingFiles: TPanel
        Left = 0
        Top = 200
        Width = 487
        Height = 158
        Align = alBottom
        TabOrder = 1
        object lblMissingFiles: TLabel
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 479
          Height = 19
          Align = alTop
          Alignment = taCenter
          Caption = 'Missing files'
          ExplicitWidth = 85
        end
        object memoMissingFiles: TMemo
          Left = 1
          Top = 26
          Width = 485
          Height = 131
          Align = alClient
          TabOrder = 0
          WordWrap = False
        end
      end
    end
    object tabIgnoreOptions: TTabSheet
      Caption = 'tabIgnoreOptions'
      ImageIndex = 1
      TabVisible = False
      object lblIgnoreOptions: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 481
        Height = 38
        Align = alTop
        Alignment = taCenter
        Caption = 
          'Lines containing the following will be ignored when making compa' +
          'risons (case insensitive)'
        WordWrap = True
        ExplicitWidth = 426
      end
      object memoLinesToIgnore: TMemo
        Left = 0
        Top = 44
        Width = 487
        Height = 228
        Align = alClient
        Lines.Strings = (
          'version')
        TabOrder = 0
        WordWrap = False
      end
      object Panel2: TPanel
        Left = 0
        Top = 272
        Width = 487
        Height = 86
        Align = alBottom
        TabOrder = 1
        object Label1: TLabel
          Left = 3
          Top = 10
          Width = 270
          Height = 19
          Caption = 'Ignore fractional differences less than '
        end
        object Label2: TLabel
          Left = 3
          Top = 40
          Width = 264
          Height = 19
          Caption = 'Ignore absolute differences less than '
        end
        object jvedIgnoreLimitRelative: TJvValidateEdit
          Left = 283
          Top = 7
          Width = 121
          Height = 27
          CriticalPoints.MaxValueIncluded = False
          CriticalPoints.MinValueIncluded = False
          DisplayFormat = dfScientific
          DecimalPlaces = 4
          HasMinValue = True
          TabOrder = 0
        end
        object jvedIgnoreLimitAbsolute: TJvValidateEdit
          Left = 283
          Top = 37
          Width = 121
          Height = 27
          CriticalPoints.MaxValueIncluded = False
          CriticalPoints.MinValueIncluded = False
          DisplayFormat = dfScientific
          DecimalPlaces = 4
          HasMinValue = True
          TabOrder = 1
        end
      end
    end
    object tabComparisons: TTabSheet
      Caption = 'tabComparisons'
      ImageIndex = 3
      TabVisible = False
      object Splitter1: TSplitter
        Left = 0
        Top = 113
        Width = 487
        Height = 5
        Cursor = crVSplit
        Align = alTop
      end
      object pnlComparisons: TPanel
        Left = 0
        Top = 118
        Width = 487
        Height = 240
        Align = alClient
        TabOrder = 0
        object lblComparisons: TLabel
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 479
          Height = 19
          Align = alTop
          Alignment = taCenter
          Caption = 'File differences'
          ExplicitWidth = 105
        end
        object jvredComparisons: TJvRichEdit
          Left = 1
          Top = 26
          Width = 485
          Height = 172
          Align = alClient
          AutoSize = False
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          WordWrap = False
        end
        object Panel1: TPanel
          Left = 1
          Top = 198
          Width = 485
          Height = 41
          Align = alBottom
          TabOrder = 1
          object btnSearch: TButton
            Left = 3
            Top = 8
            Width = 75
            Height = 25
            Caption = 'Search'
            TabOrder = 0
            OnClick = btnSearchClick
          end
        end
      end
      object pnlDifferenceTree: TPanel
        Left = 0
        Top = 0
        Width = 487
        Height = 113
        Align = alTop
        TabOrder = 1
        object lblDifferenceTree: TLabel
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 479
          Height = 19
          Align = alTop
          Alignment = taCenter
          Caption = 'Files containing differences'
          ExplicitWidth = 190
        end
        object tvDifferences: TTreeView
          Left = 1
          Top = 26
          Width = 485
          Height = 86
          Align = alClient
          HideSelection = False
          Indent = 19
          TabOrder = 0
          OnChange = tvDifferencesChange
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 368
    Width = 495
    Height = 45
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      495
      45)
    object pbarProgress: TProgressBar
      Left = 171
      Top = 6
      Width = 315
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Step = 1
      TabOrder = 0
    end
    object btnNext: TBitBtn
      Left = 87
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Next'
      TabOrder = 1
      OnClick = btnNextClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        3333333333333333333333333333333333333333333FF3333333333333003333
        3333333333773FF3333333333309003333333333337F773FF333333333099900
        33333FFFFF7F33773FF30000000999990033777777733333773F099999999999
        99007FFFFFFF33333F7700000009999900337777777F333F7733333333099900
        33333333337F3F77333333333309003333333333337F77333333333333003333
        3333333333773333333333333333333333333333333333333333333333333333
        3333333333333333333333333333333333333333333333333333}
      Layout = blGlyphRight
      NumGlyphs = 2
    end
    object btnBack: TBitBtn
      Left = 6
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Back'
      Enabled = False
      TabOrder = 2
      OnClick = btnBackClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        3333333333333FF3333333333333003333333333333F77F33333333333009033
        333333333F7737F333333333009990333333333F773337FFFFFF330099999000
        00003F773333377777770099999999999990773FF33333FFFFF7330099999000
        000033773FF33777777733330099903333333333773FF7F33333333333009033
        33333333337737F3333333333333003333333333333377333333333333333333
        3333333333333333333333333333333333333333333333333333333333333333
        3333333333333333333333333333333333333333333333333333}
      NumGlyphs = 2
    end
  end
  object JvSelectDirectory1: TJvSelectDirectory
    ClassicDialog = False
    Options = [sdAllowCreate]
    Title = 'Select parent of test and archive directory'
    Left = 216
    Top = 56
  end
  object fdFindText: TFindDialog
    OnShow = fdFindTextShow
    Options = [frDown, frDisableUpDown, frDisableWholeWord]
    OnFind = fdFindTextFind
    Left = 200
    Top = 176
  end
end
