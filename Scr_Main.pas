unit Scr_Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, System.Messaging, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FMX.DialogService, FMX.Platform,
  FMX.Objects, FMX.ScrollBox, FMX.Memo, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.TMSCustomButton, FMX.TMSBarButton, FMX.Layouts, FMX.Helpers.Android,
  FMX.PhoneDialer,
  {$IFDEF ANDROID}
  Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText, Androidapi.Jni.Widget, Androidapi.JNI,
  Androidapi.Helpers, Androidapi.JNI.Telephony, Androidapi.JNI.Provider,
  Androidapi.JNI.Os, System.permissions, Web.HTTPApp, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent;
{$ENDIF}

type
  TfScr_Main = class(TForm)
    StatusBar1: TStatusBar;
    oBtn_Salir: TTMSFMXBarButton;
    oBtn_Setting: TTMSFMXBarButton;
    oBtn_Quick_Inv: TTMSFMXBarButton;
    oBtn_Send_Data: TTMSFMXBarButton;
    oBtn_Cargar: TTMSFMXBarButton;
    oConn: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    oCmnd: TFDCommand;
    oQry_Gen: TFDQuery;
    Memo1: TMemo;
    procedure oBtn_SalirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function Init_Database_Sqlite: boolean;
    procedure GetPhoneInfo;
    procedure OnCloseDialog(Sender: TObject; const AResult: TModalResult);
//{$IFDEF ANDROID}
    procedure Toast(const Msg: string; Duration: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure oBtn_Send_DataClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure oBtn_CargarClick(Sender: TObject);
//{$ENDIF}
  private
    { Private declarations }
    PhoneDialerService: IFMXPhoneDialerService;
  public
    oNumbers: TArray<string>;
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  fScr_Main: TfScr_Main;

implementation

uses
  Pub_Unit, Scr_Registro, Scr_Activa;

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiTb.fmx ANDROID}

constructor TfScr_Main.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TPlatformServices.Current.SupportsPlatformService(IFMXPhoneDialerService, IInterface(PhoneDialerService));
end;

procedure TfScr_Main.FormCreate(Sender: TObject);
begin
  Pub_Unit.cpACCESS_NETWORK_STATE := JStringToString(TJManifest_permission.JavaClass.ACCESS_NETWORK_STATE);
  Pub_Unit.cpREAD_PHONE_STATE := JStringToString(TJManifest_permission.JavaClass.READ_PHONE_STATE);
  Pub_Unit.cpACCESS_WIFI_STATE := JStringToString(TJManifest_permission.JavaClass.ACCESS_WIFI_STATE);
  Pub_Unit.cpCAMERA := JStringToString(TJManifest_permission.JavaClass.CAMERA);
  Pub_Unit.cpINTERNET := JStringToString(TJManifest_permission.JavaClass.INTERNET);
  Pub_Unit.cpREAD_EXTERNAL_STORAGE := JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE);
  Pub_Unit.cpWRITE_EXTERNAL_STORAGE := JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);
  Pub_Unit.cPACKAGE_NAME := JStringToString(TAndroidHelper.Activity.getApplicationContext().getPackageName());

  CallInUIThreadAndWaitFinishing(
    procedure
    begin
//    work without but should be uncoment this 2 lines https://developer.android.com/reference/android/view/Window#setStatusBarColor(int)You shuld uncoment this 2 lines
//    TAndroidHelper.Activity.getWindow.addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
//    TAndroidHelper.Activity.getWindow.clearFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_TRANSLUCENT_STATUS);
//    TAndroidHelper.Activity.getWindow.setStatusBarColor(TAlphaColorRec.Chartreuse);
    end);

  //self.SystemStatusBar.BackgroundColor := $FF111111;
  //self.SystemStatusBar.Visibility := TFormSystemStatusBar.TVisibilityMode.Visible;
end;

