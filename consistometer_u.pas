unit consistometer_u;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FileCtrl, ComCtrls, FileUtil;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Measure: TButton;
    Graph: TButton;
    Image2: TImage;
    LabelKonz: TLabel;
    Timer2: TTimer;
    Level: TButton;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    TrackBar5: TTrackBar;
    StaticText5: TStaticText;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure MeasureClick(Sender: TObject);
    procedure GraphClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure LevelClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);

    procedure UpDownMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
{................}
  function MemShOpen(ApplicationName : PChar) : longint; stdcall; external 'libsh.dll';
  function MemShClose : longint;  stdcall;external 'libsh.dll';

  function MemShGetIdentVarName(VarName : PChar) : Longint; stdcall; external 'libsh.dll';

  function MemShGetTypeVar(Ident : longint): Char;  stdcall; external 'libsh.dll';
  function MemShGetSizeVar(Ident : longint): longint;  stdcall; external 'libsh.dll';
  function MemShReadVar(Ident : longint; {var} Pdat : pointer) : longint; stdcall;external 'libsh.dll';
  function MemShWriteVar(Ident : longint; {var} Pdat : pointer): longint; stdcall;  external 'libsh.dll';

  function MemShGetTypeVarName(VarName : PChar): Char;  stdcall; external 'libsh.dll';
  function MemShGetSizeVarName(VarName : PChar): longint;  stdcall; external 'libsh.dll';
  function MemShWriteVarName(VarName : PChar; {var} Pdat : pointer): longint; stdcall;  external 'libsh.dll';
  function MemShReadVarName(VarName : PChar; {var} Pdat : pointer) : longint; stdcall;external 'libsh.dll';

  function MemShReadApplicationCount : longint; stdcall; external 'libsh.dll';
  function MemShLengthPcharMax : longint; stdcall; external 'libsh.dll';
{................}

var
  Form1: TForm1;
{--------------------------------------------------------------------------------}
implementation
uses
    IniFiles, Registry, Gauges;
{$R *.lfm}
const
   NameMixer1On           = 'GI_Mixer1_on';
   NameConsistencyDisplay = 'G_Mixer1_Consistency_Display';
   NameConsistencyDegree  = 'W_Consistency_Degree';
   NameOrderCode         = 'G_Mixer1_Order_Code';
   NameRecipeCode         = 'G_Mixer1_Recipe_Code';
   NameBatchState         = 'G_Mixer1_Batch_State';
   NameBatchVolume        = 'G_Mixer1_Batch_Volume';
   NameConsistency_T1     = 'W_Consistency_T1';
   NameConsistency_T2     = 'W_Consistency_T2';
   NameConsistency_T3     = 'W_Consistency_T3';
const
 rng = 8;

var
   IdentMixer1On,
   IdentConsistencyDisplay,
   IdentConsistencyDegree : longint;

   Mixer1On           : byte;
   ConsistencyDisplay : double;
   ConsistencyDegree  : byte;
   PMixer1On           : ^byte;
   PConsistencyDisplay : ^double;
   PConsistencyDegree  : ^byte;

   IdentOrderCode,
   IdentRecipeCode,
   IdentBatchState,
   IdentBatchVolume        : longint;
   OrderCode,
   RecipeCode,
   BatchState,
   BatchVolume             : PChar;

   IdentConsistency_T1,
   IdentConsistency_T2,
   IdentConsistency_T3     : longint;
   Consistency_T1,
   Consistency_T2,
   Consistency_T3          : PChar;

 var
   SelfFileName : string;
   WorkName : string;
   LogFileName : string;
   LogFile : text;
   cd : byte;
   M1konz : byte;
   //FileIni : TIniFile;
   //StatusFile : TIniFile;
   StatusFileName : string;
   IniFile : TIniFile;
   IniFileName : string;
   //FileIniName, koef : string;
   suda : integer;
   //Index_W_SKonz : longint;
   //Index_W_NulaKonz : longint;
   SKonz : array[1..10] of integer;
   PtrPtr   : pointer;
   start : boolean;
   //Cislo_prihlaseni : byte;
   KoefKonz  : real;
   //err : integer;
   Measure_NoGraf : boolean;
   Sk : byte;
   Tara : single;
   //Error : boolean;
   chyba_zapisu : longint;
   konzistence : integer;
   TimeControl1, TimeControl2 : Integer;
   Zapis1, Zapis2 : boolean;
   StartTime : DWord;
   MixTime : DWord;
   vypust : boolean;
   CountFile : longint;
   Consi1, Consi2, Consi3 : string;
   SettingsFile : TIniFile;
   SettingsFileName : string;
   MaxWidthForm1 : integer;
