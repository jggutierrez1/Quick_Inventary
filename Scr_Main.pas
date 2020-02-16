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
  System.Net.HttpClient, System.Net.HttpClientComponent, FMX.Effects;
{$ENDIF}

type
  TfScr_Main = class(TForm)
    oBtn_Salir: TTMSFMXBarButton;
    oBtn_Setting: TTMSFMXBarButton;
    oBtn_Send_Data: TTMSFMXBarButton;
    oConn: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    oCmnd: TFDCommand;
    oQry_Gen: TFDQuery;
    ShadowEffect1: TShadowEffect;
    MaterialOxfordBlueSB: TStyleBook;
    procedure oBtn_SalirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function Init_Database_Sqlite: boolean;
//{$IFDEF ANDROID}
    procedure Toast(const Msg: string; Duration: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure oBtn_Send_DataClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OnCloseDialog(Sender: TObject; const AResult: TModalResult);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//{$ENDIF}
  private
    { Private declarations }
    PhoneDialerService: IFMXPhoneDialerService;
    procedure do_activa(ModalResult: TModalResult);
    function Valida_Activacion_Vigente(): Boolean;
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

procedure TfScr_Main.OnCloseDialog(Sender: TObject; const AResult: TModalResult);
begin
  if AResult = mrOK then
    Close;
end;

procedure TfScr_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  MessageDlg('Seguro que desea salir de la aplicasión?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        Application.Terminate;
    end);
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
    FMX.Dialogs.MessageDlg('Salir de la Applicación?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel], -1, self.OnCloseDialog);
  end;
end;

procedure TfScr_Main.FormShow(Sender: TObject);
var
  bGetCode: boolean;
  bRegistrar_App: boolean;
  cSql_Cmd: string;
begin
  self.oBtn_Setting.Visible := false;
  self.oBtn_Send_Data.Visible := false;
  self.oBtn_Salir.Visible := false;

  bGetCode := False;
  bRegistrar_App := False;
  self.Init_Database_Sqlite();
  if (Pub_Unit.Instaled_Database() = false) then
  begin
    Pub_Unit.Execute_SQL_Command(Pub_Unit.cSqlCreateDisp);
    Pub_Unit.check_tables_device(false);
    bRegistrar_App := true;
  end
  else
  begin
    if (Pub_Unit.check_device_data() <= 0) then
      bRegistrar_App := true
    else
    begin
      if (self.Valida_Activacion_Vigente() = False) then
        bGetCode := true
      else
        bGetCode := false;
    end;
  end;

  if (bRegistrar_App = true) then
  begin
    //Pub_Unit.Execute_SQL_Command(cSqlCreateDisp);

    Application.CreateForm(TfScr_Registro, fScr_Registro);
    fScr_Registro.oMasterForm := fScr_Main;
    fScr_Registro.ShowModal(
      procedure(ModalResult: TModalResult)
      var
        bActivar_App: boolean;
        oPar1: Tstringlist;
        cSql_Result1: string;
      begin
        bActivar_App := false;
        if (ModalResult = mrOK) then
        begin
          oPar1 := tstringlist.Create;
          oPar1.Clear;
          oPar1.Add('dbname=devices_inv');
          oPar1.Add('device=' + Pub_Unit.cId_Device);
          oPar1.Add('logsql=0');

          Pub_Unit.Http_Post('/nat_counter/get_device_data.php', oPar1, cSql_Result1);
          if (Trim(cSql_Result1) <> '') then
          begin
            cSql_Result1 := Pub_Unit.StripUnwantedText(cSql_Result1);
            Pub_Unit.Execute_SQL_Command(cSql_Result1);

            Application.CreateForm(TfScr_Activa, fScr_Activa);
            fScr_Activa.oMasterForm := nil;
            fScr_Activa.ShowModal(
              procedure(ModalResult: TModalResult)
              begin
                do_activa(ModalResult);
              end);
            freeandnil(fScr_Activa);
          end
          else
          begin

            TDialogService.PreferredMode := TDialogService.TPreferredMode.platform;
            TDialogService.MessageDialog('Error al recibir la informacion del servidor:[' + cSql_Result1 + ']', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
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
    if (bGetCode = true) then
    begin

      Application.CreateForm(TfScr_Activa, fScr_Activa);
      fScr_Activa.oMasterForm := SELF;
      fScr_Activa.ShowModal(
        procedure(ModalResult: TModalResult)
        begin
          do_activa(ModalResult);
        end);
      freeandnil(fScr_Activa);
    end
    else
    begin
      self.Visible := True;
      self.oBtn_Setting.Visible := true;
      self.oBtn_Send_Data.Visible := true;
      self.oBtn_Salir.Visible := true;

    end;
  end;
end;

procedure TfScr_Main.do_activa(ModalResult: TModalResult);
var
  oPar2: Tstringlist;
  cSql_Result2: string;
begin
  if (ModalResult = mrOk) then
  begin
    oPar2 := tstringlist.Create;
    oPar2.Clear;
    oPar2.Add('dbname=devices_inv');
    oPar2.Add('device=' + Pub_Unit.cId_Device);
    oPar2.Add('logsql=0');
    Pub_Unit.Http_Post('/nat_counter/upd_device_data.php', oPar2, cSql_Result2);
    oPar2.Free;
    if (Trim(cSql_Result2) <> '') then
    begin
      cSql_Result2 := Pub_Unit.StripUnwantedText(cSql_Result2);
      Pub_Unit.Execute_SQL_Command(cSql_Result2);
      Application.Terminate();
    end
    else
    begin
      TDialogService.PreferredMode := TDialogService.TPreferredMode.platform;
      TDialogService.MessageDialog('Error al recibir la informacion del servidor:[' + cSql_Result2 + ']', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
        procedure(const AResult: TModalResult)
        begin
          case AResult of
            mrOk:
              Application.Terminate();
          end;
        end);

    end;
    Application.Terminate();
  end;
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
end;

function TfScr_Main.Init_Database_Sqlite: boolean;
begin
  oConn.Connected := false;
  oConn.Params.Values['Database'] := Pub_Unit.cDb_Path;
  oConn.Connected := true;
  Result := oConn.Connected;
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

function TfScr_Main.Valida_Activacion_Vigente(): Boolean;
var
  cSql_Cmd: string;
  dDateIni: TDateTime;
  dDateEnd: TDateTime;
  cDateIni: string;
  cDateEnd: string;
  cDateNow: string;
begin
  Result := false;
  cSql_Cmd := 'SELECT serial,acceso_periodo,fecha_desde,fecha_hasta,acceso_subidas, subidas_counter,subidas_total FROM dispositivos WHERE serial="' + Pub_Unit.cId_Device + '"';
  if (Pub_Unit.Execute_SQL_Query(Pub_Unit.oPub_Qry, cSql_Cmd) = True) then
  begin
    dDateIni := Pub_Unit.oPub_Qry.FieldByName('fecha_desde').AsDateTime;
    dDateEnd := Pub_Unit.oPub_Qry.FieldByName('fecha_hasta').AsDateTime;
    cDateIni := Pub_Unit.DateTimeForSQL(dDateIni);
    cDateEnd := Pub_Unit.DateTimeForSQL(dDateEnd);
    cDateNow := Pub_Unit.DateTimeForSQL(Now());

    if (Pub_Unit.oPub_Qry.FieldByName('acceso_periodo').AsInteger = 1) then
    begin
      if ((Now() >= dDateIni) and (Now() <= dDateEnd)) then
        Result := true
      else
        Result := false;
    end
    else
    begin
      if ((Pub_Unit.oPub_Qry.FieldByName('subidas_counter').AsInteger >= 0) and (Pub_Unit.oPub_Qry.FieldByName('subidas_counter').AsInteger <= Pub_Unit.oPub_Qry.FieldByName('subidas_total').AsInteger)) then
        Result := true
      else
        Result := false;
    end;
  end;
end;

end.

