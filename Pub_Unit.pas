unit Pub_Unit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, System.Net.HttpClientComponent, System.Threading, System.math,
  System.StrUtils, System.DateUtils, FireDAC.Stan.Intf, System.Net.HttpClient,
  Web.HTTPApp, System.NetEncoding, IdHTTP, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Script, FMX.DialogService,
  FMX.Platform, FMX.Objects, FMX.ScrollBox, FMX.Memo, FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.TMSCustomButton, FMX.TMSBarButton, FMX.Layouts, {FMX.Helpers.Android,}
  System.JSON, System.JSON.BSON, System.JSON.Writers, System.JSON.Builders,
  REST.Types, REST.Client, REST.Utils, Data.Bind.Components,
  Data.Bind.ObjectScope
  {$IFDEF ANDROID}
    , FMX.Helpers.Android, Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
    Androidapi.JNI.GraphicsContentViewText, Androidapi.Jni.Widget,
    Androidapi.JNI, Androidapi.Helpers, Androidapi.JNI.Telephony,
    Androidapi.JNI.Provider, Androidapi.JNI.Os, System.permissions,
    Androidapi.JNI.Net;
{$ENDIF}

type
  TDateTimePart = (dtpHour, dtpMinute, dtpSecond, dtpMS, dtpDay, dtpMonth, dtpYear);

type
  Config2 = object
    nombre: string;
    host: string;
    usuario: string;
    clave: string;
    puerto: integer;
    database: string;
    Reportes: string;
    estado: string;
    protocol: string;
  end;

var
  Itm: TJTelephonyManager;
  cId_Device: string;
  cPACKAGE_NAME: string;
  cpACCESS_NETWORK_STATE, cpREAD_PHONE_STATE, cpACCESS_WIFI_STATE, cpCAMERA, cpINTERNET, cpREAD_EXTERNAL_STORAGE, cpWRITE_EXTERNAL_STORAGE: string;
  cSERVER_URL: string;
  cSERVER_URL_LIST: array of string;
  iSERVER_URL_LIST_CNT: integer;
  iSERVER_ITEM_LIST: Integer;
  cSERVER_URL_FLES, cSERVER_DIR_IMGS: string;
  oHTTP_Get, oHTTP_Post: TNetHTTPClient;
  cDb_Path: string;
  oPub_Con_Tmp: TFDConnection;
  oPub_Con: TFDConnection;
  oPub_Drv: TFDPhysSQLiteDriverLink;
  oPub_Mang: TFDManager;
  oPub_Cmd: TFDCommand;
  oPub_Qry: TFDQuery;
  oPub_Scrp: TFDScript;
  oConnParams: TStringList;
  cpDecimales: Char = '.';
  cpThousand: Char = ',';
  cSqlCreateDisp: string;

const
  HTTP_GET_NOT_BUSY = 0;
  HTTP_GET_BUSY = 1;
  HTTP_POST_NOT_BUSY = 0;
  HTTP_POST_BUSY = 1;

function get_Device_id(): string;

function GetLine(): string;

function GetIMEI(): string;

function Http_Post(cpWebService_name: string; pParams: TStringList; var pResult: string; bOtherPath: boolean = false): boolean;

function Http_Get(cpWebPath_parameter: string; var pResult: string; bOtherPath: boolean = false): boolean;

procedure Http_Get_Sync(cpWebService_name: string; pParams: TStringList; var pResult: string);

procedure Toast(const Msg: string; Duration: Integer);

function IsConnected: Boolean;

function IsWiFiConnected: Boolean;

function IsMobileConnected: Boolean;

function DeviceTelephoneNumber: string;

function DeviceTelephoneNumbers: TArray<string>;

function ProperCase(var cString: string): string;

function isEmpty(s: single): Boolean; overload;

function isEmpty(s: string): Boolean; overload;

function RandomPassword(PLen: integer): string;

function RemoveNonAlpha(srcStr: string): string;

function isCharAlpha(ch: Char): Boolean;

function IsDigit(ch: Char): Boolean;

function RandomWord(dictSize, lngStepSize, wordLen, minWordLen: integer): string;

function LDOM(Date: Tdatetime): Tdatetime;

function FDOM(Date: Tdatetime): Tdatetime;

function MakeRNDString(Chars: string; Count: integer): string;

function CreateUniqueFileName(sPath: string): string;

function iif(Test: Boolean; TrueR, FalseR: variant): variant;

function StrToFloat2(cStr: string): Extended;

function PadR(ASource: string; ALimit: integer; APadChar: Char = ' '): string;

function PadL(ASource: string; ALimit: integer; APadChar: Char = ' '): string;

function stripped(stripchar: Char; Str: string): string;

function CenterString(aStr: string; Len: integer): string;

function DateTimeAdd(SrcDate: Tdatetime; DatePart: TDateTimePart; DiffValue: integer): Tdatetime;

function RoundD(X: currency; d: integer): Extended;

function RoundDn(X: single): single;

function RoundUp(X: single): single;

function Sgn(X: single): integer;

function FormatSumadora_FloatToStr(fValue: Extended; DigitInt: integer; DigitFloat: integer): string;

procedure set_decimal_separator(pDecimal_Separator: Char);

function Inlist(aCadena: string; aLista: array of string): Boolean;

function Replicate(Caracter: string; Quant: integer): string;

function IsStrANumber(const s: string): Boolean;

function FloatToStr3(fValue: Extended; nDigit: integer = 2): string;

function DateTimeForSQL(const pDateTime: Tdatetime): string;

function DateForSQL(const pDate: TDate): string;

function Add_Minutes_in_Datetime(pDateTime: Tdatetime; pMinute: integer): Tdatetime;

function Add_Hours_in_Datetime(pDateTime: Tdatetime; pHour: integer): Tdatetime;

function Add_Years_in_Datetime(pDateTime: Tdatetime; pYear: integer): Tdatetime;

function Add_Months_in_Datetime(pDateTime: Tdatetime; pMonth: integer): Tdatetime;

function Add_Days_in_Datetime(pDateTime: Tdatetime; pDay: integer): Tdatetime;

function Replace_Minute_in_Datetime(pDateTime: Tdatetime; pMinute: integer): Tdatetime;

function Replace_Hour_in_Datetime(pDateTime: Tdatetime; pHour: integer): Tdatetime;

function Replace_Year_in_Datetime(pDateTime: Tdatetime; pYear: integer): Tdatetime;

function Replace_Month_in_Datetime(pDateTime: Tdatetime; pMonth: integer): Tdatetime;

function removeLeadingZeros(const Value: string): string;

function RepeatString(const s: string; Count: cardinal): string;

function tiempo_Transcurrido(pStartTime: DWORD; pEndTime: DWORD): string;

function esPrimo(X: integer): Boolean;

function TimeToDateTime(pTime: Ttime): Tdatetime;

function ReplaceDatePart(pDateTime: Tdatetime; pDateReplace: Tdatetime): Tdatetime;

function Strip(L, c: Char; Str: string): string;

function SecToTime(Sec: integer): string;

function between(nval, nmin, nmax: Longint): Boolean;

function strTran(cText, cfor, cwith: string): string;

function FloatToStr2(Value: Extended): string;

procedure Set_Decinal_Thousand_Separator;

function IsNumber(const c: Char): Boolean;

function FormatNumber(flt: Double; decimals: integer = 0; Thousands: Boolean = True): string; overload;

function FormatNumber(int: Int64; Thousands: Boolean = True): string; overload;

function FormatNumber(Str: string; Thousands: Boolean = True): string; overload;

function UnformatNumber(Val: string): string;

function LastDayInMonth(const Year, Month: Word): Tdatetime;

function DayOfYear(const Year, Month, Day: Word): integer;

function Execute_SQL_Query(var oQry: TFDQuery; sSql: string; oQryExec: Boolean = False): Boolean; overload;

function Execute_SQL_Query(oConn_Tmp: TFDConnection; var oQry: TFDQuery; sSql: string; oQryExec: Boolean = False): Boolean; overload;

function Execute_SQL_Query(var oQry: TFDQuery; sSql: TStringList; oQryExec: Boolean = False): Boolean; overload;

function Execute_SQL_Result(oConn_Tmp: TFDConnection; pSQL: string): string; overload;

function Execute_SQL_Result(pSQL: string): string; overload;

function query_selectgen_result(text: string): string;

function Execute_SQL_Command_Tmp_Fle(pFilename: string; oConn_Tmp: TFDConnection): Boolean; overload;

function Execute_SQL_Command_Tmp(pScript: TStringList; oConn_Tmp: TFDConnection): Boolean; overload;

function Execute_SQL_Command_Tmp(pSQL: string; oConn_Tmp: TFDConnection): Boolean; overload;

function Execute_SQL_Command_Tmp(pSQL: string; oSetting_Tmp: Config2): Boolean; overload;

function Execute_SQL_Command(pScript: TStringList): Boolean; overload;

function Execute_SQL_Script(pScript: TStrings): Boolean; overload;

function Execute_SQL_Script(pScript: string): Boolean; overload;

function Execute_SQL_Script(oConn_Tmp: TFDConnection; pScript: TStrings): Boolean; overload;

