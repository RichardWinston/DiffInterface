unit MainUnit;

interface

// http://gnuwin32.sourceforge.net/packages/diffutils.htm

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, JvBaseDlg, JvSelectDirectory, JvExStdCtrls,
  JvRichEdit, ExtCtrls, Mask, JvExMask, JvToolEdit, ASLink, Contnrs, JvEdit,
  JvValidateEdit, Buttons;
                               
type
  TFileDifferences = class;

  TFileDifference = class(TObject)
  public
    Parent: TFileDifferences;
    File1LineId: string;
    File2LineID: string;
    Differences: TStringList;
    Node: TTreeNode;
    Constructor Create;
    Destructor Destroy; override;
  end;

  TFileDifferences = class(TObject)
  strict
  private
    FDifferences: TList;
    function GetCount: integer;
    function GetDifferences(const Index: integer): TFileDifference;
    procedure SetDifferences(const Index: integer;
      const Value: TFileDifference);
  public
    FirstFile: string;
    SecondFile: string;
    property Differences[const Index: integer]: TFileDifference
      read GetDifferences write SetDifferences; default;
    procedure Clear;
    Constructor Create;
    Destructor Destroy; override;
    procedure Add(ADiff: TFileDifference);
    property Count: integer read GetCount;
    procedure Remove(const Index: integer);
    function IndexOf(Const Diff: TFileDifference): integer;
  end;

  TfrmMain = class(TForm)
    fneDiff: TJvFilenameEdit;
    Splitter1: TSplitter;
    JvSelectDirectory1: TJvSelectDirectory;
    pnlFilesToCompare: TPanel;
    spltCompare: TSplitter;
    memoLinesToIgnore: TMemo;
    pbarProgress: TProgressBar;
    pcDifferences: TPageControl;
    tabDiffLocation: TTabSheet;
    tabIgnoreOptions: TTabSheet;
    tabFilesToCompare: TTabSheet;
    tabComparisons: TTabSheet;
    pnlBottom: TPanel;
    spltFiles: TSplitter;
    lblDiff: TLabel;
    lblIgnoreOptions: TLabel;
    pnlMissingFiles: TPanel;
    memoMissingFiles: TMemo;
    lblMissingFiles: TLabel;
    pnlTestFiles: TPanel;
    memoTestFiles: TMemo;
    lblTestFiles: TLabel;
    pnlArchiveFiles: TPanel;
    memoArchiveFiles: TMemo;
    lblArchiveFiles: TLabel;
    pnlComparisons: TPanel;
    jvredComparisons: TJvRichEdit;
    lblComparisons: TLabel;
    pnlDifferenceTree: TPanel;
    tvDifferences: TTreeView;
    lblDifferenceTree: TLabel;
    aslDiffUrl: TASLink;
    Panel2: TPanel;
    jvedIgnoreLimitRelative: TJvValidateEdit;
    Label1: TLabel;
    Label2: TLabel;
    jvedIgnoreLimitAbsolute: TJvValidateEdit;
    Panel3: TPanel;
    btnSelectFiles: TButton;
    btnNext: TBitBtn;
    btnBack: TBitBtn;
    Panel1: TPanel;
    btnSearch: TButton;
    fdFindText: TFindDialog;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure fneDiffChange(Sender: TObject);
    procedure btnSelectFilesClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure fdFindTextFind(Sender: TObject);
    procedure fdFindTextShow(Sender: TObject);
    procedure tvDifferencesChange(Sender: TObject; Node: TTreeNode);
  private
    TestDirectory: string;
    ArchiveDirectory: string;
    FirstFileIdentified: boolean;
    SecondFileIdentified: boolean;
    SelectionStart, SelectionEnd: integer;
    // @name is implemented as TObjectList;
    FileDifferences: TList;
    CurrentFileDifferences: TFileDifferences;
    CurrentDiff: TFileDifference;
    RelativeDifference: double;
    AbsoluteDifference: double;
    DiffGroupStartIndex: Integer;
    DiffStartIndex: Integer;
    SearchCharStartIndex: integer;
    procedure ProcessOuput(const Text: string);
    procedure FillTree;
    procedure RemoveExtraneousDifferences;
    procedure GetFiles;
    procedure CompareFiles;
    procedure IndentifyChangedLines(const Text: string);
    function ExtractWord(var AString: string): string;
    function WordsAreDifferent(const Word1, Word2: string): boolean;
    function LinesAreDifferent(Line1, Line2: string; IgnoreList: TStringList): boolean;
    procedure ExtractWords(Words1, Words2: TStringList; Line1, Line2: string);
    procedure FillFileLists;
    function IniFileName: string;
    procedure ReadIniFile;
    procedure WriteIniFile;
    procedure FillIgnoreList(IgnoreList: TStringList);
    function ShouldIgnoreLine(Line: string; IgnoreList: TStringList): boolean;
    procedure InitializeStartSearchIndicies;
    function TryFortranStrToFloat(const Word: string; out Value: double): boolean;



  { Private declarations }
  { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses JclSysUtils, IntListUnit, StrUtils, IniFiles;

resourcestring
  StrDirectories = 'Directories';
  StrDiffLocation = 'Diff Location';
  StrArchiveDirectory = 'Archive Directory';
  StrTestDirectory = 'Test Directory';
  StrIgnoreTerms = 'Ignore Terms';
  StrIgnoreTerm = 'Ignore Term ';
  StrIgnoreValues = 'Ignore Values';
  StrRelativeDifference = 'Relative Difference';
  StrAbsoluteDifference = 'Absolute Difference';

function ParentDir(const ADirectory: string): string;
var
  LastPathDelimPosition: integer;
  CharIndex: Integer;
begin
  LastPathDelimPosition := -1;
  for CharIndex := Length(ADirectory) downto 1 do
  begin
    if ADirectory[CharIndex] = PathDelim then
    begin
      LastPathDelimPosition := CharIndex;
      break;
    end;
  end;
  if LastPathDelimPosition > 0 then
  begin
    result := Copy(ADirectory, 1, LastPathDelimPosition-1);
  end
  else
  begin
    result := '';
  end;
end;

// http://www.festra.com/eng/snip04.htm
// Recursive procedure to build a list of files
procedure FindFiles(FilesList: TStringList; StartDir, FileMask: string);
var
  SR: TSearchRec;
  DirList: TStringList;
  IsFound: Boolean;
  i: integer;
begin
  if StartDir[length(StartDir)] <> '\' then
    StartDir := StartDir + '\';

  { Build a list of the files in directory StartDir
     (not the directories!)                         }

  IsFound :=
    FindFirst(StartDir+FileMask, faAnyFile-faDirectory, SR) = 0;
  while IsFound do begin
    FilesList.Add(StartDir + SR.Name);
    IsFound := FindNext(SR) = 0;
  end;
  FindClose(SR);

  // Build a list of subdirectories
  DirList := TStringList.Create;
  IsFound := FindFirst(StartDir+'*.*', faAnyFile, SR) = 0;
  while IsFound do begin
    if ((SR.Attr and faDirectory) <> 0) and
         (SR.Name[1] <> '.') then
      DirList.Add(StartDir + SR.Name);
    IsFound := FindNext(SR) = 0;
  end;
  FindClose(SR);

  // Scan the list of subdirectories
  for i := 0 to DirList.Count - 1 do
    FindFiles(FilesList, DirList[i], FileMask);

  DirList.Free;
end;

function TfrmMain.ExtractWord(var AString: string): string;
var
  TrimPos: integer;
  Positions: TIntegerList;
  TrimIndex: Integer;
  MinusPos: integer;
  Dummy: double;
begin
  AString := Trim(AString);
  Positions := TIntegerList.Create;
  try
    Positions.Add(Pos(' ', AString));
    Positions.Add(Pos(',', AString));
    Positions.Add(Pos('(', AString));
    Positions.Add(Pos(')', AString));
    Positions.Add(Pos('"', AString));
    Positions.Add(Pos('=', AString));
    Positions.Add(Pos('''', AString));
    Positions.Add(Pos(':', AString));
    Positions.Sort;
    TrimPos := 0;
    for TrimIndex := 0 to Positions.Count - 1 do
    begin
      if Positions[TrimIndex] > TrimPos then
      begin
        TrimPos := Positions[TrimIndex];
        break;
      end;
    end;
    MinusPos := Pos('-', AString);
    if MinusPos = 1 then
    begin
      MinusPos := PosEx('-', AString, 2);
    end;
    while (MinusPos > 1) and ((TrimPos = 0) or (MinusPos < TrimPos)) do
    begin
      if (AString[MinusPos-1] in
        ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
      begin
        if TryFortranStrToFloat(Copy(AString, 1, Pred(MinusPos)), Dummy) then
        begin
          TrimPos := MinusPos;
          break
        end
        else
        begin
          MinusPos := PosEx('-', AString, Succ(MinusPos));
        end;
      end
      else
      begin
        MinusPos := PosEx('-', AString, Succ(MinusPos));
      end;
    end;
  finally
    Positions.Free;
  end;
  if (TrimPos > 0) then
  begin
    if TrimPos = 1 then
    begin
      result := Copy(AString, 1,1);
      AString := Copy(AString, 2, MAXINT);
    end
    else
    begin
      result := Copy(AString, 1,Pred(TrimPos));
      AString := Copy(AString, Succ(TrimPos), MAXINT);
    end;
  end
  else
  begin
    result := AString;
    AString := '';
  end;
end;

function TfrmMain.TryFortranStrToFloat(const Word: string; out Value: double): boolean;
var
  TestWord: string;
begin
  result := TryStrToFloat(Word, Value);
  if not result then
  begin
    TestWord := StringReplace(Word, 'D', 'E', [rfIgnoreCase]);
    result := TryStrToFloat(TestWord, Value);
  end;
end;

function TfrmMain.WordsAreDifferent(const Word1, Word2: string): Boolean;
var
  E: Integer;
  Val2: Double;
  Val1: Double;
  TestWord: string;
begin
  result := False;
  if Word1 <> Word2 then
  begin
    if not TryFortranStrToFloat(Word1, Val1) then
    begin
      result := True;
      Exit;
    end;
    if not TryFortranStrToFloat(Word2, Val2) then
    begin
      result := True;
      Exit;
    end;
//    Val(Word1, Val1, E);
//    if E <> 0 then
//    begin
//      TestWord := StringReplace(Word1, 'D', 'E', [rfIgnoreCase]);
//      Val(TestWord, Val1, E);
//      if E <> 0 then
//      begin
//        result := True;
//        Exit;
//      end;
//    end;
//    Val(Word2, Val2, E);
//    if E <> 0 then
//    begin
//      TestWord := StringReplace(Word2, 'D', 'E', [rfIgnoreCase]);
//      Val(TestWord, Val2, E);
//      if E <> 0 then
//      begin
//        result := True;
//        Exit;
//      end;
//    end;
    if (Abs(Val1 - Val2) > AbsoluteDifference)
      and (Abs(Val1 - Val2) / (Abs(Val1) + Abs(Val2)) > RelativeDifference) then
    begin
      result := True;
    end;
  end;
end;

procedure TfrmMain.WriteIniFile;
var
  IniFile: TIniFile;
  Index: integer;
begin
  IniFile := TIniFile.Create(IniFileName);
  try
    IniFile.WriteString(StrDirectories, StrDiffLocation, fneDiff.Text);
    IniFile.WriteString(StrDirectories, StrArchiveDirectory, ArchiveDirectory);
    IniFile.WriteString(StrDirectories, StrTestDirectory, TestDirectory);

    IniFile.EraseSection(StrIgnoreTerms);
    for Index := 0 to memoLinesToIgnore.Lines.Count - 1 do
    begin
      if (memoLinesToIgnore.Lines[Index] <> '')
        and (memoLinesToIgnore.Lines[Index] <> ArchiveDirectory)
        and (memoLinesToIgnore.Lines[Index] <> TestDirectory) then
      begin
        IniFile.WriteString(StrIgnoreTerms, StrIgnoreTerm + IntToStr(Index),
          memoLinesToIgnore.Lines[Index]);
      end;
    end;

    IniFile.WriteFloat(StrIgnoreValues, StrRelativeDifference, RelativeDifference);
    IniFile.WriteFloat(StrIgnoreValues, StrAbsoluteDifference, AbsoluteDifference);

    IniFile.UpdateFile;
  finally
    IniFile.Free;
  end;
end;

procedure TfrmMain.FillIgnoreList(IgnoreList: TStringList);
var
  IgnoreIndex: Integer;
begin
  for IgnoreIndex := 0 to memoLinesToIgnore.Lines.Count - 1 do
  begin
    IgnoreList.Add(LowerCase(memoLinesToIgnore.Lines[IgnoreIndex]));
  end;
end;

function TfrmMain.ShouldIgnoreLine(Line: string; IgnoreList: TStringList): boolean;
var
  IgnoreIndex: Integer;
begin
  result := False;
  Line := LowerCase(Line);
  if (Line = '+') or (Line = '-') then
  begin
    result := True;
    Exit;
  end;
  for IgnoreIndex := 0 to IgnoreList.Count - 1 do
  begin
    if Pos(IgnoreList[IgnoreIndex], Line) > 0 then
    begin
      result := True;
      break;
    end;
  end;
end;

procedure TfrmMain.InitializeStartSearchIndicies;
var
  ADiff: TFileDifference;
begin
  if tvDifferences.Selected = nil then
  begin
    DiffGroupStartIndex := 0;
    DiffStartIndex := 0;
    SearchCharStartIndex := 0;
  end
  else
  begin
    ADiff := tvDifferences.Selected.Data;
    if ADiff = nil then
    begin
      DiffGroupStartIndex := 0;
      DiffStartIndex := 0;
      SearchCharStartIndex := 0;
    end
    else
    begin
      DiffStartIndex := ADiff.Parent.IndexOf(ADiff);
      DiffGroupStartIndex := FileDifferences.IndexOf(ADiff.Parent);
      SearchCharStartIndex := jvredComparisons.GetSelection.cpMax;

    end;
  end;
end;

procedure TfrmMain.ExtractWords(Words1, Words2: TStringList; Line1, Line2: string);
begin
  while (Line1 <> '') do
  begin
    Words1.Add(ExtractWord(Line1));
  end;
  while (Line2 <> '') do
  begin
    Words2.Add(ExtractWord(Line2));
  end;
end;

procedure TfrmMain.FillFileLists;
var
  AlternateFileName: string;
  FileIndex: Integer;
  ArchiveFiles: TStringList;
  TestFiles: TStringList;
begin
  TestFiles := TStringList.Create;
  ArchiveFiles := TStringList.Create;
  try
    FindFiles(TestFiles, TestDirectory, '*.*');
    FindFiles(ArchiveFiles, ArchiveDirectory, '*.*');
    TestFiles.Sort;
    ArchiveFiles.Sort;
    for FileIndex := TestFiles.Count - 1 downto 0 do
    begin
      AlternateFileName := StringReplace(TestFiles[FileIndex], TestDirectory,
        ArchiveDirectory, [rfIgnoreCase]);
      if ArchiveFiles.IndexOf(AlternateFileName) < 0 then
      begin
        memoMissingFiles.Lines.Add(AlternateFileName);
        TestFiles.Delete(FileIndex);
      end;
    end;
    for FileIndex := ArchiveFiles.Count - 1 downto 0 do
    begin
      AlternateFileName := StringReplace(ArchiveFiles[FileIndex], ArchiveDirectory,
        TestDirectory, [rfIgnoreCase]);
      if TestFiles.IndexOf(AlternateFileName) < 0 then
      begin
        memoMissingFiles.Lines.Add(AlternateFileName);
        ArchiveFiles.Delete(FileIndex);
      end;
    end;
    memoTestFiles.Lines := TestFiles;
    memoArchiveFiles.Lines := ArchiveFiles;
    if memoMissingFiles.Lines.Count > 0 then
    begin
      pnlMissingFiles.Visible := True;
      spltFiles.Visible := True;
      spltFiles.Top := 0;
    end;
  finally
    TestFiles.Free;
    ArchiveFiles.Free;
  end;
end;

function TfrmMain.LinesAreDifferent(Line1, Line2: string; IgnoreList: TStringList): Boolean;
var
  WordIndex: Integer;
  Words2: TStringList;
  Words1: TStringList;
begin
  result := False;
  if ShouldIgnoreLine(Line1, IgnoreList) then
  begin
    if ShouldIgnoreLine(Line2, IgnoreList) then
    begin
      Exit;
    end;
  end;

  Words1 := TStringList.Create;
  Words2 := TStringList.Create;
  try
    ExtractWords(Words1, Words2, Line1, Line2);
    if Words1.Count <> Words2.Count then
    begin
      result := True;
    end
    else
    begin
      for WordIndex := 0 to Words1.Count - 1 do
      begin
        if WordsAreDifferent(Words1[WordIndex], Words2[WordIndex]) then
        begin
          result := True;
          Break;
        end;
      end;
    end;
  finally
    Words1.Free;
    Words2.Free;
  end;
end;

procedure TfrmMain.ReadIniFile;
var
  IniFile: TIniFile;
  Index: integer;
  IgnoreValues: TStringList;
begin
  if not FileExists(IniFileName) then
  begin
    Exit;
  end;
  IniFile := TIniFile.Create(IniFileName);
  try
    fneDiff.Text := IniFile.ReadString(StrDirectories, StrDiffLocation, fneDiff.Text);
    ArchiveDirectory := IniFile.ReadString(StrDirectories, StrArchiveDirectory, '');
    TestDirectory := IniFile.ReadString(StrDirectories, StrTestDirectory, '');

    if DirectoryExists(ArchiveDirectory) and DirectoryExists(TestDirectory) then
    begin
      FillFileLists;
    end;

    IgnoreValues := TStringList.Create;
    try
      memoLinesToIgnore.Lines.Clear;
      IniFile.ReadSectionValues(StrIgnoreTerms, IgnoreValues);
      for Index := 0 to IgnoreValues.Count - 1 do
      begin
        memoLinesToIgnore.Lines.Add(IgnoreValues.ValueFromIndex[Index]);
      end;
    finally
      IgnoreValues.Free;
    end;

    RelativeDifference := IniFile.ReadFloat(StrIgnoreValues, StrRelativeDifference, 0);
    jvedIgnoreLimitRelative.Value := RelativeDifference;
    AbsoluteDifference := IniFile.ReadFloat(StrIgnoreValues, StrAbsoluteDifference, 0);
    jvedIgnoreLimitAbsolute.Value := AbsoluteDifference;
  finally
    IniFile.Free;
  end;
end;

procedure TfrmMain.RemoveExtraneousDifferences;
var
  FileIndex: integer;
  FileDifference: TFileDifferences;
  DifferenceIndex: integer;
  ADiff: TFileDifference;
  LineIndex: integer;
  ALine: string;
  FirstChar: string;
  lcTestDir: string;
  lcArchiveDir: string;
  ZeroElements: string;
  KeepDif: boolean;
  IgnoreList: TStringList;
  NextLineToCheck: integer;
  Version1, Version2: TStringList;
  VersionIndex: integer;
  TempLine: string;
  TempLine1: string;
  TempLine2: string;
begin
  RelativeDifference := jvedIgnoreLimitRelative.Value;
  AbsoluteDifference := jvedIgnoreLimitAbsolute.Value;
  IgnoreList := TStringlist.Create;
  try
    FillIgnoreList(IgnoreList);

    lcTestDir := LowerCase(TestDirectory);
    lcArchiveDir := LowerCase(ArchiveDirectory);
    ZeroElements := LowerCase('ELEMENTS OF RZ ARRAY USED OUT OF');
    for FileIndex := 0 to FileDifferences.Count - 1 do
    begin
      FileDifference := FileDifferences[FileIndex];
      for DifferenceIndex  := FileDifference.Count - 1 downto 0 do
      begin
        ADiff := FileDifference.Differences[DifferenceIndex];
        KeepDif := False;
        NextLineToCheck := 0;
        for LineIndex := 0 to ADiff.Differences.Count - 1 do
        begin
          if LineIndex < NextLineToCheck then
          begin
            Continue;
          end;
          ALine := ADiff.Differences[LineIndex];
          FirstChar := Copy(ALine, 1, 1);
          if (FirstChar = '+') or (FirstChar = '-')  then
          begin
            ALine := LowerCase(ALine);
            Version1 := TStringList.Create;
            Version2 := TStringList.Create;
            try
              for VersionIndex := LineIndex to ADiff.Differences.Count - 1 do
              begin
                TempLine := ADiff.Differences[VersionIndex];
                FirstChar := Copy(TempLine, 1, 1);
                if (FirstChar = '+')  then
                begin
                  Version1.Add(Copy(TempLine,2,MaxInt));
                end
                else if (FirstChar = '-')  then
                begin
                  Version2.Add(Copy(TempLine,2,MaxInt));
                end
                else
                begin
                  NextLineToCheck := VersionIndex-1;
                  break;
                end;
                if VersionIndex = ADiff.Differences.Count - 1 then
                begin
                  NextLineToCheck := VersionIndex;
                end;
              end;
              for VersionIndex := Version1.Count -1 downto 0 do
              begin
                if ShouldIgnoreLine(Version1[VersionIndex], IgnoreList) then
                begin
                  Version1.Delete(VersionIndex);
                end;
              end;
              for VersionIndex := Version2.Count -1 downto 0 do
              begin
                if ShouldIgnoreLine(Version2[VersionIndex], IgnoreList) then
                begin
                  Version2.Delete(VersionIndex);
                end;
              end;

              if Version1.Count <> Version2.Count then
              begin
                KeepDif := True;
                break;
              end
              else
              begin
                for VersionIndex := 0 to Version1.Count - 1 do
                begin
                  TempLine1 := Version1[VersionIndex];
                  TempLine2 := Version2[VersionIndex];
                  if LinesAreDifferent(TempLine1, TempLine2, IgnoreList) then
                  begin
                    KeepDif := True;
                    break;
                  end;
                end;
                if KeepDif then
                begin
                  break;
                end;
              end;
            finally
              Version1.Free;
              Version2.Free;
            end;

            if KeepDif then
            begin
              break;
            end;
          end;
          Inc(NextLineToCheck);
        end;
        if not KeepDif then
        begin
          FileDifference.Remove(DifferenceIndex);
        end;
      end;
    end;
  finally
    IgnoreList.Free;
  end;
  for FileIndex := FileDifferences.Count - 1 downto 0 do
  begin
    FileDifference := FileDifferences[FileIndex];
    if FileDifference.Count = 0 then
    begin
      FileDifferences.Delete(FileIndex);
    end;
  end;
  btnSearch.Enabled := FileDifferences.Count > 0;
end;

procedure TfrmMain.GetFiles;
begin
  if JvSelectDirectory1.Execute then
  begin
    TestDirectory := JvSelectDirectory1.Directory + PathDelim + 'test';
    if not DirectoryExists(TestDirectory) then
    begin
      MessageDlg(TestDirectory + ' does not exist.', mtError, [mbOK], 0);
      Exit;
    end;
    ArchiveDirectory := JvSelectDirectory1.Directory + PathDelim + 'archive';
    if not DirectoryExists(ArchiveDirectory) then
    begin
      MessageDlg(ArchiveDirectory + ' does not exist.', mtError, [mbOK], 0);
      Exit;
    end;
    FillFileLists;
  end;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
begin
  fdFindText.Execute;
end;

procedure TfrmMain.btnSelectFilesClick(Sender: TObject);
begin
  GetFiles;
end;

procedure TfrmMain.CompareFiles;
var
  CompareFileIndex: Integer;
  CommandLine: string;
begin
  FileDifferences.Clear;
  jvredComparisons.Lines.Clear;
  SelectionStart := 0;
  SelectionEnd := 0;
  FirstFileIdentified := False;
  SecondFileIdentified := False;
  pbarProgress.Max := memoTestFiles.Lines.Count;
  pbarProgress.Position := 0;
  pbarProgress.Step := 1;
  for CompareFileIndex := 0 to memoTestFiles.Lines.Count - 1 do
  begin
    CommandLine := fneDiff.Text + ' -u ' + '"'
      + memoArchiveFiles.Lines[CompareFileIndex] + '"' + ' ' + '"'
      + memoTestFiles.Lines[CompareFileIndex] + '"';
    CurrentFileDifferences := TFileDifferences.Create;
    CurrentDiff := nil;
    FirstFileIdentified := False;
    SecondFileIdentified := False;
    FileDifferences.Add(CurrentFileDifferences);
    CurrentFileDifferences.FirstFile :=
      memoTestFiles.Lines[CompareFileIndex];
    CurrentFileDifferences.SecondFile :=
      memoArchiveFiles.Lines[CompareFileIndex];
    Execute(CommandLine, ProcessOuput);
    pbarProgress.StepIt;
  end;
  FillTree;
end;

procedure TfrmMain.IndentifyChangedLines(const Text: string);
var
  TrimText: string;
  CommaPos: Integer;
  Line1: Integer;
  SpacePos: Integer;
  Line2: Integer;
  ALine: string;
begin
  CurrentDiff := TFileDifference.Create;
  CurrentFileDifferences.Add(CurrentDiff);
  // line identifiers
  TrimText := Copy(Trim(Copy(Text, 3, Length(Text) - 4)), 2, MAXINT);
  CommaPos := Pos(',', TrimText);
  Assert(CommaPos > 1);
  Line1 := StrToInt(Copy(TrimText, 1, CommaPos - 1));
  TrimText := Trim(Copy(TrimText, CommaPos + 1, MAXINT));
  SpacePos := Pos(' ', TrimText);
  Assert(SpacePos > 1);
  Line2 := Line1 + StrToInt(Copy(TrimText, 1, SpacePos - 1)) - 1;
  ALine := CurrentFileDifferences.FirstFile + ': ' + 'Lines ' + IntToStr(Line1)
    + '-' + IntToStr(Line2);
  CurrentDiff.File1LineId := ALine;

  TrimText := Copy(Trim(Copy(TrimText, SpacePos + 1, MAXINT)), 2, MAXINT);
  CommaPos := Pos(',', TrimText);
  Assert(CommaPos > 1);
  Line1 := StrToInt(Copy(TrimText, 1, CommaPos - 1));
  TrimText := Trim(Copy(TrimText, CommaPos + 1, MAXINT));
  Line2 := Line1 + StrToInt(TrimText) - 1;
  ALine := CurrentFileDifferences.SecondFile + ': ' + 'Lines ' + IntToStr(Line1)
    + '-' + IntToStr(Line2);
  CurrentDiff.File2LineId := ALine;
end;

function TfrmMain.IniFileName: string;
begin
  result := ParamStr(0);
  result := ChangeFileExt(result, '.ini');
end;

procedure TfrmMain.FillTree;
var
  FileIndex: integer;
  FileDifference: TFileDifferences;
  PriorNode: TTreeNode;
  DifferenceIndex: integer;
  ADiff: TFileDifference;
begin
  RemoveExtraneousDifferences;
  tvDifferences.Items.Clear;
  PriorNode := nil;
  for FileIndex := 0 to FileDifferences.Count - 1 do
  begin
    FileDifference := FileDifferences[FileIndex];
    if FileDifference.Count > 0 then
    begin
      PriorNode := tvDifferences.Items.Add(PriorNode, FileDifference.FirstFile
        + ' & ' + FileDifference.SecondFile);
      for DifferenceIndex  := 0 to FileDifference.Count - 1 do
      begin
        ADiff := FileDifference.Differences[DifferenceIndex];
        ADiff.Node := tvDifferences.Items.AddChildObject(PriorNode,
          ADiff.File1LineId + ' & ' + ADiff.File2LineID, ADiff);
      end;
    end;
  end;
end;

procedure TfrmMain.fdFindTextFind(Sender: TObject);
var
  ADiff: TFileDifference;
  DiffGroupIndex: integer;
  DiffIndex: integer;
  DiffGroup: TFileDifferences;
  FoundInSameDiff: boolean;
  FindText: string;
  MatchCase: boolean;
  function FindSomeText: boolean;
  var
    LineIndex: integer;
    ALine: string;
    LineStart, LineEnd: integer;
    SearchPosition: integer;
    SelectionStart, SelectionEnd: integer;
  begin
    result := False;
    LineEnd := Length(ADiff.File1LineId) + Length(ADiff.File1LineId) + 4;
    for LineIndex := 0 to ADiff.Differences.Count - 1 do
    begin
      ALine := ADiff.Differences[LineIndex];
      LineStart := LineEnd;
      LineEnd := LineStart + Length(ALine) + 1;
      if FoundInSameDiff and (SearchCharStartIndex > LineEnd) then
      begin
        Continue;
      end;
      if not MatchCase then
      begin
        ALine := LowerCase(ALine);
      end;
      if FoundInSameDiff and (SearchCharStartIndex > LineStart) then
      begin
        SearchPosition := PosEx(FindText, ALine, SearchCharStartIndex-LineStart);
      end
      else
      begin
        SearchPosition := Pos(FindText, ALine);
      end;
      if SearchPosition > 0 then
      begin
        tvDifferences.Selected := ADiff.Node;
        result := True;
        tvDifferencesChange(nil, nil);
        SelectionStart := LineStart + SearchPosition;
        SelectionEnd := SelectionStart + Length(fdFindText.FindText);
        jvredComparisons.SetSelection(SelectionStart, SelectionEnd, True);
        SearchCharStartIndex := SelectionEnd;
        if not FoundInSameDiff then
        begin
          DiffStartIndex := DiffIndex;
          DiffGroupStartIndex := DiffGroupIndex;
        end;
        break;
      end;
    end;
  end;
begin
  FindText := fdFindText.FindText;
  MatchCase := frMatchCase in fdFindText.Options;
  if not MatchCase then
  begin
    FindText := LowerCase(FindText);
  end;

  FoundInSameDiff := True;
  DiffGroupIndex := DiffGroupStartIndex;
  DiffGroup := FileDifferences[DiffGroupIndex];
  DiffIndex := DiffStartIndex;
  ADiff := DiffGroup[DiffStartIndex];
  if FindSomeText then
  begin
    Exit;
  end;
  FoundInSameDiff := False;
  for DiffIndex := DiffStartIndex+1 to DiffGroup.Count - 1 do
  begin
    ADiff := DiffGroup[DiffIndex];
    if FindSomeText then
    begin
      Exit;
    end;
  end;
  for DiffGroupIndex := DiffGroupStartIndex+1 to FileDifferences.Count - 1 do
  begin
    DiffGroup := FileDifferences[DiffGroupIndex];
    for DiffIndex := 0 to DiffGroup.Count - 1 do
    begin
      ADiff := DiffGroup[DiffIndex];
      if FindSomeText then
      begin
        Exit;
      end;
    end;
  end;
  for DiffGroupIndex := 0 to DiffGroupStartIndex-1 do
  begin
    DiffGroup := FileDifferences[DiffGroupIndex];
    for DiffIndex := 0 to DiffGroup.Count - 1 do
    begin
      ADiff := DiffGroup[DiffIndex];
      if FindSomeText then
      begin
        Exit;
      end;
    end;
  end;
  DiffGroupIndex := DiffGroupStartIndex;
  DiffGroup := FileDifferences[DiffGroupIndex];
  for DiffIndex := 0 to DiffStartIndex - 1 do
  begin
    ADiff := DiffGroup[DiffIndex];
    if FindSomeText then
    begin
      Exit;
    end;
  end;
  MessageDlg('Text not found', mtInformation, [mbOK], 0);
end;

procedure TfrmMain.fdFindTextShow(Sender: TObject);
begin
  InitializeStartSearchIndicies;
end;

procedure TfrmMain.fneDiffChange(Sender: TObject);
var
  FileName: string;
begin
  FileName := fneDiff.Text;
  if Length(FileName) > 1 then
  begin
    if FileName[1] = '"' then
    begin
      FileName := Copy(FileName, 2, MAXINT);
    end;
    if Length(FileName) > 1 then
    begin
      if FileName[Length(FileName)] = '"' then
      begin
        FileName := Copy(FileName, 1, Length(FileName) -1);
      end;
    end;
  end;
  btnNext.Enabled := FileExists(FileName);
  if btnNext.Enabled then
  begin
    fneDiff.Color := clWindow;
  end
  else
  begin
    fneDiff.Color := clRed;
  end;
end;

procedure TfrmMain.btnBackClick(Sender: TObject);
begin
  pcDifferences.ActivePageIndex := pcDifferences.ActivePageIndex - 1;
  btnNext.Enabled := True;
  if pcDifferences.ActivePageIndex = 0 then
  begin
    btnBack.Enabled := False;
  end;

end;

procedure TfrmMain.btnNextClick(Sender: TObject);
begin
  if pcDifferences.ActivePageIndex + 1 = tabComparisons.PageIndex then
  begin
    CompareFiles
  end;
  pcDifferences.ActivePageIndex := pcDifferences.ActivePageIndex + 1;
  btnBack.Enabled := True;
  if pcDifferences.ActivePageIndex = pcDifferences.PageCount -1 then
  begin
    btnNext.Enabled := False;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FileDifferences:= TObjectList.Create;
  pcDifferences.ActivePageIndex := 0;
  pnlMissingFiles.Visible := False;
  spltFiles.Visible := False;
  ReadIniFile;
  fneDiffChange(nil);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  WriteIniFile;
  FileDifferences.Free;
end;

procedure TfrmMain.ProcessOuput(const Text: string);
begin
  if not FirstFileIdentified then
  begin
    if Copy(Text, 1, 3) = '---' then
    begin
      FirstFileIdentified := True;
    end;
    Exit;
  end
  else if not SecondFileIdentified then
  begin
    if Copy(Text, 1, 3) = '+++' then
    begin
      SecondFileIdentified := True;
    end;
    Exit;
  end
  else if Copy(Text, 1, 2) = '@@' then
  begin
    IndentifyChangedLines(Text);
    Exit;
  end;
  CurrentDiff.Differences.Add(Text);
  Application.ProcessMessages;
end;

procedure TfrmMain.tvDifferencesChange(Sender: TObject; Node: TTreeNode);
var
  ADiff: TFileDifference;
  SelectionStart, SelectionEnd:  integer;
  LineIndex: integer;
  LineStart: TIntegerList;
  LineEnd: TIntegerList;
  Version1, Version2: TStringList;
  FirstChar: string;
  VersionIndex: integer;
  VLineIndex1, VLineIndex2: TIntegerList;
  LIndex, LIndex1, LIndex2: integer;
  MajorDiff1, MajorDiff2: TColor;
  MinorDiff1, MinorDiff2: TColor;
  Line1, Line2: string;
  Limit1, Limit2: double;
  DifferentWords1, DifferentWords2: TStringList;
  WordIndex: Integer;
  WordPos: integer;
  OffSet: Integer;
  NextLineToTest: integer;
  Word1, Word2: string;
  IgnoreList: TStringList;
  procedure AddLine(const ALine: string);
  begin
    SelectionStart := SelectionEnd;
    SelectionEnd := SelectionEnd + Length(ALine) + 1;
    jvredComparisons.Lines.Add(ALine);
    LineStart.Add(SelectionStart);
    LineEnd.Add(SelectionEnd);
  end;
begin

  if tvDifferences.Selected = nil then
  begin
    Exit;
  end;
  ADiff := tvDifferences.Selected.Data;
  jvredComparisons.Lines.Clear;
  if ADiff = nil then
  begin
    Exit;
  end;
  pbarProgress.Position := 0;
  pbarProgress.Max := (ADiff.Differences.Count)*2;
  Screen.Cursor := crHourGlass;
  try
    IgnoreList := TStringlist.Create;
    try
      FillIgnoreList(IgnoreList);
      Limit1 := jvedIgnoreLimitRelative.Value;
      Limit2 := jvedIgnoreLimitAbsolute.Value;
      MajorDiff1 := clRed;
      MinorDiff1 := $C0C0FF;
      MajorDiff2 := clBlue;
      MinorDiff2 := clAqua;
      LineStart := TIntegerList.Create;
      LineEnd := TIntegerList.Create;
      try
        SelectionEnd := 0;
        AddLine(ADiff.File2LineId);
        jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
        jvredComparisons.SelAttributes.BackColor := MajorDiff2;
        jvredComparisons.SelAttributes.Color := clWhite;
        LineStart.Delete(0);
        LineEnd.Delete(0);

        AddLine(ADiff.File1LineId);
        jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
        jvredComparisons.SelAttributes.BackColor := MajorDiff1;
        jvredComparisons.SelAttributes.Color := clWhite;
        LineStart.Delete(0);
        LineEnd.Delete(0);

        for LineIndex := 0 to ADiff.Differences.Count - 1 do
        begin
          AddLine(ADiff.Differences[LineIndex]);
          pbarProgress.StepIt;
          Application.ProcessMessages;
        end;
        NextLineToTest := 0;
        for LineIndex := 0 to ADiff.Differences.Count - 1 do
        begin
          if NextLineToTest > LineIndex then
          begin
            Continue;
          end;
          Inc(NextLineToTest);
          FirstChar := Copy(ADiff.Differences[LineIndex], 1, 1);

          if (FirstChar = '-') or (FirstChar = '+') then
          begin
            Version1 := TStringList.Create;
            Version2 := TStringList.Create;
            VLineIndex1 := TIntegerList.Create;
            VLineIndex2 := TIntegerList.Create;
            try
              for VersionIndex := LineIndex to ADiff.Differences.Count - 1 do
              begin
                FirstChar := Copy(ADiff.Differences[VersionIndex], 1, 1);
                if FirstChar = '+' then
                begin
                  Version1.Add(ADiff.Differences[VersionIndex]);
                  VLineIndex1.Add(VersionIndex);
                end
                else if FirstChar = '-' then
                begin
                  Version2.Add(ADiff.Differences[VersionIndex]);
                  VLineIndex2.Add(VersionIndex);
                end
                else
                begin
                  break;
                end;
              end;

              NextLineToTest := NextLineToTest + Version1.Count + Version2.Count -1;
              if Version1.Count <> Version2.Count then
              begin
                for VersionIndex := 0 to VLineIndex1.Count - 1 do
                begin
                  pbarProgress.StepIt;
                  Application.ProcessMessages;
                  LIndex := VLineIndex1[VersionIndex];
                  SelectionStart := LineStart[LIndex];
                  SelectionEnd := LineEnd[LIndex];
                  jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
                  if ShouldIgnoreLine(Version1[VersionIndex], IgnoreList) then
                  begin
                    jvredComparisons.SelAttributes.BackColor := MinorDiff1;
                  end
                  else
                  begin
                    jvredComparisons.SelAttributes.BackColor := MajorDiff1;
                    jvredComparisons.SelAttributes.Color := clWhite;
                  end;
                end;
                for VersionIndex := 0 to VLineIndex2.Count - 1 do
                begin
                  pbarProgress.StepIt;
                  Application.ProcessMessages;
                  LIndex := VLineIndex2[VersionIndex];
                  SelectionStart := LineStart[LIndex];
                  SelectionEnd := LineEnd[LIndex];
                  jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
                  if ShouldIgnoreLine(Version2[VersionIndex], IgnoreList) then
                  begin
                    jvredComparisons.SelAttributes.BackColor := MinorDiff2;
                  end
                  else
                  begin
                    jvredComparisons.SelAttributes.BackColor := MajorDiff2;
                    jvredComparisons.SelAttributes.Color := clWhite;
                  end;
                end;
              end
              else
              begin
                for VersionIndex := 0 to VLineIndex1.Count - 1 do
                begin
                  pbarProgress.StepIt;
                  pbarProgress.StepIt;
                  Application.ProcessMessages;
                  Line1 := Version1[VersionIndex];
                  Line2 := Version2[VersionIndex];
                  LIndex := VLineIndex1[VersionIndex];
                  SelectionStart := LineStart[LIndex];
                  SelectionEnd := LineEnd[LIndex];
                  jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
                  jvredComparisons.SelAttributes.BackColor := MinorDiff1;

                  LIndex := VLineIndex2[VersionIndex];
                  SelectionStart := LineStart[LIndex];
                  SelectionEnd := LineEnd[LIndex];
                  jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
                  jvredComparisons.SelAttributes.BackColor := MinorDiff2;

                  if LinesAreDifferent(Copy(Line1,2,MAXINT), Copy(Line2,2,MAXINT), IgnoreList) then
                  begin
                    LIndex1 := VLineIndex1[VersionIndex];
                    SelectionStart := LineStart[LIndex1];
                    jvredComparisons.SetSelection(SelectionStart,SelectionStart + 1,False);
                    jvredComparisons.SelAttributes.BackColor := MajorDiff1;
                    jvredComparisons.SelAttributes.Color := clWhite;

                    LIndex2 := VLineIndex2[VersionIndex];
                    SelectionStart := LineStart[LIndex2];
                    jvredComparisons.SetSelection(SelectionStart,SelectionStart + 1,False);
                    jvredComparisons.SelAttributes.BackColor := MajorDiff2;
                    jvredComparisons.SelAttributes.Color := clWhite;

                    DifferentWords1 := TStringList.Create;
                    DifferentWords2 := TStringList.Create;
                    try
                      ExtractWords(DifferentWords1, DifferentWords2,
                        Copy(Line1,2,MAXINT), Copy(Line2,2,MAXINT));
                      if DifferentWords1.Count <> DifferentWords2.Count then
                      begin
                        LIndex := VLineIndex1[VersionIndex];
                        SelectionStart := LineStart[LIndex];
                        SelectionEnd := LineEnd[LIndex];
                        jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
                        jvredComparisons.SelAttributes.BackColor := MajorDiff1;
                        jvredComparisons.SelAttributes.Color := clWhite;

                        LIndex := VLineIndex2[VersionIndex];
                        SelectionStart := LineStart[LIndex];
                        SelectionEnd := LineEnd[LIndex];
                        jvredComparisons.SetSelection(SelectionStart,SelectionEnd-1,False);
                        jvredComparisons.SelAttributes.BackColor := MajorDiff2;
                        jvredComparisons.SelAttributes.Color := clWhite;
                      end
                      else
                      begin
                        OffSet := 1;
                        for WordIndex := 0 to DifferentWords1.Count - 1 do
                        begin
                          Word1 := DifferentWords1[WordIndex];
                          Word2 := DifferentWords2[WordIndex];
                          WordPos := PosEx(DifferentWords1[WordIndex], Line1, OffSet);
                          Assert(WordPos > 0);
                          OffSet := WordPos + Length(DifferentWords1[WordIndex]);
                          if WordsAreDifferent(Word1, Word2) then
                          begin
                            SelectionStart := LineStart[LIndex1] + WordPos -1;
                            SelectionEnd := SelectionStart + Length(DifferentWords1[WordIndex]);
                            jvredComparisons.SetSelection(SelectionStart,SelectionEnd,False);
                            jvredComparisons.SelAttributes.BackColor := MajorDiff1;
                            jvredComparisons.SelAttributes.Color := clWhite;
                          end;
                        end;
                        OffSet := 1;
                        for WordIndex := 0 to DifferentWords2.Count - 1 do
                        begin
                          Word1 := DifferentWords1[WordIndex];
                          Word2 := DifferentWords2[WordIndex];
                          WordPos := PosEx(DifferentWords2[WordIndex], Line2, OffSet);
                          Assert(WordPos > 0);
                          OffSet := WordPos + Length(DifferentWords2[WordIndex]);
                          if WordsAreDifferent(Word1, Word2) then
                          begin
                            SelectionStart := LineStart[LIndex2] + WordPos -1;
                            SelectionEnd := SelectionStart + Length(DifferentWords2[WordIndex]);
                            jvredComparisons.SetSelection(SelectionStart,SelectionEnd,False);
                            jvredComparisons.SelAttributes.BackColor := MajorDiff2;
                            jvredComparisons.SelAttributes.Color := clWhite;
                          end;
                        end;
                      end;
                    finally
                      DifferentWords1.Free;
                      DifferentWords2.Free;
                    end;
                  end;
                end;
              end;
            finally
              Version1.Free;
              Version2.Free;
              VLineIndex1.Free;
              VLineIndex2.Free;
            end;
          end
          else
          begin
            pbarProgress.StepIt;
            Application.ProcessMessages;
          end;
        end;
      finally
        LineStart.Free;
        LineEnd.Free;
      end;
    finally
      IgnoreList.Free;
    end;
    jvredComparisons.SetSelection(0,0,True);
    InitializeStartSearchIndicies;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{ TFileDifference }

constructor TFileDifference.Create;
begin
  inherited;
  Differences:= TStringList.Create;
end;

destructor TFileDifference.Destroy;
begin
  Differences.Free;
  inherited;
end;

{ TFileDifferences }

procedure TFileDifferences.Add(ADiff: TFileDifference);
begin
  FDifferences.Add(ADiff);
  ADiff.Parent := self;
end;

procedure TFileDifferences.Clear;
begin
  FDifferences.Clear;
end;

constructor TFileDifferences.Create;
begin
  inherited;
  FDifferences:= TObjectList.Create;
end;

destructor TFileDifferences.Destroy;
begin
  FDifferences.Free;
  inherited;
end;

function TFileDifferences.GetCount: integer;
begin
  result := FDifferences.Count;
end;

function TFileDifferences.GetDifferences(const Index: integer): TFileDifference;
begin
  result := FDifferences[Index];
end;

function TFileDifferences.IndexOf(const Diff: TFileDifference): integer;
begin
  result := FDifferences.IndexOf(Diff);
end;

procedure TFileDifferences.Remove(const Index: integer);
begin
  FDifferences.Delete(Index);
end;

procedure TFileDifferences.SetDifferences(const Index: integer;
  const Value: TFileDifference);
begin
  FDifferences[Index] := Value;
end;

end.