var
 LevelLabel : array[1..rng] of TLabel;
 VolumeLabel : array[1..rng] of TLabel;
 LevelUpDown : array[1..rng] of TUpDown;
 Gauge : array[1..rng] of TGauge;

function Cas : string;
var
   Hour, Min, Sec, MSec: Word;
   _Hour, _Min, _Sec, _MSec: string;

begin
     DecodeTime(Now, Hour, Min, Sec, MSec);
     Str(Hour,_Hour);
     while Length(_Hour)<2 do
      _Hour:='0'+_Hour;
     Str(Min,_Min);
     while Length(_Min)<2 do
      _Min:='0'+_Min;
     Str(Sec,_Sec);
     while Length(_Sec)<2 do
      _Sec:='0'+_Sec;
     Str(MSec,_MSec);
     while Length(_MSec)<=2 do
      _MSec:='0'+_MSec;
     Result:=_Hour+':'+_Min+':'+_Sec+'.'+_MSec+' - ';
end;
procedure LogWrite(s : string);
begin
 try
  Append(LogFile);
  Writeln(LogFile, IntToStr(chyba_zapisu)+ ' - '+Cas+s);
  CloseFile(LogFile);
 except
  Inc(chyba_zapisu);
 end;

end;

function WriteStatus(i : integer) : boolean;
var
 count : longint;
 WF : TIniFile;
 F : TextFile;
begin
     WF:=TIniFile.Create(WorkName);
     WF.WriteString('General', 'Status', IntToStr(i));
     WF.Free;
     count:=0;
     repeat
       Inc(count);
       Result:=CopyFile(PChar(WorkName), PChar(StatusFileName), false);
       Sleep(100);
       if count>=10
        then Break;
     until Result;
     if FileExistsUTF8(WorkName) { *Converted from FileExists* }
      then
       begin
        AssignFile(F, WorkName);
        Erase(F);
       end;
     LogWrite('Write status ['+IntToStr(i)+']              count ('+IntToStr(count)+')');
end;


procedure K_LineTo(X,Y : integer);
begin
   Form1.Image1.Canvas.LineTo(X+15, Form1.Image1.Height-(Y+12));
end;
procedure K_MoveTo(X,Y : integer);
begin
   Form1.Image1.Canvas.MoveTo(X+15, Form1.Image1.Height-(Y+12));
end;

const
     Radius =  70 ;
     Nradius = 10 ;
     zakladna = 5*pi/8 ;
     maxim    = 7/4 * pi;
     rozsah   = 100;
     cX = 100;
     cY = 90;

var
   oldUhel    : real;
   //uh, udaj, delta : real;
{- - - - - - - - - - - - - - - -}
procedure Kresli(u: real);
 var
    x, y : integer;
 begin
     Form1.Image2.Canvas.Font.Size:=8;
     Form1.Image2.Canvas.Font.Style:=[fsBold];
     Form1.Image2.Canvas.TextOut(cX-28, cY+10, 'Consistency');
     Form1.Image2.Canvas.Ellipse(cX-2, cY-2, cX+2, cY+2);
     x:=Round(NRadius * cos(pi+zakladna+u));
     y:=Round(NRadius * sin(pi+zakladna+u));
     Form1.Image2.Canvas.MoveTo(cX+x, cY+y);
     x:=Round(Radius * cos(zakladna+u));
     y:=Round(Radius * sin(zakladna+u));
     Form1.Image2.Canvas.LineTo(cX+x, cY+y);
 end;