function Execute_SQL_Command(pSQL: string): Boolean; overload;

procedure active_device(cClave: string);

procedure Create_Sql_Tables(bDropTables: Boolean = false);

function Instaled_Database(): Boolean;

procedure check_tables_device(bDrop: boolean = false);

function check_device_data(): Integer;

function Get_Json_From_Url(cUrl: string): string;

function CheckUrl(url: string): boolean;

function CheckUrl2(url: string): boolean;

function Check_Ip_Disp(): Boolean;

function GetFromJsonResult(cJsonString: string; cFielsName: string): string;

function StripUnwantedText(cText: string): string;

implementation

function DeviceTelephoneNumbers: TArray<string>;
var
  SubscriptionManager: JSubscriptionManager;
  I, SubscriptionInfoCount: Integer;
  SubscriptionInfoList: JList;
  SubscriptionInfo: JSubscriptionInfo;
begin
  // Subscription manager is only available in Android 5.1 and later
  if TOSVersion.Check(5, 1) then
  begin
    SubscriptionManager := TJSubscriptionManager.JavaClass.from(TAndroidHelper.Context);
    SubscriptionInfoCount := SubscriptionManager.getActiveSubscriptionInfoCount;
    SubscriptionInfoList := SubscriptionManager.getActiveSubscriptionInfoList;
    SetLength(Result, SubscriptionInfoCount);
    for I := 0 to Pred(SubscriptionInfoCount) do
    begin
      SubscriptionInfo := TJSubscriptionInfo.Wrap(SubscriptionInfoList.get(I));
      if SubscriptionInfo <> nil then
        Result[I] := JStringToString(SubscriptionInfo.getNumber);
    end;
  end
  else
  begin
    // If running on older OS, use older API
    SetLength(Result, SubscriptionInfoCount);
    Result[0] := DeviceTelephoneNumber
  end;
end;

function DeviceTelephoneNumber: string;
var
  TelephonyManagerObj: JObject;
  TelephonyManager: JTelephonyManager;
begin
  TelephonyManagerObj := TAndroidHelper.Context.getSystemService(TJContext.JavaClass.TELEPHONY_SERVICE);
  if TelephonyManagerObj <> nil then
  begin
    TelephonyManager := TJTelephonyManager.Wrap(TelephonyManagerObj);
    if TelephonyManager <> nil then
    begin
      Result := JStringToString(TelephonyManager.getLine1Number);
    end
    else
      Result := 'no manager';

  end
  else
    Result := 'no service';
end;

function get_Device_id(): string;
var
  cSerial: string;
begin
  cSerial := JStringToString(TJSettings_Secure.JavaClass.getString(SharedActivity.getContentResolver, TJSettings_Secure.JavaClass.ANDROID_ID));
  result := cSerial;
end;

function GetLine(): string;
var
  obj: JObject;
  tMgr: JTelephonyManager;
  cLine: string;
begin
  obj := SharedActivityContext.getSystemService(TJContext.JavaClass.TELEPHONY_SERVICE);
  if obj <> nil then
  begin
    tMgr := TJTelephonyManager.Wrap((obj as ILocalObject).GetObjectID);
    if tMgr <> nil then
      cLine := JStringToString(tMgr.getLine1Number);
  end;
  Result := cLine;
end;

function GetIMEI(): string;
var
  obj: JObject;
  tm: JTelephonyManager;
  IMEI: string;
begin
  obj := SharedActivityContext.getSystemService(TJContext.JavaClass.TELEPHONY_SERVICE);
  if obj <> nil then
  begin
    tm := TJTelephonyManager.Wrap((obj as ILocalObject).GetObjectID);
    if tm <> nil then
      IMEI := JStringToString(tm.getDeviceId);
  end;
  if IMEI = '' then
    IMEI := JStringToString(TJSettings_Secure.JavaClass.getString(SharedActivity.getContentResolver, TJSettings_Secure.JavaClass.ANDROID_ID));

  Result := 'IMEI :' + #13 + IMEI;
end;

function Http_Post(cpWebService_name: string; pParams: TStringList; var pResult: string; bOtherPath: boolean = false): boolean;
begin
  {
  Ejemplo:
  parametres.Clear;
  parametres.Add('table_no=1');
  parametres.Add('emp_id=1');
  Http_Post('/flam/get_all_data.php', parametres, OSLang);
  }
  if (oHTTP_Post.Tag = HTTP_POST_NOT_BUSY) then
  begin
    oHTTP_Post.ContentType := 'application/json, text/plain; q=0.9, text/html; charset=utf-8;';
    oHTTP_Post.AcceptCharSet := 'utf-8, *;q=0.8';
    try
      oHTTP_Post.Tag := HTTP_POST_BUSY;
      if (bOtherPath = true) then
        pResult := oHTTP_Post.post(cpWebService_name, pParams, nil, TEncoding.UTF8).ContentAsString(tencoding.UTF8)
      else
        pResult := oHTTP_Post.post(cSERVER_URL + cpWebService_name, pParams, nil, TEncoding.UTF8).ContentAsString(tencoding.UTF8);

      Result := true;
    except
      Toast(cSERVER_URL + cpWebService_name + ' ->Error:' + pResult, 300);
      pResult := '';
      Result := false;
    end;
    oHTTP_Post.Tag := HTTP_POST_NOT_BUSY;
  end;
end;

function Http_Get(cpWebPath_parameter: string; var pResult: string; bOtherPath: boolean = false): boolean;
var
  oResponse: TStringStream;
  iStatus: Integer;
begin
  //example: Http_Get('https://api6.ipify.org/?format=jsonp&callback=getip', OSLang, true);

  if (oHTTP_Get.Tag = HTTP_GET_NOT_BUSY) then
  begin
    oResponse := TStringStream.Create;
    oHTTP_Get.ContentType := 'application/json, text/plain; q=0.9, text/html; charset=utf-8;';
    oHTTP_Get.AcceptCharSet := 'utf-8, *;q=0.8';
    try
      oHTTP_Get.Tag := HTTP_GET_BUSY;
      if (bOtherPath = true) then
        iStatus := oHTTP_Get.Get(cpWebPath_parameter, oResponse, nil).StatusCode
      else
        iStatus := oHTTP_Get.Get(cSERVER_URL + cpWebPath_parameter, oResponse, nil).StatusCode;

      iStatus := iStatus div 200;
      if iStatus <> 1 then
      begin
        Toast(cSERVER_URL + cpWebPath_parameter + ' ->Error:' + iStatus.ToString, 300);
        pResult := cpWebPath_parameter + ' ->Error:' + iStatus.ToString;
      end
      else
        pResult := oResponse.DataString;
      Result := true;
    except
      pResult := 'ERROR';
      Result := false;
    end;
    oHTTP_Get.Tag := HTTP_GET_NOT_BUSY;
    oResponse.Free;
  end
  else
  begin
    pResult := 'BUSY';
    Result := false;
  end;
end;

procedure Toast(const Msg: string; Duration: Integer);
begin
  CallInUiThread(
    procedure
    begin
      TJToast.JavaClass.makeText(TAndroidHelper.Context, StrToJCharSequence(Msg), Duration).show
    end);
end;

procedure Http_Get_Sync(cpWebService_name: string; pParams: TStringList; var pResult: string);
begin
  if oHTTP_Get.Tag = HTTP_GET_NOT_BUSY then
  begin
{    GaussianBlurEffect1.Enabled := True;
    ProgressBar1.Visible := True;
    Timer1.Enabled := True;
    TTask.Run(
      procedure
      var
        LResponse: TMemoryStream;
      begin
        LResponse := TMemoryStream.Create;
        try
          oHTTP_Get.Tag := HTTP_GET_BUSY;
          oHTTP_Get.Get('https://picsum.photos/seed/' + Random.ToString + '/' + Image1.Width.ToString + '/' + Image1.Height.ToString, LResponse);
          TThread.Synchronize(nil,
            procedure
            begin
              Image1.Bitmap.LoadFromStream(LResponse);
            end);
        finally
          LResponse.Free;
          oHTTP_Get.Tag := HTTP_GET_NOT_BUSY;

          GaussianBlurEffect1.Enabled := False;
          ProgressBar1.Visible := False;
          Timer1.Enabled := False;
          ProgressBar1.Value := 0;
        end;
      end);
}                                                                                                                                                                                                                                                                                                end;
end;

function GetConnectivityManager: JConnectivityManager;
var
  ConnectivityServiceNative: JObject;
begin
  ConnectivityServiceNative := TAndroidHelper.Context.getSystemService(TJContext.JavaClass.CONNECTIVITY_SERVICE);
  if not Assigned(ConnectivityServiceNative) then
    raise Exception.Create('Could not locate Connectivity Service');
  Result := TJConnectivityManager.Wrap((ConnectivityServiceNative as ILocalObject).GetObjectID);
  if not Assigned(Result) then
    raise Exception.Create('Could not access Connectivity Manager');
end;

function IsConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  ActiveNetwork: JNetworkInfo;
begin
  ConnectivityManager := GetConnectivityManager;
  ActiveNetwork := ConnectivityManager.getActiveNetworkInfo;
  Result := Assigned(ActiveNetwork) and ActiveNetwork.IsConnected;
