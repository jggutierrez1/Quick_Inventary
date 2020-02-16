unit Scr_Registro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  System.RegularExpressions, FMX.TMSCustomButton, FMX.TMSBarButton, FMX.Layouts,
  FMX.ExtCtrls;

type
  TfScr_Registro = class(TForm)
    MaterialOxfordBlueSB: TStyleBook;
    ToolBar1: TToolBar;
    oTitle: TLabel;
    ShadowEffect1: TShadowEffect;
    olEntidad: TLabel;
    oEntidad: TEdit;
    olOperador: TLabel;
    oOperador: TEdit;
    olEmail: TLabel;
    oEmail: TEdit;
    EmailValidLabel: TLabel;
    olContacto: TLabel;
    olStatus: TLabel;
    oBtn_Salir: TTMSFMXBarButton;
    ImageViewer1: TImageViewer;
    oTM_Chek_Internet: TTimer;
    oBtn_Solic: TTMSFMXBarButton;
    olDeviceId: TLabel;
    procedure oEmailValidate(Sender: TObject; var Text: string);
    procedure oBtn_SalirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure oTM_Chek_InternetTimer(Sender: TObject);
    procedure oBtn_SolicClick(Sender: TObject);
  private
    { Private declarations }
    bChek_Ip: Boolean;
  public
    oMasterForm: TForm;
    { Public declarations }
  end;

var
  fScr_Registro: TfScr_Registro;

implementation

uses
  Pub_Unit;
{$R *.fmx}
{$R *.XLgXhdpiTb.fmx ANDROID}
{$R *.iPhone47in.fmx IOS}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfScr_Registro.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  self.oTM_Chek_Internet.Enabled := false;
  if (self.oMasterForm <> nil) then
  begin
    if (self.oMasterForm.Visible = false) then
      self.oMasterForm.Visible := true
  end;

end;

procedure TfScr_Registro.FormCreate(Sender: TObject);
begin
  bChek_Ip := true;
end;

procedure TfScr_Registro.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) then
  begin
//  Do whatever you want to do here
    Key := 0; // Set Key = 0 if you want to prevent the default action
  end;
end;

procedure TfScr_Registro.FormShow(Sender: TObject);
begin
  if (self.oMasterForm <> nil) then
  begin
    if (self.oMasterForm.Visible = true) then
      self.oMasterForm.Visible := false
  end;
  self.olDeviceId.Text := 'ID DEL EQUIPO: ' + Pub_Unit.cId_Device;
  SELF.oBtn_Solic.Enabled := FALSe;
  self.oTM_Chek_InternetTimer(self);
end;

procedure TfScr_Registro.oBtn_SalirClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfScr_Registro.oBtn_SolicClick(Sender: TObject);
var
  cParsString, cResult: string;
  iResult: integer;
  oParms: Tstringlist;
begin
  if (Trim(SELF.oEntidad.text) = '') then
  begin
    ShowMessage('DEBE INGRESAR NOMBRE DE LA EMPRESA/ENTIDADEL QUE SOLICITA LA ACTIVACION DEL SERVICIO.');
    SELF.oEntidad.SetFocus;
    Exit;
  end;

  if (Trim(SELF.oOperador.text) = '') then
  begin
    ShowMessage('DEBE INGRESAR NOMBRE DEL OPERADOR DEL DISPOSITIVO MOVIL.');
    SELF.oOperador.SetFocus;
    Exit;
  end;

  if (Trim(SELF.oEmail.text) = '') then
  begin
    ShowMessage('DEBE INGRESAR CORREO REGISTRADO EN EL DISPOSITIVO PARA PODER RECIBIR EL CODIGO DE ACTIVACION.');
    SELF.oEmail.SetFocus;
    Exit;
  end;

  if (bChek_Ip = true) then
  begin
    if (Pub_Unit.Check_Ip_Disp() = False) then
    begin
      ShowMessage('EL SERVIDOR REMOTO [' + cSERVER_URL + '], NO ESTA DISPONIBLE EN ESTE MOMENTO, CONSULTE EL SOPORTE TECNICO Y REINTENTAR.');
      Exit;
    end;

    bChek_Ip := false;
  end;

  oParms := tstringlist.Create;
  oParms.Clear;
  oParms.Add('dbc_name=devices_inv');
  oParms.Add('logs_sql=0');
  oParms.Add('dev_iden=' + Pub_Unit.cId_Device);
  oParms.Add('nom_enti=' + Trim(SELF.oEntidad.text));
  oParms.Add('nom_oper=' + Trim(SELF.oOperador.text));
  oParms.Add('dev_mail=' + Trim(SELF.oEmail.text));

  Pub_Unit.Http_Post('/nat_counter/request_activation.php', oParms, cResult);
  cResult := GetFromJsonResult(cResult, 'status');
  if (TRIM(cResult) = '1') then
  begin
    ModalResult := mrOK;
    close
  end
  else
  begin
    ShowMessage('ERROR INESPERADO [' + cResult + '] DEVUELTO.');
  end;
end;

procedure TfScr_Registro.oTM_Chek_InternetTimer(Sender: TObject);
begin
  self.oTM_Chek_Internet.Enabled := falsE;
  if (Pub_Unit.IsConnected() = false) then
  begin
    Self.oBtn_Solic.Enabled := False;
    self.olStatus.TEXT := 'SIN ACCESO A INTERNET';
  end
  else
  begin
    Self.oBtn_Solic.Enabled := true;
    self.olStatus.TEXT := 'CON ACCESO A INTERNET';
  end;
  Self.oBtn_Solic.Repaint;
  self.olStatus.Repaint;
  //self.oTM_Chek_Internet.Enabled := true;
end;

procedure TfScr_Registro.oEmailValidate(Sender: TObject; var Text: string);
var
  RegEx: TRegEx;
begin
  RegEx := TRegex.Create('^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-\p{Cyrillic}]+\.[a-zA-Z0-9-.\p{Cyrillic}]*[a-zA-Z0-9\p{Cyrillic}]+$');
  self.EmailValidLabel.Visible := not RegEx.Match(Text).Success;
end;

end.

