program consistometer;

uses
  Forms,
  consistometer_u in 'consistometer_u.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'ConsistoMeter';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