{- - - - - - - - - - - - - - - -}
procedure Stupnice(roz : integer);
 var
  i, x, y, d, s, ci, k: longint;
  u , c : real;
  cs : string;
 procedure Carka;
  begin
   x:=cX+Round((Radius+d) * cos(zakladna+u));
   y:=cY+Round((Radius+d) * sin(zakladna+u));
   Form1.Image2.Canvas.LineTo(+x, +y);
  end;
 begin
    s:=roz;
    if s>=200
     then
       while (s>200) and ((s mod 5)=0) do
         s:= s div 5
     else
       while s<=20 do
         s:= s * 10;
    while s<50 do
       s:=s*5;
    Form1.Image2.Canvas.Pen.Mode:=pmWhite;
    Form1.Image2.Canvas.Rectangle(0, 0, Form1.Image2.Width, Form1.Image2.Height); {clr}
    Form1.Image2.Canvas.Pen.Mode:=pmBlack;
    Kresli(oldUhel);

    k:=(1000*roz) div s;
    for i:=0 to s do
      begin
           u:=(i * maxim)/s;
           c:=(roz/s)*i;
           ci:=Round(c*100);
           x:=cX+Round((Radius) * cos(zakladna+u));
           y:=cY+Round((Radius) * sin(zakladna+u));
           Form1.Image2.Canvas.MoveTo(+x, +y);
           if ((ci mod k)=0)
             then
                begin
                   d:=9;
                   Carka;
                   x:=-6+cX+Round((Radius+18) * cos(zakladna+u));
                   y:=-6+cY+Round((Radius+15) * sin(zakladna+u));
                   Form1.Image2.Canvas.Font.Name:='smallfont';
                   case roz of
                     0..10       : begin
                                     Str(c:1:1, cs);
                                     Form1.Image2.Canvas.Font.Size:=8;
                                   end;
                     11..100     : begin
                                     Str(c:2:0, cs);
                                     Form1.Image2.Canvas.Font.Size:=8;
                                   end;
                     101..1000   : begin
                                     Str(c:3:0, cs);
                                     Form1.Image2.Canvas.Font.Size:=7;
                                   end;
                     1001..10000 : begin
                                     Str(c:4:0, cs);
                                     Form1.Image2.Canvas.Font.Size:=7;
                                   end;
                   end;
                   Form1.Image2.Canvas.TextOut(x,y,cs);
                end
             else
                begin
                 d:=3;
                 Carka;
                end;
      end;
 end;

procedure Ruka(udaj : Real);
 var
   uhel : real;
 begin
     if udaj<0
      then
       begin
        if udaj<-10
         then
          begin
           udaj:=-10;
           Form1.LabelKonz.Font.Color:=clPurple;
          end
         else
          Form1.LabelKonz.Font.Color:=clRed;
       end
      else
       begin
        if udaj>110
         then
          begin
           udaj:=110;
           Form1.LabelKonz.Font.Color:=clLime;
          end
         else
          Form1.LabelKonz.Font.Color:=clBlack;
       end;

     Form1.LabelKonz.Caption:=IntToStr(Round(udaj));
     uhel:=udaj*maxim/rozsah;
     Form1.Image2.Canvas.Pen.Mode:=pmNotXor;
     Kresli(oldUhel);         {smaze}
     oldUhel:=uhel;
     Form1.Image2.Canvas.Pen.Mode:=pmBlack;
     Kresli(uhel);            {kresli}
 end;

procedure TForm1.FormCreate(Sender: TObject);
var
 i, cd : integer;
 po : real;
 ps : string;
begin
  Measure_NoGraf:=false;
  K_MoveTo(0, 0);
  Timer1.Tag:=0;
  Measure_NoGraf:=true;
  Stupnice(100);
  LabelKonz.Visible:=true;
  Form1.Image1.Visible:=false;
  Form1.Image2.Visible:=true;
  Form1.Width:=205;
  IniFile:=TIniFile.Create(IniFilename);
   Form1.Left:=IniFile.ReadInteger('Position', 'Left', 100);
   Form1.Top:=IniFile.ReadInteger('Position', 'Top', 100);
  IniFile.Free;
  Form1.TrackBar1.Position:=Form1.TrackBar1.Max-SKonz[1];
  Form1.TrackBar2.Position:=Form1.TrackBar2.Max-SKonz[2];
  Form1.TrackBar3.Position:=Form1.TrackBar3.Max-SKonz[3];
  Form1.TrackBar4.Position:=Form1.TrackBar4.Max-SKonz[4];
  Form1.TrackBar5.Position:=Form1.TrackBar5.Max-SKonz[5];

  Form1.TrackBar6.Position:=TimeControl1;
  Form1.TrackBar7.Position:=TimeControl2;
  {+++}
  for i:=1 to rng do
     begin
       VolumeLabel[i]:=TLabel.Create(VolumeLabel[i]);
       VolumeLabel[i].Left:=525;
       VolumeLabel[i].Parent:=Form1;
       VolumeLabel[i].AutoSize:=False;
       VolumeLabel[i].Top:=(i-1)*VolumeLabel[i].Height+40;
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
     MaxWidthForm1:=Gauge[rng].Left+Gauge[rng].Width+5;
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
    {---}
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
   konzi : integer;
   mich : boolean;
   ox, oy : integer;