procedure TfScr_Main.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    Key := 0; // Set Key = 0 if you want to prevent the default action
    MessageDlg('Salir de la Applicación?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel], -1, self.OnCloseDialog);
  end;
end;

procedure TfScr_Main.FormShow(Sender: TObject);
var
  bGetCode: boolean;
  bRegDevi: boolean;
  cSql_Cmd: string;
begin
  bGetCode := False;
  bRegDevi := False;
  self.Init_Database_Sqlite();
  if (Pub_Unit.Instaled_Database() = false) then
  begin
    Pub_Unit.check_tables_device(false);
    bRegDevi := true;
  end
  else
  begin
    if (Pub_Unit.check_device_data() <= 0) then
      bRegDevi := true
    else
      bGetCode := true;
  end;

  if (bRegDevi = true) then
  begin
    Application.CreateForm(TfScr_Registro, fScr_Registro);
    fScr_Registro.oMasterForm := nil;
    fScr_Registro.ShowModal(
      procedure(ModalResult: TModalResult)
      var
        oPar: Tstringlist;
        cSql_Result: string;
      begin
        if (ModalResult = mrOK) then
        begin

          oPar := tstringlist.Create;
          oPar.Clear;
          oPar.Add('dbname=devices_inv');
          oPar.Add('device=' + Pub_Unit.cId_Device);
          oPar.Add('logsql=0');

          Pub_Unit.Http_Post('/nat_counter/get_device_data.php', oPar, cSql_Result);
          if (Trim(cSql_Result) <> '') then
          begin
            Pub_Unit.Execute_SQL_Command(cSql_Result);

            //cSql_Cmd := 'SELECT serial,acceso_periodo,fecha_desde,fecha_hasta,acceso_subidas, subidas_counter FROM dispositivos WHERE serial="' + Pub_Unit.cId_Device + '"';
            //Pub_Unit.Execute_SQL_Query(Pub_Unit.oPub_Qry, cSql_Cmd);

            Application.CreateForm(TfScr_Activa, fScr_Activa);
            fScr_Activa.oMasterForm := nil;
            fScr_Activa.ShowModal(
              procedure(ModalResult: TModalResult)
              begin

              end);
            freeandnil(fScr_Activa);
          end
          else
          begin

            TDialogService.PreferredMode := TDialogService.TPreferredMode.platform;
            TDialogService.MessageDialog('Error al recibir la informacion del servidor:[' + cSql_Result + ']', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
              procedure(const AResult: TModalResult)
              begin
                case AResult of
                  mrOk:
                    Application.Terminate();
                end;
              end);
          end;
        end
        else
        begin
          Application.Terminate();
        end;

      end);
    freeandnil(fScr_Registro);
  end
  else
  begin
    Application.CreateForm(TfScr_Activa, fScr_Activa);
    fScr_Activa.oMasterForm := SELF;
    fScr_Activa.Show;
    //freeandnil(fScr_Activa);
  end;
end;

procedure TfScr_Main.OnCloseDialog(Sender: TObject; const AResult: TModalResult);
begin
  if AResult = mrOK then
    Close;
end;

procedure TfScr_Main.oBtn_CargarClick(Sender: TObject);
var
  cres: string;
begin
  cres := Get_Json_From_Url('https://centenariopma.hopto.org/');
end;

procedure TfScr_Main.oBtn_SalirClick(Sender: TObject);
begin
  close;
end;

procedure TfScr_Main.oBtn_Send_DataClick(Sender: TObject);
var
  ctr: string;
  oArray: TArray<string>;
begin
  PermissionsService.RequestPermissions([Pub_Unit.cpACCESS_NETWORK_STATE],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO: ' + Pub_Unit.cpACCESS_NETWORK_STATE)

      else
        ShowMessage('Permission Denied: ' + Pub_Unit.cpACCESS_NETWORK_STATE);
    end);

  PermissionsService.RequestPermissions([Pub_Unit.cpREAD_PHONE_STATE],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO: ' + Pub_Unit.cpREAD_PHONE_STATE)

      else
        ShowMessage('Permission Denied ' + Pub_Unit.cpREAD_PHONE_STATE);
    end);

  PermissionsService.RequestPermissions([Pub_Unit.cpACCESS_WIFI_STATE],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO :' + Pub_Unit.cpACCESS_WIFI_STATE)

      else
        ShowMessage('Permission Denied :' + Pub_Unit.cpACCESS_WIFI_STATE);
    end);

  PermissionsService.RequestPermissions([Pub_Unit.cpCAMERA],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO :' + Pub_Unit.cpCAMERA)

      else
        ShowMessage('Permission Denied :' + Pub_Unit.cpCAMERA);
    end);

  PermissionsService.RequestPermissions([Pub_Unit.cpINTERNET],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO :' + Pub_Unit.cpINTERNET)

      else
        ShowMessage('Permission Denied :' + Pub_Unit.cpINTERNET);
    end);

  PermissionsService.RequestPermissions([Pub_Unit.cpREAD_EXTERNAL_STORAGE],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO :' + Pub_Unit.cpREAD_EXTERNAL_STORAGE)

      else
        ShowMessage('Permission Denied :' + Pub_Unit.cpREAD_EXTERNAL_STORAGE);
    end);

  PermissionsService.RequestPermissions([Pub_Unit.cpWRITE_EXTERNAL_STORAGE],
    procedure(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        //ShowMessage('Permission CONCEDIDO :' + Pub_Unit.cpWRITE_EXTERNAL_STORAGE)

      else
        ShowMessage('Permission Denied :' + Pub_Unit.cpWRITE_EXTERNAL_STORAGE);
    end);

  ctr := Pub_Unit.DeviceTelephoneNumber();
  SELF.Memo1.Lines.Add('PHONE1=' + ctr);

  oArray := Pub_Unit.DeviceTelephoneNumbers();
  SELF.Memo1.Lines.Add('PHONE2=' + oArray[0]);

  self.GetPhoneInfo();

end;

function TfScr_Main.Init_Database_Sqlite: boolean;
begin
  oConn.Connected := false;
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
  oConn.Params.Values['Database'] := Pub_Unit.cDb_Path;
  oConn.Connected := true;
  Result := oConn.Connected;
{$ENDIF}
end;


//{$IFDEF ANDROID}
procedure TfScr_Main.Toast(const Msg: string; Duration: Integer);
begin
  CallInUiThread(
    procedure
    begin
      TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence(Msg), Duration).show
    end);
end;
//{$ENDIF}

procedure TfScr_Main.GetPhoneInfo;
var
  OSVersion: TOSVersion;
  OSLang: string;
  LocaleService: IFMXLocaleService;
  cDevice, cId, cModelName, cSerial: string;
  oTels: TStringList;
  parametres: Tstringlist;
begin
  parametres := tstringlist.Create;
  cSerial := Pub_Unit.get_Device_id();

  cModelName := 'unknown';
{$IFDEF Android}
  cDevice := JStringToString(TJBuild.JavaClass.DEVICE);
  cId := JStringToString(TJBuild.JavaClass.ID);
  cModelName := JStringToString(TJBuild.JavaClass.MODEL);
  //cSerial := JStringToString(TJBuild.JavaClass.SERIAL);
{$ENDIF}
{$IFDEF IOS}
  //ModelName := GetDeviceModelString;
  cModelName := '';
{$ENDIF}

  Memo1.Lines.Add(Format('Device=%s', [cDevice]));
  Memo1.Lines.Add(Format('Id=%s', [cId]));
  Memo1.Lines.Add(Format('ModelName=%s', [cModelName]));
  Memo1.Lines.Add(Format('Serial=%s', [cSerial]));
  Memo1.Lines.Add(Format('OSName=%s', [OSVersion.Name]));
  Memo1.Lines.Add(Format('Platform=%d', [Ord(OSVersion.platform)]));
  Memo1.Lines.Add(Format('Version=%d.%d', [OSVersion.Major, OSVersion.Minor]));

  OSLang := '';
  //OSLang := Pub_Unit.GetIMEI();
  //Memo1.Lines.Add(OSLang);
  Memo1.Repaint;

  OSLang := '';
  //OSLang := Pub_Unit.GetContactByNumber('60481423');
  //Memo1.Lines.Add(OSLang);

  parametres.Clear;
  parametres.Add('table_no=1');
  parametres.Add('emp_id=1');
  //UTF8Encode('1'));
  //EncodeURIComponent('éè') );
  //Http_Get('https://api6.ipify.org/?format=jsonp&callback=getip', OSLang, true);
  //Http_Post('/flam/get_all_data.php', parametres, OSLang);

  begin
    Memo1.Lines.Add(OSLang);
    Memo1.Repaint;
  end;
  Memo1.Repaint;
  parametres.Free;
end;

end.

