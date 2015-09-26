program consistometer;

{$MODE Delphi}

uses
  Forms, Interfaces,
  consistometer_u in 'consistometer_u.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ConsistoMeter';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