begin
   //windows.Beep(5000,15);
   MixTime:=(GetTickCount-StartTime) div 1000;
   begin
    Label1.Caption:=FloatToStr(KoefKonz);
    Label4.Caption:=IntToStr(M1konz);
    PtrPtr:=PConsistencyDegree;
    cd:=MemShReadVar(IdentConsistencyDegree, PtrPtr);
    ////cd:=DB_PrectiPromIndex(Index_W_SKonz, PtrPtr, 0);
    if cd<>0
      then
        begin
          ////ShowMessage('Read Error Index_W_SKonz '+IntToStr(cd));
          LogWrite('# Error MemShReadVar ('+IntToStr(cd)+') '+NameConsistencyDegree);
          Sk:=255;
        end
      else
        Sk:=ConsistencyDegree;
        {Sk:=Byte(PtrPtr^);}
    if (Sk=128) and vypust
      then
       begin
        Consi2:=IntToStr(konzistence)+#$B0+'/'+IntToStr(MixTime)+'s';
        Consistency_T2:=PChar(Consi2);
        PtrPtr:=Consistency_T2;
        cd:=MemShWriteVar(IdentConsistency_T2, PtrPtr);
        Form1.Caption:=Consi1+'    '+Consi2+'    '+Consi3;
        Image1.Canvas.Pen.Color:=clGreen; {green}
        Image1.Canvas.Font.Color:=clGreen;
        Image1.Canvas.Pen.Style:=psDot;
        //Image1.Canvas.TextOut(10+MixTime*4, Image1.Height-10, IntToStr(MixTime));
        K_MoveTo(MixTime*4, -3);
        K_LineTo(MixTime*4, Image1.Height);
        Image1.Canvas.TextOut(20+MixTime*4, Image1.Height-konzistence-30, IntToStr(konzistence)+'/'+IntToStr(MixTime));
        K_MoveTo(Timer1.Tag, konzistence);
        Image1.Canvas.Pen.Style:=psSolid;
        vypust:=false;
       end;
    if (Sk=0) and start
      then
       begin
        start:=false;
       end;
    if (Sk<5) and (Sk>0) and not start
      then
        begin                                 {zmena tridy konzistence}
          ///windows.Beep(10,15);
          StartTime:=GetTickCount;
          start:=true;
          Zapis1:=true;
          Zapis2:=true;
          vypust:=true;
          Timer1.Tag:=0;
          Image1.Canvas.Brush.Color:=clWhite; {vymazani}
          Image1.Canvas.Pen.Color:=clWhite;
          Image1.Canvas.Rectangle(0, 0, Image1.Width, Image1.Height);

          Image1.Canvas.Pen.Color:=clSilver;
          Image1.Canvas.Pen.Width:=1;
          Image1.Canvas.Pen.Style:=psDot;
          Image1.Canvas.Font.Color:=clGray;
          Image1.Canvas.Font.Size:=7;
          Image1.Canvas.Font.Name:='Small Fonts';
          for ox:=0 to Image1.Width div 60 do
            begin
              Image1.Canvas.TextOut(10+ox*60, Image1.Height-10, IntToStr(ox*15));
              K_MoveTo(ox*60, -3);
              K_LineTo(ox*60, Image1.Height);
            end;
          for ox:=0 to Image1.Width div 4 do
            begin
              K_MoveTo(ox*4, 1);
              K_LineTo(ox*4, 2);
            end;

          for oy:=0 to Image1.Height div 50 do
            begin
              if oy=0
               then Image1.Canvas.Pen.Style:=psSolid
               else Image1.Canvas.Pen.Style:=psDot;
              Image1.Canvas.TextOut(1, (oy*50), IntToStr((Image1.Height div 50)*50 - oy*50));
              K_MoveTo(-3, oy*50);
              K_LineTo(Image1.Width, oy*50);
            end;
          {}
          Image1.Canvas.Pen.Color:=clRed;
          Image1.Canvas.Font.Color:=clRed;
          Image1.Canvas.TextOut(10+TrackBar6.Position*4, Image1.Height-10, IntToStr(TrackBar6.Position));
          K_MoveTo(TrackBar6.Position*4, -3);
          K_LineTo(TrackBar6.Position*4, Image1.Height);

          Image1.Canvas.Pen.Color:=clBlue;
          Image1.Canvas.Font.Color:=clBlue;
          Image1.Canvas.TextOut(10+TrackBar7.Position*4, Image1.Height-10, IntToStr(TrackBar7.Position));
          K_MoveTo(TrackBar7.Position*4, -3);
          K_LineTo(TrackBar7.Position*4, Image1.Height);
          {}
          Image1.Canvas.Pen.Color:=clRed;
          Image1.Canvas.Pen.Style:=psDot;
          K_MoveTo(0, SKonz[Sk]);
          K_LineTo(Image1.Width, SKonz[Sk]);

          Image1.Canvas.Font.Color:=clRed;
          Image1.Canvas.TextOut(Image1.Width-20, Image1.Height-SKonz[Sk]-24, 'S'+IntToStr(Sk));

          Image1.Canvas.Pen.Style:=psSolid;
          K_MoveTo(0, 0);

          PtrPtr:=OrderCode;
          cd:=MemShReadVar(IdentOrderCode, PtrPtr);
          PtrPtr:=RecipeCode;
          cd:=MemShReadVar(IdentRecipeCode, PtrPtr);
          PtrPtr:=BatchState;
          cd:=MemShReadVar(IdentBatchState, PtrPtr);
          PtrPtr:=BatchVolume;
          cd:=MemShReadVar(IdentBatchVolume, PtrPtr);
          Consistency_T1:=PChar('');
          PtrPtr:=Consistency_T1;
          cd:=MemShWriteVar(IdentConsistency_T1, PtrPtr);
          Consistency_T2:=PChar('');
          PtrPtr:=Consistency_T2;
          cd:=MemShWriteVar(IdentConsistency_T2, PtrPtr);
          Consistency_T3:=PChar('');
          PtrPtr:=Consistency_T3;
          cd:=MemShWriteVar(IdentConsistency_T3, PtrPtr);
          Consi1:='';
          Consi2:='';
          Consi3:='';
          Form1.Caption:='Consistency';
        end;

    ////mich:=IO_Zapnut_DI(T_M1zapnuta,0, cd);
    PtrPtr:=PMixer1On;
    cd:=MemShReadVar(IdentMixer1On, PtrPtr);
    if cd<>0
      then LogWrite('# Error MemShReadVar ('+IntToStr(cd)+') '+NameMixer1On);
    if Mixer1On=0
     then mich:=false
     else mich:=true;
    //
    //mich:=true;
    //
    if mich and not Form1.Visible
      then Form1.Visible:=true;
    if not mich and Form1.Visible
      then Form1.Visible:=false;

    ////cd:=DB_PrectiPromIndex(Index_W_NulaKonz, PtrPtr, 0);
    {if cd<>0
      then
        begin
          ShowMessage('Read Error Index_W_NulaKonz '+IntToStr(cd));}
          Tara:=0;
        {end
      else Tara:=single(PtrPtr^);}


    ////konzistence:=IO_Precti_AI(M1konz, 0, cd);

    PtrPtr:=PConsistencyDisplay;
    cd:=MemShReadVar(IdentConsistencyDisplay, PtrPtr);
    if cd<>0
      then LogWrite('# Error MemShReadVar ('+IntToStr(cd)+') '+NameConsistencyDisplay);
    konzi:=Round((ConsistencyDisplay-Tara));
    if konzistence<konzi
     then konzistence:=konzistence+1;
    if konzistence>konzi
     then konzistence:=konzistence-1;
    Ruka(konzistence);
    Label3.Caption:=IntToStr(konzistence);

    if Timer1.Tag<=Image1.Width
       then
        begin
          if suda=4
            then
             begin
               Timer1.Tag:=Timer1.Tag+1;
               suda:=0;
               Image1.Canvas.Pen.Color:=clBlack;
               K_LineTo(Timer1.Tag, konzistence);
                if (MixTime=TrackBar6.Position) and Zapis1
                 then
                  begin
                   Image1.Canvas.Font.Color:=clRed;
                   Image1.Canvas.TextOut(20+MixTime*4, Image1.Height-konzistence-30, IntToStr(konzistence)+'/'+IntToStr(MixTime));
                   Consi1:=IntToStr(konzistence)+#$B0+'/'+IntToStr(MixTime)+'s';
                   Consistency_T1:=PChar(Consi1);
                   PtrPtr:=Consistency_T1;
                   cd:=MemShWriteVar(IdentConsistency_T1, PtrPtr);
                   Form1.Caption:=Consi1+'    '+Consi2+'    '+Consi3;

                   Zapis1:=false;
                  end;
                if (MixTime=TrackBar7.Position) and Zapis2
                 then
                  begin
                   Image1.Canvas.Font.Color:=clBlue;
                   Image1.Canvas.TextOut(20+MixTime*4, Image1.Height-konzistence-30, IntToStr(konzistence)+'/'+IntToStr(MixTime));
                   Consi3:=IntToStr(konzistence)+#$B0+'/'+IntToStr(MixTime)+'s';
                   Consistency_T3:=PChar(Consi3);
                   PtrPtr:=Consistency_T3;
                   cd:=MemShWriteVar(IdentConsistency_T3, PtrPtr);
                   Form1.Caption:=Consi1+'    '+Consi2+'    '+Consi3;
                   Zapis2:=false;
                  end;
               K_MoveTo(Timer1.Tag, konzistence);
             end;
          Inc(suda);
        end;

   end;
