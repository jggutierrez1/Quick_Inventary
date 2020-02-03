unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, REST.Types, FMX.ScrollBox, FMX.Memo,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, System.JSON;

type
  TForm1 = class(TForm)
    btn1: TButton;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    oHttp_Result: TMemo;
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TForm1.btn1Click(Sender: TObject);
var
  cJsonResult: string;
  jValue: TJsonValue;
begin
  self.btn1.Enabled := False;

  self.RESTRequest1.Execute;
  cJsonResult := self.RESTResponse1.Content;
  // jValue := self.RESTResponse1.JsonValue;
  // cJsonResult := jValue.ToString;

  self.oHttp_Result.Text := cJsonResult;

end;

end.
