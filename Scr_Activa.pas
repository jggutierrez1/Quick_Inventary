unit Scr_Activa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FMX.DialogService, FMX.Platform, FMX.Objects,
  FMX.ScrollBox, FMX.Memo, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.TMSCustomButton,
  FMX.TMSBarButton, FMX.Layouts, FMX.Helpers.Android, FMX.PhoneDialer, FMX.Edit,
  FMX.Ani, FMX.Effects, FMX.ExtCtrls;

type
  TfScr_Activa = class(TForm)
    oCodigo: TEdit;
    olStatus: TLabel;
    oBtn_Exit: TTMSFMXBarButton;
    oBtn_Valid: TTMSFMXBarButton;
    oChek_Internet: TTimer;
    olDeviceId: TLabel;
    ToolBar1: TToolBar;
    oTitle: TLabel;
    ShadowEffect2: TShadowEffect;
    MaterialOxfordBlueSB: TStyleBook;
    ImageViewer1: TImageViewer;
    olCodigo: TLabel;
    procedure oBtn_ExitClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure oChek_InternetTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure oBtn_ValidClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    iIntentos: Integer;
    bChek_Ip: Boolean;
    { Private declarations }
  public
    oMasterForm: TForm;
    { Public declarations }
  end;

var
  fScr_Activa: TfScr_Activa;

implementation

uses
  Pub_Unit, Scr_Main;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.iPhone47in.fmx IOS}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}

procedure TfScr_Activa.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  self.oChek_Internet.Enabled := false;
  if (self.oMasterForm <> nil) then
  begin
    if (self.oMasterForm.Visible = false) then
      self.oMasterForm.Visible := true
  end;
end;

procedure TfScr_Activa.FormCreate(Sender: TObject);
begin
  self.iIntentos := 0;
  bChek_Ip := true;
end;

procedure TfScr_Activa.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) then
  begin
// Do whatever you want to do here
    Key := 0; // Set Key = 0 if you want to prevent the default action
  end;

end;

procedure TfScr_Activa.FormShow(Sender: TObject);
begin
  if (self.oMasterForm <> nil) then
  begin
    if (self.oMasterForm.Visible = true) then
      self.oMasterForm.Visible := false
  end;
  self.olDeviceId.Text := 'ID DEL EQUIPO: ' + Pub_Unit.cId_Device;
  self.oChek_Internet.Enabled := true;
end;

procedure TfScr_Activa.oBtn_ValidClick(Sender: TObject);
var
  cClave, cParsString, cResult: string;
  iResult: integer;
  oParms: Tstringlist;
begin
  if (Trim(SELF.oCodigo.text) = '') then
  begin
    ShowMessage('DEBE INGRESAR CODIGO DE ACTIVACION ENVIADO AL CORREO ELECTRONICO.');
    SELF.oCodigo.SetFocus;
    Exit;
  end;

  cClave := self.oCodigo.text;
  cParsString := '';
  cResult := '';

  if (bChek_Ip = true) then
  begin
    if (Pub_Unit.Check_Ip_Disp() = False) then
    begin
      ShowMessage('EL SERVIDOR REMOTO [' + cSERVER_URL + '], NO ESTA DISPONIBLE EN ESTE MOMENTO, CONSULTE EL SOPORTE TECNICO Y REINTENTAR.');
      //Application.Terminate();
      Exit;
    end;
    bChek_Ip := false;
  end;

  if (self.iIntentos >= 3) then
  begin
    ShowMessage('DEMASIADOS INTENTOS.');
    Application.Terminate();
    Exit;
  end;

  cResult := '';
  oParms := tstringlist.Create;
  oParms.Clear;

  oParms.Add('dbname=devices_inv');
  oParms.Add('logsql=0');
  oParms.Add('device=' + Pub_Unit.cId_Device);
  oParms.Add('clavee=' + cClave);

  Pub_Unit.Http_Post('/nat_counter/register_device.php', oParms, cResult);
  cResult := GetFromJsonResult(cResult, 'status');

  iResult := StrToInt(cResult);
  if (iResult = 1) then
  begin
    Pub_Unit.active_device(cClave);
    close;
    exit;
  end
  else
  begin
    ShowMessage('CLAVE INVALIDA.');
    self.iIntentos := self.iIntentos + 1;
    exit;
  end;
end;

procedure TfScr_Activa.oBtn_ExitClick(Sender: TObject);
begin
  self.iIntentos := 0;
  Application.Terminate();
end;

procedure TfScr_Activa.oChek_InternetTimer(Sender: TObject);
begin
  self.oChek_Internet.Enabled := falsE;
  if (Pub_Unit.IsConnected() = false) then
  begin
    Self.oBtn_Valid.Enabled := False;
    self.olStatus.TEXT := 'SIN ACCESO A INTERNET';
  end
  else
  begin
    Self.oBtn_Valid.Enabled := true;
    self.olStatus.TEXT := 'CON ACCESO A INTERNET';
  end;
  self.olStatus.Repaint;
  self.oChek_Internet.Enabled := true;
end;

end.