end;


procedure TForm1.MeasureClick(Sender: TObject);
begin
  Measure_NoGraf:=true;
  Measure.Enabled:=false;
  Graph.Enabled:=true;
  Stupnice(100);
  LabelKonz.Visible:=true;
  Form1.Image1.Visible:=false;
  Form1.Image2.Visible:=true;
  Form1.Width:=205;
end;
{..........................................}
procedure TForm1.GraphClick(Sender: TObject);
begin
  Measure_NoGraf:=false;
  Graph.Enabled:=false;
  Measure.Enabled:=true;
  LabelKonz.Visible:=false;
  Form1.Image2.Visible:=false;
  Form1.Image1.Visible:=true;
  Form1.Width:=395;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
   LogWrite('Destroy');
   Timer1.Enabled:=false;
   Timer2.Enabled:=false;
   Sleep(200);
   if Form1.Left<1024
    then
     begin
      IniFile:=TIniFile.Create(IniFilename);
      IniFile.WriteInteger('Position', 'Left', Form1.Left);
      IniFile.WriteInteger('Position', 'Top', Form1.Top);
      IniFile.Free;
     end;
   //windows.Beep(1000,1000);
   if not WriteStatus(3)
    then
     begin
      LogWrite('# unwritten status');
     end;

end;
var
  Lstring, i : integer;
  data : string;