end;

function IsWiFiConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  WiFiNetwork: JNetworkInfo;
begin
  ConnectivityManager := GetConnectivityManager;
  WiFiNetwork := ConnectivityManager.getNetworkInfo(TJConnectivityManager.JavaClass.TYPE_WIFI);
  Result := WiFiNetwork.IsConnected;
end;

function IsMobileConnected: Boolean;
var
  ConnectivityManager: JConnectivityManager;
  MobileNetwork: JNetworkInfo;
begin
  ConnectivityManager := GetConnectivityManager;
  MobileNetwork := ConnectivityManager.getNetworkInfo(TJConnectivityManager.JavaClass.TYPE_MOBILE);
  Result := MobileNetwork.IsConnected;
end;

function ProperCase(var cString: string): string;
var
  GetString: string;
  GetLength: integer;
  i: integer;
  T: string;
begin
  GetString := cString;
  GetLength := Length(GetString);
  if GetLength > 0 then
  begin
    for i := 0 to GetLength do
    begin
      if (GetString = ' ') or (i = 0) then
      begin
        if GetString[i + 1] in ['a'..'z'] then
        begin
          T := GetString[i + 1];
          T := UpperCase(T);
          GetString[i + 1] := T[1];
        end;
      end;
    end;
    Result := GetString;
  end
  else
    Result := '';
end;

function CreateUniqueFileName(sPath: string): string;
var
  chTemp: Char;
begin
  repeat
    Randomize;
    repeat
      chTemp := Chr(Random(43) + 47);
      if chTemp in ['0'..'9', 'A'..'Z'] then
        Result := Result + chTemp;
    until Length(Result) = 12;
  until not FileExists(sPath + Result);
end;

function MakeRNDString(Chars: string; Count: integer): string;
var
  i, X: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    X := Length(Chars) - Random(Length(Chars));
    Result := Result + Chars[X];
    Chars := Copy(Chars, 1, X - 1) + Copy(Chars, X + 1, Length(Chars));
  end;
end;

function FDOM(Date: Tdatetime): Tdatetime;
var
  wYear, wMonth, wDay: Word;
begin
  DecodeDate(Date, wYear, wMonth, wDay);
  Result := EncodeDate(wYear, wMonth, 1);
end;

function LDOM(Date: Tdatetime): Tdatetime;
var
  wYear, wMonth, wDay: Word;
begin
  DecodeDate(Date, wYear, wMonth, wDay);
  // (if Month < 12 then inc(Month)
  // else begin Month := 1; inc(Year) end;
  // Result := EncodeDate(Year, Month, 1) - 1;
  Result := EncodeDate(wYear, wMonth, MonthDays[IsLeapYear(wYear), wMonth]);
end;

function RandomWord(dictSize, lngStepSize, wordLen, minWordLen: integer): string;
begin
  Result := '';
  if (wordLen < minWordLen) and (minWordLen > 0) then
    wordLen := minWordLen
  else if (wordLen < 1) and (minWordLen < 1) then
    wordLen := 1;
  repeat
    Result := Result + Chr(Random(dictSize) + lngStepSize);
  until (Length(Result) = wordLen);
end;

