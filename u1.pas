unit u1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, IniFiles, Gauges;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure UpDownMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form1: TForm1;

implementation

{$R *.DFM}
const
 rng = 8;
var
 LevelLabel : array[1..rng] of TLabel;
 VolumeLabel : array[1..rng] of TLabel;
 LevelUpDown : array[1..rng] of TUpDown;
 Gauge : array[1..rng] of TGauge;
 SettingsFile : TIniFile;
 SettingsFileName : string;

procedure TForm1.FormCreate(Sender: TObject);
var
 i, cd : integer;
 po : real;
 ps : string;
begin
    for i:=1 to rng do
     begin
       VolumeLabel[i]:=TLabel.Create(VolumeLabel[i]);
       VolumeLabel[i].Left:=3;
       VolumeLabel[i].Parent:=Form1;
       VolumeLabel[i].AutoSize:=False;
       VolumeLabel[i].Top:=(i-1)*VolumeLabel[i].Height+5;
       VolumeLabel[i].Width:=30;
       VolumeLabel[i].Caption:='abc';

       LevelLabel[i]:=TLabel.Create(LevelLabel[i]);
       LevelLabel[i].Parent:=Form1;
       LevelLabel[i].AutoSize:=False;
       LevelLabel[i].Left:=VolumeLabel[i].Left+VolumeLabel[i].Width+5;
       LevelLabel[i].Top:=VolumeLabel[i].Top;
       LevelLabel[i].Height:=VolumeLabel[i].Height;
       LevelLabel[i].Width:=30;
       LevelLabel[i].Caption:='abc';


       LevelUpDown[i]:=TUpDown.Create(LevelUpDown[i]);
       LevelUpDown[i].Parent:=Form1;
       LevelUpDown[i].Tag:=i;
       LevelUpDown[i].Orientation:=udHorizontal;
       LevelUpDown[i].Left:=LevelLabel[i].Left+LevelLabel[i].Width+5;
       LevelUpDown[i].Top:=LevelLabel[i].Top-1;
       LevelUpDown[i].Width:=2*LevelLabel[i].Height;
       LevelUpDown[i].Height:=LevelLabel[i].Height;
       LevelUpDown[i].OnMouseUp:=UpDownMouseUp;
       LevelUpDown[i].OnChanging:=UpDownChanging;

       Gauge[i]:=TGauge.Create(Gauge[i]);
       Gauge[i].Parent:=Form1;
       Gauge[i].Kind:=gkHorizontalBar;
       Gauge[i].Left:=LevelUpDown[i].Left+LevelUpDown[i].Width+5;
       Gauge[i].Top:=LevelUpDown[i].Top+6;
       Gauge[i].Height:=5;
       Gauge[i].Width:=100;
       Gauge[i].ShowText:=false;

     end;
    SettingsFileName:='c:\atx300b\consist\p1.ini';
    SettingsFile:=TIniFile.Create(SettingsFileName);
    for i:=1 to rng do
     begin
       VolumeLabel[i].Caption:=SettingsFile.ReadString('Consist', 'V'+IntTostr(i), '');
     end;
    for i:=1 to rng do
     begin
       ps:=SettingsFile.ReadString('Consist', 'R'+IntTostr(i), '');
        while Pos(',', ps) > 0 do
         ps[Pos(',', ps)]:= '.';
       Val(ps,po, cd);
       LevelUpDown[i].Position:=Round(po*100);
       Gauge[i].Progress:=LevelUpDown[i].Position;
       LevelLabel[i].Caption:=FloatToStr(LevelUpDown[i].Position/100);
     end;
    SettingsFile.Free;
end;


procedure TForm1.UpDownMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 i : integer;
begin
 LevelLabel[TUpDown(Sender).Tag].Caption:=FloatToStr((TUpDown(Sender).Position)/TUpDown(Sender).Max);
 SettingsFile:=TIniFile.Create(SettingsFileName);
 for i:=1 to rng do
  begin
    SettingsFile.WriteString('Consist', 'R'+IntTostr(i), LevelLabel[i].Caption);
  end;
 SettingsFile.Free;
 Gauge[TUpDown(Sender).Tag].Progress:=TUpDown(Sender).Position;
end;


procedure TForm1.UpDownChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
   LevelLabel[TUpDown(Sender).Tag].Caption:=FloatToStr((TUpDown(Sender).Position)/TUpDown(Sender).Max);
   Gauge[TUpDown(Sender).Tag].Progress:=TUpDown(Sender).Position;
end;

end.

{ VolumeLabel[TUpDown(Sender).Tag].Caption:=FloatToStr((TUpDown(Sender).Position-1)/TUpDown(Sender).Max);
}