procedure TForm1.Timer2Timer(Sender: TObject);
begin
     if (GetKeyState(Ord('C'))<0) and (GetKeyState(Ord('O'))<0)
      then
       begin
        Timer2.Interval:=1000;
        if Form1.Left<1023
         then
          begin
           Timer2.Tag:=Form1.Left;
           Form1.Left:=1024;
          end
         else
          Form1.Left:=Timer2.Tag;
       end
      else Timer2.Interval:=100;
end;

procedure TForm1.LevelClick(Sender: TObject);
begin
     if Level.Tag=0
      then
       begin
        Form1.Width:=MaxWidthForm1+10;
        Level.Tag:=1;
        Level.Caption:='Save';
       end
      else
       begin
        Level.Tag:=0;
        Level.Caption:='Level';
        Form1.Width:=395;
        IniFile:=TIniFile.Create(IniFilename);
        IniFile.WriteInteger('S_Consistency','S1', TrackBar1.Max-TrackBar1.Position);
        IniFile.WriteInteger('S_Consistency','S2', TrackBar2.Max-TrackBar2.Position);
        IniFile.WriteInteger('S_Consistency','S3', TrackBar3.Max-TrackBar3.Position);
        IniFile.WriteInteger('S_Consistency','S4', TrackBar4.Max-TrackBar4.Position);
        IniFile.WriteInteger('S_Consistency','S5', TrackBar5.Max-TrackBar5.Position);
        IniFile.WriteInteger('S_Consistency','TimeControl1', TrackBar6.Position);
        IniFile.WriteInteger('S_Consistency','TimeControl2', TrackBar7.Position);
        IniFile.Free;
       end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  ox, oy : integer;
  Sk : integer;