function RemoveNonAlpha(srcStr: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Length(srcStr) - 1 do
    if isCharAlpha(srcStr[i]) then
      Result := Result + srcStr[i];
end;

function IsDigit(ch: Char): Boolean;
begin
  Result := ch in ['0'..'9'];
end;

function isCharAlpha(ch: Char): Boolean;
begin
  Result := not IsDigit(ch);
end;

function RandomPassword(PLen: integer): string;
var
  Str: string;
  cResult: string;
begin
  Randomize;
  cResult := '';
  Str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  repeat
    cResult := cResult + Str[Random(Length(Str)) + 1];
  until (Length(cResult) = PLen);
  Result := cResult;
end;

function isEmpty(s: string): Boolean; overload;
begin
  if (Trim(s) <> '') then
    Result := False
  else
    Result := True
end;

function isEmpty(s: single): Boolean; overload;
begin
  if (s <> 0) then
    Result := False
  else
    Result := True
end;

function iif(Test: Boolean; TrueR, FalseR: variant): variant;
begin
  if Test then
    Result := TrueR
  else
    Result := FalseR;
end;


// EX: PadL('123', 5, '0') ==> 00123
function PadL(ASource: string; ALimit: integer; APadChar: Char = ' '): string;
var
  i: integer;
begin
  Result := ASource;
  for i := 1 to ALimit - Length(Result) do
  begin
    Result := APadChar + Result;
  end;
end;

// EX: PadR('123', 5, '0') ==> 12300
function PadR(ASource: string; ALimit: integer; APadChar: Char = ' '): string;
var
  i: integer;
begin
  Result := ASource;
  for i := 1 to ALimit - Length(Result) do
  begin
    Result := Result + APadChar;
  end;
end;

function StrToFloat2(cStr: string): Extended;
var
  cValue: string;
begin
  cValue := iif(Trim(cStr) = '', '0.00', Trim(cStr));
  Result := StrToFloat(stripped(',', cValue));
end;

function stripped(stripchar: Char; Str: string): string;
var
  tmpstr: string;
begin
  tmpstr := Str;
  while pos(stripchar, tmpstr) > 0 do
    Delete(tmpstr, pos(stripchar, tmpstr), 1);
  stripped := tmpstr;

end;

function DateTimeAdd(SrcDate: Tdatetime; DatePart: TDateTimePart; DiffValue: integer): Tdatetime;
var
  m, d, y: Word;
begin
  case DatePart of
    dtpHour: { hour }
      Result := SrcDate + (DiffValue / 24);
    dtpMinute: { Minute }
      Result := SrcDate + (DiffValue / 1440);
    dtpSecond: { Second }
      Result := SrcDate + (DiffValue / 86400);
    dtpMS: { Millisecond }
      Result := SrcDate + (DiffValue / 86400000);
    dtpDay: { Day }
      Result := SrcDate + DiffValue;
    dtpMonth: { Month }
      Result := IncMonth(SrcDate, DiffValue);
  else { Year }
    begin
      DecodeDate(SrcDate, y, m, d);
      Result := Trunc(EncodeDate(y + DiffValue, m, d)) + Frac(SrcDate);
    end;
  end;
end;

function CenterString(aStr: string; Len: integer): string;
var
  posStr: integer;
begin
  if Length(aStr) > Len then
    Result := Copy(aStr, 1, Len)
  else
  begin
    posStr := (Len - Length(aStr)) div 2;
    Result := Format('%*s', [Len, aStr + Format('%-*s', [posStr, ''])]);
  end;
end;

function FormatSumadora_FloatToStr(fValue: Extended; DigitInt: integer; DigitFloat: integer): string;
var
  nValueIn: integer;
  iFactMul: integer;
  nTmp_Val: integer;
  fTmp_Val: Extended;
  cDecForm: string;
  cTmp_Int: string;
  cTmp_Dec: string;
  cRtValue: string;
begin
  nValueIn := 0;
  iFactMul := 0;
  nTmp_Val := 0;
  cDecForm := '';
  cTmp_Int := '';
  cTmp_Dec := '';
  cRtValue := '';

  nValueIn := Trunc(fValue);
  case DigitFloat of
    0:
      begin
        cDecForm := '#######0';
        iFactMul := 1;
      end;
    1:
      begin
        cDecForm := '#######0.0';
        iFactMul := 10;
      end;
    2:
      begin
        cDecForm := '#######0.00';
        iFactMul := 100;
      end;
    3:
      begin
        cDecForm := '#######0.000';
        iFactMul := 1000;
      end;
  else
    begin
      cDecForm := '#######0.00';
      iFactMul := 100;
    end;
  end;
  cTmp_Int := PadL(Trim(IntToStr(nValueIn)), DigitInt, '0');
  if DigitFloat > 0 then
  begin
    fTmp_Val := ((fValue - nValueIn) * iFactMul);
    cTmp_Dec := Trim(FormatFloat('#######0', fTmp_Val));
    cTmp_Dec := PadL(cTmp_Dec, DigitFloat, '0');
  end
  else
    cTmp_Dec := '';
  cRtValue := Trim(cTmp_Int) + Trim(cTmp_Dec);
  Result := cRtValue;
end;

{ --------------------------------------------------------------------------------------------
  // Devuelve -1, 0 o 1 de acuerdo al signo del argumento
  -------------------------------------------------------------------------------------------- }
function Sgn(X: single): integer;
begin
  if X < 0 then
    Result := -1
  else
  begin
    if X = 0 then
      Result := 0
    else
      Result := 1;
  end;
end;

{ --------------------------------------------------------------------------------------------
  // Devuelve el primer entero mayor que o igual al n�mero dado en valor absoluto
  // (se preserva el signo).
  // RoundUp(3.3) = 4    RoundUp(-3.3) = -4
  -------------------------------------------------------------------------------------------- }
function RoundUp(X: single): single;
begin
  Result := int(X) + Sgn(Frac(X));
end;

{ --------------------------------------------------------------------------------------------
  // Devuelve el primer entero menor que o igual al n�mero dado en valor absoluto
  // (se preserva el signo).
  //   RoundDn(3.7) = 3    RoundDn(-3.7) = -3
  -------------------------------------------------------------------------------------------- }
function RoundDn(X: single): single;
begin
  Result := int(X);
end;

{ -------------------------------------------------------------------------------------------------
  Estas funciones que acabamos de presentar siempre redondean el �ltimo d�gito entero, pero a veces
  necesitamos redondear por ejemplo la segunda cifra decimal o los miles, millones y billones. La siguiente funci�n realiza un "redondeo normal" tomando un par�metro adicional para indicar el d�gito a ser redondeado:
  // RoundD(123.456, 0) = 123.00
  // RoundD(123.456, 2) = 123.46
  // RoundD(123456, -3) = 123000
}
function RoundD(X: currency; d: integer): Extended;
var
  n: Extended;
begin

  n := IntPower(10, d);
  X := X * n;
  Result := (int(X) + int(Frac(X) * 2)) / n;
end;

procedure set_decimal_separator(pDecimal_Separator: Char);
begin
  cpDecimales := pDecimal_Separator;
  FormatSettings.DecimalSeparator := cpDecimales;
end;

{ --------------------------------------------------------------------------------------------
  esta funci�n duplica un caracter las cantidad de veces especificada.
  Cadena:=Replicate('=',20)
  devuelve a cadena '===================='
  ---------------------------------------------------------------------------------------------- }

function Replicate(Caracter: string; Quant: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Quant do
    Result := Result + Caracter;
end;

{ -------------------------------------------------------------------------------------------------
  esta funcion es original de Foxpro/Visual Foxpro, le agregas una lista de elementos y te devuelve
  true si la cadena contiene alguno de los elementos de la lista y false si no lo tiene.
  ejemplo de uso:

  VariableTexto:='gato';
  if Inlist(VariableTexto,['perro','gato','canario'])=true then
  begin
  //es un gato
  .....
  end;
  -------------------------------------------------------------------------------------------------- }
function Inlist(aCadena: string; aLista: array of string): Boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(aLista) to High(aLista) do
  begin
    if UpperCase(aCadena) = UpperCase(aLista[i]) then
    begin
      Result := True;
      break;
    end;
  end;
end;

function FloatToStr3(fValue: Extended; nDigit: integer = 2): string;
var
  cMask: string;
begin
  cMask := '%20.' + Trim(IntToStr(nDigit)) + 'f';
  Result := Trim(Format(cMask, [fValue]));
end;

{ -----------------------------------------------------------------------------------------------
  Esta función determina si una cadena contiene sólo números
  ------------------------------------------------------------------------------------------------ }
function IsStrANumber(const s: string): Boolean;
var
  P: PChar;
begin
  P := PChar(s);
  Result := False;
  while P^ <> #0 do
  begin
    if not (P^ in ['0'..'9']) then
      exit;
    Inc(P);
  end;
  Result := True;
end;

function tiempo_Trans_Result(pStartTime: DWORD; pEndTime: DWORD; iFlag: integer = 0): string;
var
  ElapsedTime: DWORD;
  Estimated_hours: DWORD;
  Estimated_Minutes: DWORD;
  Estimated_seconds: DWORD;
begin
  ElapsedTime := pEndTime - pStartTime;
  // calculo de horas minutos y segundos
  Estimated_hours := (ElapsedTime div (3600 * 999)) mod 24;
  Estimated_Minutes := (ElapsedTime div (60 * 999)) mod 60;
  Estimated_seconds := (ElapsedTime div 999) mod 60;
  case iFlag of
    0:
      Result := Trim(IntToStr(Estimated_hours) + ':' + IntToStr(Estimated_Minutes) + ':' + IntToStr(Estimated_seconds));
    1:
      Result := Trim(IntToStr(Estimated_hours));
    2:
      Result := Trim(IntToStr(Estimated_Minutes));
    3:
      Result := Trim(IntToStr(Estimated_seconds));
    4:
  else
    Result := '';
  end;
end;

function Replace_Day_in_Datetime(pDateTime: Tdatetime; pDay: integer): Tdatetime;
begin
  Result := RecodeDate(pDateTime, YearOf(pDateTime), MonthOf(pDateTime), pDay);
end;

function Replace_Month_in_Datetime(pDateTime: Tdatetime; pMonth: integer): Tdatetime;
begin
  Result := RecodeDate(pDateTime, YearOf(pDateTime), pMonth, DayOf(pDateTime));
end;

function Replace_Year_in_Datetime(pDateTime: Tdatetime; pYear: integer): Tdatetime;
begin
  Result := RecodeDate(pDateTime, pYear, MonthOf(pDateTime), DayOf(pDateTime));
end;

function Replace_Hour_in_Datetime(pDateTime: Tdatetime; pHour: integer): Tdatetime;
begin
  Result := RecodeTime(pDateTime, pHour, MinuteOf(pDateTime), SecondOf(pDateTime), 0);
end;

function Replace_Minute_in_Datetime(pDateTime: Tdatetime; pMinute: integer): Tdatetime;
begin
  Result := RecodeTime(pDateTime, HourOf(pDateTime), pMinute, SecondOf(pDateTime), 0);
end;

function Add_Days_in_Datetime(pDateTime: Tdatetime; pDay: integer): Tdatetime;
begin
  Result := DateTimeAdd(pDateTime, dtpDay, pDay);
end;

function Add_Months_in_Datetime(pDateTime: Tdatetime; pMonth: integer): Tdatetime;
begin
  Result := DateTimeAdd(pDateTime, dtpMonth, pMonth);
end;

function Add_Years_in_Datetime(pDateTime: Tdatetime; pYear: integer): Tdatetime;
begin
  Result := DateTimeAdd(pDateTime, dtpYear, pYear);
end;

function Add_Hours_in_Datetime(pDateTime: Tdatetime; pHour: integer): Tdatetime;
begin
  Result := DateTimeAdd(pDateTime, dtpHour, pHour);
end;

function Add_Minutes_in_Datetime(pDateTime: Tdatetime; pMinute: integer): Tdatetime;
begin
  Result := DateTimeAdd(pDateTime, dtpMinute, pMinute);
end;

function DateForSQL(const pDate: TDate): string;
var
  y, m, d: Word;
begin
  DecodeDate(pDate, y, m, d);
  Result := Format('#%.*d-%.*d-%.*d#', [4, y, 2, m, 2, d]);
end;

function DateTimeForSQL(const pDateTime: Tdatetime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', pDateTime);
end;

function RepeatString(const s: string; Count: cardinal): string;
var
  i: integer;
begin
  for i := 1 to Count do
    Result := Result + s;
end;

function removeLeadingZeros(const Value: string): string;
var
  i: integer;
begin
  for i := 1 to Length(Value) do
    if Value[i] <> '0' then
    begin
      Result := Copy(Value, i, MaxInt);
      exit;
    end;
  Result := '';
end;

function tiempo_Transcurrido(pStartTime: DWORD; pEndTime: DWORD): string;
var
  ElapsedTime: DWORD;
  Estimated_hours: DWORD;
  Estimated_Minutes: DWORD;
  Estimated_seconds: DWORD;
begin
  ElapsedTime := pEndTime - pStartTime;
  // calculo de horas minutos y segundos
  Estimated_hours := (ElapsedTime div (3600 * 999)) mod 24;
  Estimated_Minutes := (ElapsedTime div (60 * 999)) mod 60;
  Estimated_seconds := (ElapsedTime div 999) mod 60;
  if (Estimated_hours + Estimated_Minutes) = 0 then
    Result := 'Tiempo Transcurrido: ' + IntToStr(Estimated_seconds) + ' Segundos. '
  else
    Result := 'Tiempo Transcurrido: ' + IntToStr(Estimated_hours) + ':' + IntToStr(Estimated_Minutes) + ':' + IntToStr(Estimated_seconds);
end;

function ReplaceDatePart(pDateTime: Tdatetime; pDateReplace: Tdatetime): Tdatetime;
var
  oDay, oMonth, oYear, oHour, oMinute, oSecond, oMilli: Word;
  rDay, rMonth, rYear: Word;
begin
  DecodeDateTime(pDateTime, oYear, oMonth, oDay, oHour, oMinute, oSecond, oMilli);
  DecodeDate(pDateReplace, rYear, rMonth, rDay);
  Result := EncodeDateTime(rYear, rMonth, rDay, oHour, oMinute, oSecond, oMilli);
end;

function TimeToDateTime(pTime: Ttime): Tdatetime;
begin
  Result := StrToDateTime(FormatDateTime('yyyy-mm-dd', Now) + ' ' + TimeToStr(pTime));
end;

function esPrimo(X: integer): Boolean;
var
  i, r: Longint;
begin
  r := Round(sqrt(X));
  for i := 2 to r do
    if (X mod i = 0) then
    begin
      esPrimo := False;
      exit;
    end;
  esPrimo := True;
end;

{ ********************************************************************* }
{ Strip('L',' ',' bob') returns 'bob' }
{ Strip('R','5','56345') returns '5634' }
{ Strip('B','H','HASH') returns 'as' }
{ strip('A','E','fleetless') returns fltlss }
{ ********************************************************************* }
function Strip(L, c: Char; Str: string): string;
{ L is left,center,right,all,ends }
var
  i: Byte;
begin
  case Upcase(L) of
    'L':
      begin { Left }
        while (Str[1] = c) and (Length(Str) > 0) do
          Delete(Str, 1, 1);
      end;
    'R':
      begin { Right }
        while (Str[Length(Str)] = c) and (Length(Str) > 0) do
          Delete(Str, Length(Str), 1);
      end;
    'B':
      begin
        { Both left and right }
        while (Str[1] = c) and (Length(Str) > 0) do
          Delete(Str, 1, 1);
        while (Str[Length(Str)] = c) and (Length(Str) > 0) do
          Delete(Str, Length(Str), 1);
      end;
    'A':
      begin { All }
        i := 1;
        repeat
          if (Str[i] = c) and (Length(Str) > 0) then
            Delete(Str, i, 1)
          else
            i := succ(i);
        until (i > Length(Str)) or (Str = '');
      end;
  end;
  Strip := Str;
end; { Func Strip }


{ -----------------------------------------------------------------------------------------------------
  El sistema contiene en una de sus tablas almacenada la notación de separador de miles y decimales
  esta información cuando el sistema inicia se carga en dos variables.
  en esta funcion se toma el valor de esas variables y se les asigna al la configuracion del software.
  J.G.G. junio 2010.
  ------------------------------------------------------------------------------------------------------ }

procedure Set_Decinal_Thousand_Separator;
begin
  FormatSettings.DecimalSeparator := cpDecimales;
  FormatSettings.ThousandSeparator := cpThousand;
end;

{ -------------------------------------------------------------------------------------------
  Devido a que esta funciona manda error cuando la totacion de decimales es coma ",", hemos
  creado esta funcion que lo que hace es colocar en punto '.' la notacion de decimales, hacer
  la operación y luego lo vuelve a colocar como estab en el sistema anteriormente
  J.G.G. julio 2010.
  -------------------------------------------------------------------------------------------- }

function FloatToStr2(Value: Extended): string;
begin
  FormatSettings.DecimalSeparator := '.';
  Result := floattostr(Value);
  Set_Decinal_Thousand_Separator;
end;

function strTran(cText, cfor, cwith: string): string;
var
  ntemp: Word;
  nreplen: Word;
begin
  cfor := UpperCase(cfor);
  nreplen := Length(cfor);
  for ntemp := 1 to Length(cText) do
  begin
    if (UpperCase(Copy(cText, ntemp, nreplen)) = cfor) then
    begin
      Delete(cText, ntemp, nreplen);
      Insert(cwith, cText, ntemp);
    end;
  end;
  Result := cText;
end;

{ -----------------------------------------------------------------------------------------------
  Esta función sólo funciona para datos numéricos he indica si un valor esta en el rango indicado
  ------------------------------------------------------------------------------------------------ }

function between(nval, nmin, nmax: Longint): Boolean;
begin
  Result := False;
  if (nval >= nmin) and (nval <= nmax) then
    Result := True;
end;

{ -----------------------------------------------------------------------------------------------
  Esta funcion convierte de segundos a horas en formato 'hh:mm:ss'.
  ------------------------------------------------------------------------------------------------ }
function SecToTime(Sec: integer): string;
var
  H, m, s: string;
  ZH, ZM, ZS: integer;
begin
  ZH := Sec div 3600;
  ZM := Sec div 60 - ZH * 60;
  ZS := Sec - (ZH * 3600 + ZM * 60);
  H := IntToStr(ZH);
  m := IntToStr(ZM);
  s := IntToStr(ZS);
  Result := H + ':' + m + ':' + s;
end;

{ --------------------------------------------------------------------------------------------
  Unformat a formatted integer or float. Used for CSV export and composing WHERE clauses for grid editing.
  ---------------------------------------------------------------------------------------------- }

function UnformatNumber(Val: string): string;
begin
  Result := Val;
  if FormatSettings.ThousandSeparator <> FormatSettings.DecimalSeparator then
    Result := StringReplace(Result, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
  Result := StringReplace(Result, FormatSettings.DecimalSeparator, '.', [rfReplaceAll]);
end;

{ --------------------------------------------------------------------------------------------
  Return a formatted integer or float from a string
  @param string Text containing a number
  @return string
  ---------------------------------------------------------------------------------------------- }

function FormatNumber(Str: string; Thousands: Boolean = True): string; overload;
var
  i, P, Left: integer;
begin

  Result := StringReplace(Str, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  if Thousands then
  begin
    if ((Length(Result) >= 1) and (Result[1] = '0')) or ((Length(Result) >= 2) and (Result[1] = '-') and (Result[2] = '0')) then
      exit;
    P := pos(FormatSettings.DecimalSeparator, Result);
    if P = 0 then
      P := Length(Result) + 1;
    Left := 2;
    if (Length(Result) >= 1) and (Result[1] = '-') then
      Left := 3;
    if P > 0 then
      for i := P - 1 downto Left do
      begin
        if (P - i) mod 3 = 0 then
          Insert(FormatSettings.ThousandSeparator, Result, i);
      end;
  end;
end;

{ --------------------------------------------------------------------------------------------
  Return a formatted number from an integer
  @param int64 Number to format
  @return string
  ---------------------------------------------------------------------------------------------- }

function FormatNumber(int: Int64; Thousands: Boolean = True): string; overload;
begin
  Result := FormatNumber(IntToStr(int), Thousands);
end;

{ --------------------------------------------------------------------------------------------
  Return a formatted number from a float This function TfUtilesV20.is called by two overloaded functions
  @param double Number to format
  @param integer Number of decimals
  @return string
  ---------------------------------------------------------------------------------------------- }

function FormatNumber(flt: Double; decimals: integer = 0; Thousands: Boolean = True): string; overload;
begin
  Result := Format('%10.' + IntToStr(decimals) + 'f', [flt]);
  Result := Trim(Result);
  Result := FormatNumber(Result, Thousands);
end;

{ --------------------------------------------------------------------------------------------
  Return true if given character represents a number.
  Limitations: only recognizes ANSI numerals.
  Eligible for inlining, hope the compiler does this automatically.
  ---------------------------------------------------------------------------------------------- }
function IsNumber(const c: Char): Boolean;
var
  B: Word;
begin
  B := ord(c);
  Result := (B >= 48) and (B <= 57);
end;

{ --------------------------------------------------------------------------------------------
  // Esta función muestra el numero de dia que desde enero hasta la fecha x de un año
  //o de una fecha.
  // [Meeus91, p. 65]
  // DayOfYear(1978, 11, 14) = 318
  // DayOfYear(2000, 11, 14) = 319
  ---------------------------------------------------------------------------------------------- }

function DayOfYear(const Year, Month, Day: Word): integer;
var
  k: Word;
begin
  if IsLeapYear(Year) then
    k := 1
  else
    k := 2;
  Result := Trunc(275 * Month / 9) - k * Trunc((Month + 9) / 12) + Day - 30;
end; { DayOfYear }

{ --------------------------------------------------------------------------------------------
  Esta función muestra la fecha del correspondiente al ùltimo día del mes.
  ---------------------------------------------------------------------------------------------- }

function LastDayInMonth(const Year, Month: Word): Tdatetime;
begin
  if Month = 12 then
    Result := EncodeDate(Year + 1, 1, 1) - 1
  else
    Result := EncodeDate(Year, Month + 1, 1) - 1;
end;

function Execute_SQL_Result(pSQL: string): string; overload;
begin
  if isEmpty(pSQL) = True then
  begin
    Result := '';
    exit;
  end;
  Result := '';

  oPub_Qry.Connection := oPub_Con;
  oPub_Qry.SQL.text := pSQL;
  try
    oPub_Qry.Open;
    if oPub_Qry.Fields[0].IsNull then
      Result := ''
    else
      Result := oPub_Qry.Fields[0].AsString;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(pSQL);
      Result := ''
    end;
  end;
  oPub_Qry.close;
end;

function Execute_SQL_Result(oConn_Tmp: TFDConnection; pSQL: string): string; overload;
begin
  if isEmpty(pSQL) = True then
  begin
    Result := '';
    exit;
  end;

  oPub_Qry.Connection := oConn_Tmp;
  oPub_Qry.SQL.text := pSQL;
  try
    oPub_Qry.Open;
    if oPub_Qry.Fields[0].IsNull then
      Result := ''
    else
      Result := oPub_Qry.Fields[0].AsString;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(pSQL);
      Result := ''
    end;
  end;
  oPub_Qry.close;
end;

function Execute_SQL_Query(var oQry: TFDQuery; sSql: TStringList; oQryExec: Boolean = False): Boolean; overload;
begin
  if (oQry = nil) then
    oQry := TFDQuery.Create(nil);

  oQry.Connection := oPub_Con;
  oQry.close;
  oQry.SQL.Clear;
  oQry.SQL.text := sSql.text;

  try
    if (oQryExec = True) then
    begin
      oQry.ExecSQL;
      Result := True;
    end
    else
    begin
      oQry.Open;
      Result := (oQry.Fields[0].IsNull = False);
    end;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(sSql.text);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Query(oConn_Tmp: TFDConnection; var oQry: TFDQuery; sSql: string; oQryExec: Boolean = False): Boolean; overload;
begin
  if (oQry = nil) then
    oQry := TFDQuery.Create(nil);

  oQry.close;
  oQry.Connection := oConn_Tmp;
  oQry.SQL.Clear;
  oQry.SQL.text := sSql;
  try
    if (oQryExec = True) then
    begin
      oQry.ExecSQL;
      Result := True;
    end
    else
    begin
      oQry.Open;
      Result := (oQry.Fields[0].IsNull = False);
    end;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(sSql);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Query(var oQry: TFDQuery; sSql: string; oQryExec: Boolean = False): Boolean; overload;
begin

  if (oQry = nil) then
    oQry := TFDQuery.Create(nil);

  oQry.Connection := oPub_Con;
  oQry.close;
  oQry.SQL.Clear;
  oQry.SQL.text := sSql;

  try
    if (oQryExec = True) then
    begin
      oQry.ExecSQL;
      Result := True;
    end
    else
    begin
      oQry.Open;
      Result := (oQry.Fields[0].IsNull = False);
    end;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(sSql);
      Result := False;
    end;
  end;
end;

function query_selectgen_result(text: string): string;
begin
  try
    //oPub_Qry := TFDQuery.Create(nil);
    oPub_Qry.Connection := oPub_Con;
    oPub_Qry.Active := False;
    oPub_Qry.SQL.Clear;
    oPub_Qry.SQL.text := text;
    oPub_Qry.Open;
    if oPub_Qry.Fields[0].text <> '' then
      Result := oPub_Qry.Fields[0].text
    else
      Result := oPub_Qry.Fields[0].text;
  except
    Result := '';
  end;
  oPub_Qry.close;
end;


{ -------------------------------------------------------------------------------------------------
  Esta funcion que es una extención de Execute_SQL_Command, ejecuta uan cadena de comandos separados
  por ; y las ejecuta al mismo tiempo en un string no muy grande.
  -------------------------------------------------------------------------------------------------- }
function Execute_SQL_Command(pSQL: string): Boolean; overload;
begin
  if isEmpty(pSQL) = True then
  begin
    Result := False;
    exit;
  end;
  Result := False;

  try
    oPub_Cmd.Connection := oPub_Con;
    oPub_Cmd.CommandText.Clear;
    oPub_Cmd.CommandText.text := pSQL;
    oPub_Cmd.Execute;
    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      Application.ShowException(E);
      ShowMessage(pSQL)
    end;
  end;
end;

{ -------------------------------------------------------------------------------------------------
  Esta funcion que es una extención de Execute_SQL_Command, ejecuta uan cadena de comandos separados
  por ; y las ejecuta al mismo tiempo
  -------------------------------------------------------------------------------------------------- }
function Execute_SQL_Script(oConn_Tmp: TFDConnection; pScript: TStrings): Boolean; overload;
begin
  if isEmpty(pScript.text) = True then
  begin
    Result := False;
    exit;
  end;

  oPub_Scrp.Connection := oConn_Tmp;
  oPub_Scrp.SQLScripts.Clear;
  oPub_Scrp.SQLScripts.Add;
  oPub_Scrp.SQLScripts[0].SQL.text := pScript.text;
  try
    oPub_Scrp.ValidateAll;
    oPub_Scrp.ExecuteAll;
    Result := True;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(pScript.text);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Script(pScript: string): Boolean; overload;
begin
  if isEmpty(pScript) = True then
  begin
    Result := False;
    exit;
  end;

  oPub_Scrp.Connection := oPub_Con;
  oPub_Scrp.SQLScripts.Clear;
  oPub_Scrp.SQLScripts.Add;
  oPub_Scrp.SQLScripts[0].SQL.text := pScript;
  try
    oPub_Scrp.ValidateAll;
    oPub_Scrp.ExecuteAll;
    Result := True;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(pScript);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Script(pScript: TStrings): Boolean; overload;
begin
  if isEmpty(pScript.text) = True then
  begin
    Result := False;
    exit;
  end;

  oPub_Scrp.Connection := oPub_Con;
  oPub_Scrp.SQLScripts.Clear;
  oPub_Scrp.SQLScripts.Add;
  oPub_Scrp.SQLScripts[0].SQL.text := pScript.text;
  try
    oPub_Scrp.ValidateAll;
    oPub_Scrp.ExecuteAll;
    Result := True;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(pScript.text);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Command(pScript: TStringList): Boolean; overload;
begin

  if isEmpty(pScript.text) = True then
  begin
    Result := False;
    exit;
  end;

  oPub_Scrp.Connection := oPub_Con;
  oPub_Scrp.SQLScripts.Clear;
  oPub_Scrp.SQLScripts.Add;
  oPub_Scrp.SQLScripts[0].SQL.text := pScript.text;
  try
    oPub_Scrp.ValidateAll;
    oPub_Scrp.ExecuteAll;
    Result := True;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      ShowMessage(pScript.text);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Command_Tmp(pSQL: string; oSetting_Tmp: Config2): Boolean; overload;
begin
  oPub_Con_Tmp.Params.Clear;
  oPub_Con_Tmp.Params.Add('DriverID=MySQL');
  oPub_Con_Tmp.Params.Add('Server=' + oSetting_Tmp.host);
  oPub_Con_Tmp.Params.Add('Database=' + oSetting_Tmp.database);
  oPub_Con_Tmp.Params.Add('CharacterSet=utf8');
  oPub_Con_Tmp.Params.Add('User_Name=' + oSetting_Tmp.usuario);
  oPub_Con_Tmp.Params.Add('Password=' + oSetting_Tmp.clave);
  oPub_Con_Tmp.Params.Add('Port=' + IntToStr(oSetting_Tmp.puerto));
  oPub_Con_Tmp.Params.Add('MetaDefCatalog=' + oSetting_Tmp.database);
  oPub_Con_Tmp.Params.Add('MetaCurCatalog=' + oSetting_Tmp.database);
  oPub_Con_Tmp.LoginPrompt := False;

  try
    oPub_Con_Tmp.Connected := True;

    oPub_Cmd.Connection := oPub_Con_Tmp;
    oPub_Cmd.CommandText.Clear;
    oPub_Cmd.CommandText.text := pSQL;
    oPub_Cmd.Execute;
    Result := True;
  finally
    Result := False;
  end;
end;

function Execute_SQL_Command_Tmp(pSQL: string; oConn_Tmp: TFDConnection): Boolean; overload;
begin
  try
    oPub_Cmd.Connection := oConn_Tmp;
    oPub_Cmd.CommandText.Clear;
    oPub_Cmd.CommandText.text := pSQL;
    oPub_Cmd.Execute;
    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
    end;
  end;
end;

function Execute_SQL_Command_Tmp(pScript: TStringList; oConn_Tmp: TFDConnection): Boolean; overload;
var
  SqlProcessor: TFDScript;
begin
  if isEmpty(pScript.text) = True then
  begin
    Result := False;
    exit;
  end;

  oPub_Scrp.Connection := oConn_Tmp;
  oPub_Scrp.SQLScripts.Clear;
  oPub_Scrp.SQLScripts.Add;
  oPub_Scrp.SQLScripts[0].SQL.text := pScript.text;
  try
    oPub_Scrp.ValidateAll;
    oPub_Scrp.ExecuteAll;
    Result := True;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      Result := False;
    end;
  end;
end;

function Execute_SQL_Command_Tmp_Fle(pFilename: string; oConn_Tmp: TFDConnection): Boolean; overload;
begin
  if isEmpty(pFilename) = True then
  begin
    Result := False;
    exit;
  end;

  oPub_Scrp.Connection := oConn_Tmp;
  oPub_Scrp.SQLScripts.Clear;
  oPub_Scrp.SQLScripts.Add;
  oPub_Scrp.SQLScripts[0].SQL.LoadFromFile(pFilename);
  try
    oPub_Scrp.ValidateAll;
    oPub_Scrp.ExecuteAll;
    Result := True;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      Result := False;
    end;
  end;
end;

procedure active_device(cClave: string);
var
  cSql_Ln: string;
  cNow: string;
begin
  cSql_Ln := '';
  cNow := Pub_Unit.DateTimeForSQL(now());

  Pub_Unit.Execute_SQL_Command('DELETE FROM dispositivos');

  cSql_Ln := '';
  cSql_Ln := cSql_Ln + 'INSERT INTO dispositivos (serial, fecha_pacceso,clave_install,acceso_periodo,fecha_desde,fecha_hasta,acceso_subidas,subidas_counter,subidas_total) VALUES ';
  cSql_Ln := cSql_Ln + '("' + cid_device + '","' + cNow + '","' + cClave + '",0,null,null,0,0)';
  Pub_Unit.Execute_SQL_Command(cSql_Ln);
end;

procedure Create_Sql_Tables(bDropTables: Boolean = false);
var
  cSql_Ln: string;
begin

  if (bDropTables = true) then
  begin
    Pub_Unit.Execute_SQL_Command('DROP TABLE IF EXISTS dispositivos');
  end;

  cSql_Ln := '';
  cSql_Ln := cSql_Ln + 'CREATE TABLE IF NOT EXISTS dispositivos (';
  cSql_Ln := cSql_Ln + 'id              INTEGER     NOT NULL,';
  cSql_Ln := cSql_Ln + 'emp_id          INT(3)      NULL DEFAULT 0,';
  cSql_Ln := cSql_Ln + 'serial          VARCHAR(50) NULL DEFAULT "",';
  cSql_Ln := cSql_Ln + 'nom_enti        VARCHAR(50) NULL DEFAULT "",';
  cSql_Ln := cSql_Ln + 'nom_oper        VARCHAR(50) NULL DEFAULT "",';
  cSql_Ln := cSql_Ln + 'dev_mail        VARCHAR(50) NULL DEFAULT "",';
  cSql_Ln := cSql_Ln + 'clave_install   VARCHAR(30) NULL DEFAULT "",';
  cSql_Ln := cSql_Ln + 'fecha_pacceso   DATETIME    NULL DEFAULT NULL,';
  cSql_Ln := cSql_Ln + 'fecha_uacceso   DATETIME    NULL DEFAULT NULL,';
  cSql_Ln := cSql_Ln + 'dbname          VARCHAR(30) NULL DEFAULT "",';
  cSql_Ln := cSql_Ln + 'acceso_periodo  INT(1)      NULL DEFAULT 0,';
  cSql_Ln := cSql_Ln + 'fecha_desde     DATETIME    NULL DEFAULT NULL,';
  cSql_Ln := cSql_Ln + 'fecha_hasta     DATETIME    NULL DEFAULT NULL,';
  cSql_Ln := cSql_Ln + 'acceso_subidas  INT(1)      NULL DEFAULT 0,';
  cSql_Ln := cSql_Ln + 'subidas_counter INT(11)     NULL DEFAULT 0,';
  cSql_Ln := cSql_Ln + 'subidas_total   INT(11)     NULL DEFAULT 0,';
  cSql_Ln := cSql_Ln + 'CONSTRAINT dispositivos PRIMARY KEY (id))';
  Pub_Unit.Execute_SQL_Command(cSql_Ln);
end;

function Instaled_Database(): Boolean;
var
  cSql_Ln, cResult: string;
begin
  cSql_Ln := 'SELECT COUNT(*) as cExist FROM sqlite_master WHERE type = "table" AND name = "dispositivos"';
  cResult := Pub_Unit.query_selectgen_result(cSql_Ln);
  if (Trim(cResult) = '') then
    cResult := '0';
  if (StrToInt(cResult) > 0) then
    result := True
  else
    result := false;
end;

procedure check_tables_device(bDrop: boolean = false);
var
  cSql_Ln: string;
begin
  cSql_Ln := '';
  if (bDrop = true) then
  begin
    cSql_Ln := '';
    cSql_Ln := cSql_Ln + 'DROP TABLE IF EXISTS dispositivos;';
    Pub_Unit.Execute_SQL_Command(cSql_Ln);

    cSql_Ln := '';
    cSql_Ln := cSql_Ln + 'CREATE TABLE dispositivos (';
    cSql_Ln := cSql_Ln + 'id              INTEGER     NOT NULL,';
    cSql_Ln := cSql_Ln + 'emp_id          INT(3)      NULL DEFAULT 0,';
    cSql_Ln := cSql_Ln + 'serial          VARCHAR(50) NULL DEFAULT "",';
    cSql_Ln := cSql_Ln + 'nom_enti        VARCHAR(50) NULL DEFAULT "",';
    cSql_Ln := cSql_Ln + 'nom_oper        VARCHAR(50) NULL DEFAULT "",';
    cSql_Ln := cSql_Ln + 'dev_mail        VARCHAR(50) NULL DEFAULT "",';
    cSql_Ln := cSql_Ln + 'clave_install   VARCHAR(30) NULL DEFAULT "",';
    cSql_Ln := cSql_Ln + 'fecha_pacceso   DATETIME    NULL DEFAULT NULL,';
    cSql_Ln := cSql_Ln + 'fecha_uacceso   DATETIME    NULL DEFAULT NULL,';
    cSql_Ln := cSql_Ln + 'dbname          VARCHAR(30) NULL DEFAULT "",';
    cSql_Ln := cSql_Ln + 'acceso_periodo  INT(1)      NULL DEFAULT 0,';
    cSql_Ln := cSql_Ln + 'fecha_desde     DATETIME    NULL DEFAULT NULL,';
    cSql_Ln := cSql_Ln + 'fecha_hasta     DATETIME    NULL DEFAULT NULL,';
    cSql_Ln := cSql_Ln + 'acceso_subidas  INT(1)      NULL DEFAULT 0,';
    cSql_Ln := cSql_Ln + 'subidas_counter INT(11)     NULL DEFAULT 0,';
    cSql_Ln := cSql_Ln + 'subidas_total   INT(11)     NULL DEFAULT 0,';
    cSql_Ln := cSql_Ln + 'CONSTRAINT dispositivos PRIMARY KEY (id))';
    Pub_Unit.Execute_SQL_Command(cSql_Ln);
  end;
end;

function check_device_data(): Integer;
var
  cNow, cRecords: string;
  iRecords: INTEGER;
  cSql_Ln: string;
begin
  cNow := Pub_Unit.DateTimeForSQL(now());

  cSql_Ln := 'SELECT count(*) FROM dispositivos WHERE serial="' + cid_device + '"';
  cRecords := query_selectgen_result(cSql_Ln);
  if ((Trim(cRecords) = '') or (Trim(cRecords) = 'NULL') or (Trim(cRecords) = 'null')) then
    cRecords := '0';

  iRecords := StrToInt(cRecords);
  Result := iRecords;
end;

function Get_Json_From_Url(cUrl: string): string;
var
  cJsonResp: string;
  cResult: string;
  lrestrequest: TRESTRequest;
  lRestClient: TRESTClient;
  lRestResponce: TRESTResponse;
begin
  cResult := '';
  cJsonResp := '';
  if (trim(cUrl) <> '') then
  begin

    lRestClient := TRESTClient.Create(cUrl);
    try
      lrestrequest := TRESTRequest.Create(nil);
      try
        lRestResponce := TRESTResponse.Create(nil);
        lRestResponce.ContentType := 'application/json';
        try
          lrestrequest.Client := lRestClient;
          lrestrequest.Response := lRestResponce;
          lrestrequest.Method := rmGet;
          lrestrequest.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
          lrestrequest.AcceptCharset := 'utf-8, *;q=0.8';
          lrestrequest.Params.Clear;
          // lrestrequest.Params.AddItem('X-IFX-Token', 'f0210ebdb504c31b20272772a11c55bf', TRESTRequestParameterKind.pkHTTPHEADER);
          // lrestrequest.Body.Add(trim(cJson), REST.Types.ContentTypeFromString('application/json'));
          lrestrequest.Execute;
          if not lRestResponce.Status.Success then
            cResult := lRestResponce.StatusText
          else
            cJsonResp := lRestResponce.content;
        finally
          lRestResponce.Free;
        end;
      finally
        lrestrequest.Free
      end;
    finally
      lRestClient.Free;
    end;
  end;
  Result := cJsonResp;
end;

{
function CheckUrl(url: string): boolean;
var
  hSession, hfile, hRequest: hInternet;
  dwindex, dwcodelen: dword;
  dwcode: array[1..20] of char;
  res: pchar;
begin
  if pos('http://', lowercase(url)) = 0 then
    url := 'http://' + url;
  Result := false;
  hSession := InternetOpen('InetURL:/1.0', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if assigned(hSession) then
  begin
    hfile := InternetOpenUrl(hSession, pchar(url), nil, 0, INTERNET_FLAG_RELOAD, 0);
    dwindex := 0;
    dwcodelen := 10;
    HttpQueryInfo(hfile, HTTP_QUERY_STATUS_CODE, @dwcode, dwcodelen, dwindex);
    res := pchar(@dwcode);
    result := (res = '200') or (res = '302');
    if assigned(hfile) then
      InternetCloseHandle(hfile);
    InternetCloseHandle(hSession);
  end;

end;
}
function CheckUrl(url: string): boolean;
var
  oLMS: TMemoryStream;
  oNetHTTPClient1: TNetHTTPClient;
  oHTTPClient1: THTTPClient;
begin
  Result := true;
  //oNetHTTPClient1 := TNetHTTPClient.create;
  oHTTPClient1 := THTTPClient.create;
  oLMS := TMemoryStream.Create;
  try
    try
      oHTTPClient1.Get(url, oLMS);
    except
      on e: EIdHTTPProtocolException do
      begin
        if (e.ErrorCode = 404) then
        begin
     //Url Not found
          Result := false;
        end
        else
        begin
          Result := false;
        end;
      end
    end;
    oLMS.Position := 0;
  finally
    oLMS.Free;
  end;
end;

function CheckUrl2(url: string): boolean;
var
  oLMS: TMemoryStream;
  oHTTPClient1: THTTPClient;
begin
  oHTTPClient1 := THTTPClient.Create;
  oHTTPClient1.ConnectionTimeout := 200;
  oHTTPClient1.ResponseTimeout := 200;
  Result := true;
  oLMS := TMemoryStream.Create;
  try
    try
      oHTTPClient1.get(url, oLMS);
    except
      on e: ENetHTTPClientException do
      begin
        Result := false;
      end
    end;
    oLMS.Position := 0;
  finally
    oLMS.Free;
    oHTTPClient1.Free;
  end;
end;

function Check_Ip_Disp(): Boolean;
var
  cHost: string;
  i: integer;
begin
  cHost := '';
  Pub_Unit.iSERVER_ITEM_LIST := -1;
  for i := 0 to iSERVER_URL_LIST_CNT do
  begin
    cHost := Pub_Unit.cSERVER_URL_LIST[i];
    if (Pub_Unit.CheckUrl(cHost) = true) then
    begin
      Pub_Unit.iSERVER_ITEM_LIST := i;
      Pub_Unit.cSERVER_URL := cHost;
      Pub_Unit.cSERVER_URL_FLES := Pub_Unit.cSERVER_URL + '/nat_counter/UploadToServer.php';
      Pub_Unit.cSERVER_DIR_IMGS := Pub_Unit.cSERVER_URL + '/nat_counter/images/';
      Break;
    end;
  end;
  if (Pub_Unit.iSERVER_ITEM_LIST < 0) then
    Result := false
  else
    Result := true;
end;

function GetFromJsonResult(cJsonString: string; cFielsName: string): string;
var
  oJsonArray: TJSONArray;
  oJsonValue: TJSONObject;
  oObj: TJSONObject;
  idx, idy: integer;
begin
  oJsonArray := nil;
  oJsonValue := nil;

  oJsonValue := TJSONObject.ParseJSONValue(cJsonString) as TJSONObject;
  if not (oJsonValue is TJSONObject) then
  begin
    oJsonArray := TJSONObject.ParseJSONValue(cJsonString) as TJSONArray;
    for idx := 0 to (oJsonArray.Size - 1) do
    begin
      oJsonValue := oJsonArray.Get(idx) as TJSONObject;
      result := oJsonValue.Get(cFielsName).JsonValue.Value;
    end;
  end
  else
  begin
    result := oJsonValue.Get(cFielsName).JsonValue.Value;
    oJsonValue.Free;
  end;

end;
{
procedure TMainForm.btnParseJSONClick(Sender: TObject);
var
  JSONCars: TJSONArray;
  i: Integer;
  Car, JSONPrice: TJSONObject;
  CarPrice: Double;
  s, CarName, CarManufacturer, CarCurrencyType: string;
begin
  s := '';
  JSONCars := TJSONObject.ParseJSONValue(JSON)
         as TJSONArray;
  if not Assigned(JSONCars) then
    raise Exception.Create('Not a valid JSON');
  try
    for i := 0 to JSONCars.Size - 1 do
    begin
      Car := JSONCars.Get(i) as TJSONObject;
      CarName := Car.Get('name').JsonValue.Value;
      CarManufacturer := Car.Get('manufacturer')
         .JsonValue.Value;
      JSONPrice := Car.Get('price')
         .JsonValue as TJSONObject;
      CarPrice := (JSONPrice.Get('value').JsonValue
                      as TJSONNumber).AsDouble;
      CarCurrencyType := JSONPrice.Get('currency')
                            .JsonValue.Value;
      s := s + Format(
        'Name = %s' + sLineBreak +
        'Manufacturer = %s' + sLineBreak +
        'Price = %.0n%s' + sLineBreak +
        '-----' + sLineBreak,
      [CarName, CarManufacturer,
      CarPrice, CarCurrencyType]);
    end;
    JSON := s;
  finally
    JSONCars.Free;
  end;
end;
}

function StripUnwantedText(cText: string): string;
var
  cResult: string;
begin
  cResult := StringReplace(cText, #13, '', [rfReplaceAll]);
  cResult := StringReplace(cResult, #10, '', [rfReplaceAll]);
  cResult := StringReplace(cResult, #9, '', [rfReplaceAll]);
  cResult := StringReplace(cResult, #13 + #10, '', [rfReplaceAll]);
  Result := cResult
end;

initialization
  cDb_Path := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'm_quick_inv.s3db');

  cSqlCreateDisp := '';
  cSqlCreateDisp := cSqlCreateDisp + 'CREATE TABLE IF NOT EXISTS dispositivos (';
  cSqlCreateDisp := cSqlCreateDisp + 'id              INTEGER     NOT NULL,';
  cSqlCreateDisp := cSqlCreateDisp + 'emp_id          INT(3)      NULL DEFAULT 0,';
  cSqlCreateDisp := cSqlCreateDisp + 'serial          VARCHAR(50) NULL DEFAULT "",';
  cSqlCreateDisp := cSqlCreateDisp + 'nom_enti        VARCHAR(50) NULL DEFAULT "",';
  cSqlCreateDisp := cSqlCreateDisp + 'nom_oper        VARCHAR(50) NULL DEFAULT "",';
  cSqlCreateDisp := cSqlCreateDisp + 'dev_mail        VARCHAR(50) NULL DEFAULT "",';
  cSqlCreateDisp := cSqlCreateDisp + 'clave_install   VARCHAR(30) NULL DEFAULT "",';
  cSqlCreateDisp := cSqlCreateDisp + 'fecha_pacceso   DATETIME    NULL DEFAULT NULL,';
  cSqlCreateDisp := cSqlCreateDisp + 'fecha_uacceso   DATETIME    NULL DEFAULT NULL,';
  cSqlCreateDisp := cSqlCreateDisp + 'dbname          VARCHAR(30) NULL DEFAULT "",';
  cSqlCreateDisp := cSqlCreateDisp + 'acceso_periodo  INT(1)      NULL DEFAULT 0,';
  cSqlCreateDisp := cSqlCreateDisp + 'fecha_desde     DATETIME    NULL DEFAULT NULL,';
  cSqlCreateDisp := cSqlCreateDisp + 'fecha_hasta     DATETIME    NULL DEFAULT NULL,';
  cSqlCreateDisp := cSqlCreateDisp + 'acceso_subidas  INT(1)      NULL DEFAULT 0,';
  cSqlCreateDisp := cSqlCreateDisp + 'subidas_counter INT(11)     NULL DEFAULT 0,';
  cSqlCreateDisp := cSqlCreateDisp + 'subidas_total   INT(11)     NULL DEFAULT 0,';
  cSqlCreateDisp := cSqlCreateDisp + 'CONSTRAINT dispositivos PRIMARY KEY (id)); ';

  oPub_Drv := TFDPhysSQLiteDriverLink.Create(nil);
  oPub_Drv.DriverID := 'SQLite';

  oConnParams := TStringList.Create;
  oConnParams.Add('Database=' + cDb_Path);
  oConnParams.Add('OpenMode=CreateUTF8');
  oConnParams.Add('DateTimeFormat=String');

  //oPub_Mang := TFDManager.Create(nil);
  //oPub_Mang.AddConnectionDef('quick_inv', 'SQLite', oConnParams);

  oPub_Con := TFDConnection.Create(nil);
  oPub_Con_Tmp := TFDConnection.Create(nil);
  //oPub_Con.ConnectionDefName := 'quick_inv';


  oPub_Con.ConnectionDefName := '';
  oPub_Con.DriverName := 'SQLite';
  oPub_Con.Params.Values['Database'] := cDb_Path;
  oPub_Con.Params.Values['OpenMode'] := 'CreateUTF8';
  oPub_Con.Params.Values['DateTimeFormat'] := 'String';
  oPub_Con.LoginDialog := nil;
  oPub_Con.LoginPrompt := false;
  oPub_Con.Connected := true;

  oPub_Cmd := TFDCommand.Create(nil);
  oPub_Qry := TFDQuery.Create(nil);
  oPub_Scrp := TFDScript.Create(nil);

  oPub_Cmd.Connection := oPub_Con;
  oPub_Qry.Connection := oPub_Con;
  oPub_Scrp.Connection := oPub_Con;

  oHTTP_Get := TNetHTTPClient.Create(nil);
  oHTTP_Post := TNetHTTPClient.Create(nil);
  oHTTP_Get.Tag := HTTP_GET_NOT_BUSY;
  oHTTP_Post.Tag := HTTP_POST_NOT_BUSY;

  iSERVER_ITEM_LIST := 0;
  cSERVER_URL := 'http://centenariopma.hopto.org';
  iSERVER_URL_LIST_CNT := 1; {0,1}
  cSERVER_URL_LIST := ['http://centenariopma.hopto.org', 'http://127.0.0.1'];
  cSERVER_URL_FLES := cSERVER_URL + '/nat_counter/UploadToServer.php';
  cSERVER_DIR_IMGS := cSERVER_URL + '/nat_counter/images/';

  cId_Device := UpperCase(Pub_Unit.get_Device_id());

finalization
  FreeAndNil(oPub_Con);
  FreeAndNil(oPub_Drv);
  FreeAndNil(oPub_Mang);
  FreeAndNil(oPub_Cmd);
  FreeAndNil(oPub_Qry);
  FreeAndNil(oPub_Scrp);
  FreeAndNil(oConnParams);

end.

