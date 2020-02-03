program Quick_Inventary;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Scr_Activa in 'Scr_Activa.pas' {fScr_Activa},
  Scr_Main in 'Scr_Main.pas' {fScr_Main},
  Pub_Unit in 'Pub_Unit.pas',
  Pro_Start in 'Pro_Start.pas',
  Scr_Registro in 'Scr_Registro.pas' {fScr_Registro};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TfScr_Main, fScr_Main);
  Application.Run;
end.