begin
   Sk:=TTrackBar(Sender).Tag;
   SKonz[Sk]:=TTrackBar(Sender).max-1-TTrackBar(Sender).Position;
   ///windows.Beep(10,15);
   start:=true;
   Timer1.Tag:=0;
   Image1.Canvas.Brush.Color:=clWhite; {vymazani}
   Image1.Canvas.Pen.Color:=clWhite;
   Image1.Canvas.Rectangle(0, 0, Image1.Width, Image1.Height);

   Image1.Canvas.Pen.Color:=clSilver;
   Image1.Canvas.Pen.Width:=1;
   Image1.Canvas.Pen.Style:=psDot;
   Image1.Canvas.Font.Color:=clGray;
   Image1.Canvas.Font.Size:=7;
   Image1.Canvas.Font.Name:='Small Fonts';
   for ox:=0 to Image1.Width div 60 do
     begin
       Image1.Canvas.TextOut(10+ox*60, Image1.Height-10, IntToStr(ox*15));
       K_MoveTo(ox*60, -3);
       K_LineTo(ox*60, Image1.Height);
     end;
   for oy:=0 to Image1.Height div 50 do
     begin
       Image1.Canvas.TextOut(1, (oy*50), IntToStr((Image1.Height div 50)*50 - oy*50));
       K_MoveTo(-3, oy*50);
       K_LineTo(Image1.Width, oy*50);
     end;
   if Sk>5
    then
     begin
      if Sk=6
       then
        begin
         Image1.Canvas.Pen.Color:=clRed;
         Image1.Canvas.Font.Color:=clRed;
        end
       else
        begin
         Image1.Canvas.Pen.Color:=clBlue;
         Image1.Canvas.Font.Color:=clBlue;
        end;
      Image1.Canvas.TextOut(20+TTrackBar(Sender).Position*4, Image1.Height-23, IntToStr(TTrackBar(Sender).Position));
      K_MoveTo(TTrackBar(Sender).Position*4, -3);
      K_LineTo(TTrackBar(Sender).Position*4, Image1.Height);
     end
    else
     begin
      Image1.Canvas.Pen.Color:=clRed;
      Image1.Canvas.Pen.Style:=psDot;
      K_MoveTo(0, SKonz[Sk]);
      K_LineTo(Image1.Width, SKonz[Sk]);
      Image1.Canvas.Font.Color:=clRed;
      Image1.Canvas.TextOut(Image1.Width-40, Image1.Height-SKonz[Sk]-24, 'S'+IntToStr(Sk)+'='+IntToStr(SKonz[Sk]));
     end;

   Image1.Canvas.Pen.Style:=psSolid;
   K_MoveTo(0, 0);

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


