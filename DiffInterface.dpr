program DiffInterface;

{%TogetherDiagram 'ModelSupport_DiffInterface\default.txaPackage'}

uses
  Forms,
  MainUnit in 'MainUnit.pas' {frmMain},
  IntListUnit in 'IntListUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