initialization
     SelfFileName:=ParamStr(0);
     Lstring:=Length(SelfFileName);
     Delete(SelfFileName, Lstring-2, 3);
     data:=ExtractFilePath(ParamStr(0))+'data\';
     if not DirectoryExists(data)
      then ForceDirectories(data);
     LogFileName:=ExpandFileName(data+ ExtractFileName(SelfFileName)+'log');
     WorkName:=ExpandFileName(data+ ExtractFileName(SelfFileName)+'wrk');
     IniFilename:=SelfFileName+'ini';

     AssignFile(LogFile,LogFileName);
     Rewrite(LogFile);
     Writeln(LogFile,'------------------');
     CloseFile(LogFile);
     LogWrite('LogFileName '+LogFileName);
     IniFilename:=ExpandFileName(IniFilename);
     if not FileExists(IniFilename)
      then
       LogWrite('# IniFile not found '+IniFilename)
      else
       LogWrite('IniFile  '+IniFilename);

     IniFile:=TIniFile.Create(IniFilename); {*}
      StatusFileName:=IniFile.ReadString('General','StatusFilePath', '');

      if StatusFileName=''
       then
        begin
         LogWrite('# Not found StatusFilePath in [General]');
         Halt;
        end;
      StatusFileName:=ExpandFileName(StatusFileName);
      LogWrite('StatusFileName '+StatusFileName);

      if not WriteStatus(1)
       then
        begin
         LogWrite('#  unwritten status');
        end;

      SKonz[1]:=IniFile.ReadInteger('S_Consistency','S1', 0);
      SKonz[2]:=IniFile.ReadInteger('S_Consistency','S2', 0);
      SKonz[3]:=IniFile.ReadInteger('S_Consistency','S3', 0);
      SKonz[4]:=IniFile.ReadInteger('S_Consistency','S4', 0);
      SKonz[5]:=IniFile.ReadInteger('S_Consistency','S5', 0);
      TimeControl1:=IniFile.ReadInteger('S_Consistency','TimeControl1', 0);
      TimeControl2:=IniFile.ReadInteger('S_Consistency','TimeControl2', 0);
      CountFile:=IniFile.ReadInteger('S_Consistency','CountFile', 0);
      Inc(CountFile);
      IniFile.WriteInteger('S_Consistency','CountFile', CountFile);

      SettingsFileName:=IniFile.ReadString('General','SettingsPath', '');

      if SettingsFileName=''
       then
        begin
         LogWrite('# Not found SettingsFilePath in [General]');
         Halt;
        end;
      SettingsFileName:=ExpandFileName(SettingsFileName);
      LogWrite('SettingsFileName '+SettingsFileName);
     IniFile.Free;   {*}

     i:=MemShOpen(PChar(ParamStr(0)));
     if i<1
      then
       begin
        LogWrite('# Error MemShOpen '+IntToStr(i));
        Halt;
       end;
     LogWrite('MemShOpen '+IntToStr(i));

     IdentMixer1On:=MemShGetIdentVarName(NameMixer1On);
     LogWrite('Ident '+NameMixer1On+' - '+IntToStr(IdentMixer1On));

     IdentConsistencyDisplay:=MemShGetIdentVarName(NameConsistencyDisplay);
     LogWrite('Ident '+NameConsistencyDisplay+' - '+IntToStr(IdentConsistencyDisplay));

     IdentConsistencyDegree:=MemShGetIdentVarName(NameConsistencyDegree);
     LogWrite('Ident '+NameConsistencyDegree+' - '+IntToStr(IdentConsistencyDegree));

     IdentRecipeCode:=MemShGetIdentVarName(NameRecipeCode);
     LogWrite('Ident '+NameRecipeCode+' - '+IntToStr(IdentRecipeCode));
     GetMem(RecipeCode, 64);

     IdentOrderCode:=MemShGetIdentVarName(NameOrderCode);
     LogWrite('Ident '+NameOrderCode+' - '+IntToStr(IdentOrderCode));
     GetMem(OrderCode, 64);

     IdentBatchState:=MemShGetIdentVarName(NameBatchState);
     LogWrite('Ident '+NameBatchState+' - '+IntToStr(IdentBatchState));
     GetMem(BatchState, 64);

     IdentBatchVolume:=MemShGetIdentVarName(NameBatchVolume);
     LogWrite('Ident '+NameBatchVolume+' - '+IntToStr(IdentBatchVolume));
     GetMem(BatchVolume, 64);


     IdentConsistency_T1:=MemShGetIdentVarName(NameConsistency_T1);
     LogWrite('Ident '+NameConsistency_T1+' - '+IntToStr(IdentConsistency_T1));
     GetMem(Consistency_T1, 64);

     IdentConsistency_T2:=MemShGetIdentVarName(NameConsistency_T2);
     LogWrite('Ident '+NameConsistency_T2+' - '+IntToStr(IdentConsistency_T2));
     GetMem(Consistency_T2, 64);

     IdentConsistency_T3:=MemShGetIdentVarName(NameConsistency_T3);
     LogWrite('Ident '+NameConsistency_T3+' - '+IntToStr(IdentConsistency_T3));
     GetMem(Consistency_T3, 64);


     PMixer1On:=Addr(Mixer1On);
     PConsistencyDisplay:=Addr(ConsistencyDisplay);
     PConsistencyDegree:=Addr(ConsistencyDegree);

     if not WriteStatus(2)
      then
       begin
        LogWrite('#  unwritten status');
       end;
     LogWrite('***');

finalization
 LogWrite('finalization');
 {FreeMem(OrderCode);
 FreeMem(RecipeCode);
 FreeMem(BatchState);
 FreeMem(BatchVolume);
 FreeMem(Consistency_T1);
 FreeMem(Consistency_T2);
 FreeMem(Consistency_T3);
 LogWrite('Freemem');
  }
 LogWrite('MemShClose '+IntToStr(MemShClose));
 if not WriteStatus(4)
  then
   begin
    LogWrite('#  unwritten status');
   end;
end.
