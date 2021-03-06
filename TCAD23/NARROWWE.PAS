{$O+}
Unit NarrowWedgeStrapTransmission;
{-------------------------------------------------------------------------}
{-   ������ �������������� �������� ����� �������� ������.               -}
{-------------------------------------------------------------------------}
INTERFACE
Uses
  Objects, Views, Designers;

Const
{-------------------------------------------------------------------------}
{-   ������ �������������� ��������                                      -}
{-------------------------------------------------------------------------}
  erWidth   = 1;  {- ������ ��������             -}
  erAngle   = 2;  {- ��� ���� �������            -}
  erSpeed   = 3;  {- ������ �������� �����       -}
  erRunway  = 4;  {- ������ ����� �������� ����� -}
  erLength  = 5;  {- ������ ����� �����          -}
  erStraps  = 6;  {- ������ ����� ������         -}

Type
  PNarrowWedgeStrapTransCAD = ^TNarrowWedgeStrapTransCAD;
{--------��� - �������� �������� ������ ------------------ }
  TNarrowWedgeStrapTransCAD = object(TDesigner)
{-  ����� ������ ��������                                                -}
    P1: real;    { �������� �� ������� ����� }
    n1: real;    { ����� �������� �������� ����� }
    up: real;    { ��������� ������������ ����� }
    d1: real;    { ������� ������ ����� }
    Q: word;     { ���� ������� �������� � ��������� }
    Tip_nat: boolean; { ��������� ����� }
    Cp: real;    { ����������� ������ ������ }
    Tip_kl: word;{ ���������� ����� }
    alfa_min: real; { ���������� ���������� ���� ������� }
    nyu_max: real;  { ����������� ���������� ����� �������� }
    V_max: real;    { ����������� ���������� �������� ����� }
    f_pr: real;     { ����������� ����������� ������ }

    a: real;     { ����������� ��������� ���������� �������� }
    d2: real;    { ������� �������� ����� }
    alfa: real;  { ���� ������ ������ �������� ����� }
    Vol: real;   { ����� �������� }
    Lh: real;    { ������������� }
    Fb: real;    { �������� �� ��� �� ��������� ������ ����� }
    z: real;     { ����� ������ }

    l: real;     { ����� ����� }
    bs: real;    { ������ ����� }
    u: real;     { ����������� ������������ ����� }
    n2: real;    { ����� �������� �������� ����� }
    V: real;     { �������� �������� ����� }
    nyu: real;   { ����� �������� ����� � ������� }
    Ft: real;    { �������� ������ � �������� }
    F0: real;    { ���� ���������������� ��������� ����� }
{-------------------------------------------------------------------------}
    d_e1,         { �������� �������� ������   }
    d_e2: real;
    d_f1,         { �������� ������   }
    d_f2: real;   { �� ��� �������    }
    f: real;      { ���������� �� ����� ����� �� ������� ����� }
    t: real;      { ��� ������ �� ����� }

    procedure InitData; virtual;
    procedure InitQuality; virtual;
    procedure MakeDataStrings (AStrings: PCollection); virtual;
    procedure ChangeDataItem (Item: byte); virtual;
    procedure MakeVersions; virtual;
    procedure MakeVersion (var ErrorCode: byte); virtual;
    procedure MakeVersionStrings (AStrings: PCollection); virtual;
    function  DataEntryPoint: pointer; virtual;
    function  QualityNumber: word; virtual;
    function  QualityEntryPoint: pointer; virtual;
    procedure PlotVersion (VersionID: PView; var Dest: text); virtual;
  end;

Const
  RNarrowWedgeStrapTransCAD: TStreamRec = (
    ObjType: 1114;
    VmtLink: Ofs(TypeOf(TNarrowWedgeStrapTransCAD)^);
    Load: @TNarrowWedgeStrapTransCAD.Load;
    Store: @TNarrowWedgeStrapTransCAD.Store
  );

IMPLEMENTATION
Uses
  Drivers, App, Dialogs, Common, obRead, GOST;

PROCEDURE TNarrowWedgeStrapTransCAD.InitData;
BEGIN
  N1:=720;
  P1:=2;
  up:=3;
  d1:=0;
  a:=0;
  Q:=0;
  Tip_nat:=True;
  Cp:=1;
  Tip_kl:=0;
  alfa_min:=120;
  nyu_max:=15;
  V_max:=30;
  f_pr:=0.73;
END;

PROCEDURE TNarrowWedgeStrapTransCAD.InitQuality;
BEGIN
  inherited InitQuality;
  QualityList^[0].Title:=NewStr('��������� ����������, ��');
  QualityList^[0].Value:=2;
  QualityList^[0].Minimize:=True;
  QualityList^[1].Title:=NewStr('������� �������� �����,��');
  QualityList^[1].Value:=0;
  QualityList^[1].Minimize:=True;
  QualityList^[2].Title:=NewStr('���� �������, ����.');
  QualityList^[2].Value:=2;
  QualityList^[2].Minimize:=False;
  QualityList^[3].Title:=NewStr('����� ��������, �� ���.');
  QualityList^[3].Value:=2;
  QualityList^[3].Minimize:=True;
  QualityList^[4].Title:=NewStr('������������� �����, ���');
  QualityList^[4].Value:=2;
  QualityList^[4].Minimize:=False;
  QualityList^[5].Title:=NewStr('�������� �� ���, �');
  QualityList^[5].Value:=2;
  QualityList^[5].Minimize:=True;
  QualityList^[6].Title:=NewStr('����� ������');
  QualityList^[6].Value:=0;
  QualityList^[6].Minimize:=True;
END;

PROCEDURE TNarrowWedgeStrapTransCAD.MakeVersionStrings;
Var
  FmtStr: string;
  ValStr: array [0..17] of string[7];
  Params: array [0..19,0..1] of Pointer;
  ItemCount: byte;

Const
  BaseStr = '%-40s %15s';
  Angle: array [0..2] of string[14] = (
  '����� 60�',
  '�� 60� �� 80�',
  '����� 80�');
  Travel: array[boolean] of string[15] = (
  '��������������',
  '�������������');
  StrapType: array[1..4] of string[2] = (
  '��',
  '��',
  '��',
  '��');
  ParamsName: array [0..19] of string [40] = (
  '��������� ������� ������� �����, ��',
  '��������� ������� ������� �����, ��',
  '�������� ������� ������� �����, ��',
  '�������� ������� ������� �����, ��',
  '������� �� ��� ������ ������� �����, ��',
  '������� �� ��� ������ ������� �����, ��',
  '��������� ����������, ��',
  '����� �����, ��',
  '������ �����, ��',
  '����� ������',
  '������ ���������������� ���������, �',
  '�������� �� ���� �� ��������� �����, �',
  '������������� �����, ���',

  '�������� �� ������� ����, ���',
  '������� �������� �����. �����, ��/���',
  '������������ �����',
  '���� ������� ��������',
  '����������� ������ ������',
  '��������� �����',
  '���������� �����');

BEGIN
  Str(d1:0:1,ValStr[0]);
  Str(d2:0:1,ValStr[1]);
  Str(d_e1:0:1,ValStr[2]);
  Str(d_e2:0:1,ValStr[3]);
  Str(d_f1:0:1,ValStr[4]);
  Str(d_f2:0:1,ValStr[5]);
  Str(a:0:2,ValStr[6]);
  Str(l:0:1,ValStr[7]);
  Str(bs:0:2,ValStr[8]);
  Str(z:0:0,ValStr[9]);
  Str(F0:0:1,ValStr[10]);
  Str(Fb:0:1,ValStr[11]);
  Str(Lh:0:1,ValStr[12]);

  Str(P1:0:2,ValStr[13]);
  Str(N1:0:2,ValStr[14]);
  Str(u:0:2,ValStr[15]);
  Str(Cp:0:2,ValStr[17]);

  for ItemCount:=0 to 17 do
    Params[ItemCount,1]:=@ValStr[ItemCount];
  Params[16,1]:=@Angle[Q];
  Params[18,1]:=@Travel[Tip_nat];
  Params[19,1]:=@StrapType[Tip_kl];
  for ItemCount:=0 to 19 do
  begin
    Params[ItemCount,0]:=@ParamsName[ItemCount];
    FormatStr(FmtStr, BaseStr, Params[ItemCount]);
    AStrings^.Insert(NewStr(FmtStr));
  end;
  AStrings^.AtInsert(13, NewStr('    �������� ������'));
END;

PROCEDURE TNarrowWedgeStrapTransCAD.MakeDataStrings;
Var
  FmtStr: string;
  ValStr: array [0..5] of string[7];
  Params: array [0..9,0..1] of Pointer;
  ItemCount: byte;

Const
  BaseStr = '%-40s %15s';
  Angle: array [0..2] of string[14] = (
  '����� 60�',
  '�� 60� �� 80�',
  '����� 80�');
  Travel: array[boolean] of string[15] = (
  '��������������',
  '�������������');
  StrapType: array[1..4] of string[2] = (
  '��',
  '��',
  '��',
  '��');
  AUTOMessage: string[4] = 'AUTO';
  ParamsName: array [0..8] of string [40] = (
  '�������� �� ������� ����, ���',
  '������� �������� �����. �����, ��/���',
  '��������� ������������ �����',
  '������� �������� �����, ��',
  '��������� ����������, ��',
  '���� ������� ��������',
  '����������� ������ ������',
  '��������� �����',
  '���������� �����');

BEGIN
  Str(P1:0:2,ValStr[0]);
  Str(N1:0:2,ValStr[1]);
  Str(up:0:2,ValStr[2]);
  if d1 = 0 then
    ValStr[3]:=AUTOMessage
  else
    Str(d1:0:2,ValStr[3]);
  if a = 0 then
    ValStr[4]:=AUTOMessage
  else
    Str(a:0:2,ValStr[4]);
  Str(Cp:0:2,ValStr[5]);
  Params[0,1]:=@ValStr[0];
  Params[1,1]:=@ValStr[1];
  Params[2,1]:=@ValStr[2];
  Params[3,1]:=@ValStr[3];
  Params[4,1]:=@ValStr[4];
  Params[5,1]:=@Angle[Q];
  Params[6,1]:=@ValStr[5];
  Params[7,1]:=@Travel[Tip_nat];
  if Tip_kl = 0 then
    Params[8,1]:=@AUTOMessage
  else
    Params[8,1]:=@StrapType[Tip_kl];
  for ItemCount:=0 to 8 do
  begin
    Params[ItemCount,0]:=@ParamsName[ItemCount];
    FormatStr(FmtStr, BaseStr, Params[ItemCount]);
    AStrings^.Insert(NewStr(FmtStr));
  end;
END;

PROCEDURE TNarrowWedgeStrapTransCAD.ChangeDataItem;
Var
  Dialog: PDialog;
  Bruce:  PView;
  R:      TRect;
  VS:     string[8];
  TC:     integer;

PROCEDURE GetPower;
BEGIN
  R.Assign(1, 1, 60, 8);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(Size.X-13, 2, Size.X-3, 3);
    Bruce:=New(PInputReal, Init(R,6,0.1,200,2,SizeOf(float)));
    Insert(Bruce);
    R.Assign(1, 2, Size.X-13, 3);
    Insert(New(PLabel, Init(R, '�������� �� ������� ����, ���', Bruce)));
    R.Assign(Size.X-18, Size.Y-3, Size.X-3, Size.Y-1);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);
    R.Move(-18, 0);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @P1);
END;

PROCEDURE GetFreqency;
BEGIN
  R.Assign(1, 1, 60, 8);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(47, 2, 57, 3);
    Bruce:=New(PInputReal, Init(R,8,10,10000,2,SizeOf(float)));
    Insert(Bruce);
    R.Assign(2, 2, 47, 3);
    Insert(New(PLabel, Init(R, '������� �������� �������� �����, ��/���',
                                                                Bruce)));
    R.Assign(Size.X-18, Size.Y-3, Size.X-3, Size.Y-1);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);
    R.Move(-18, 0);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @N1);
END;

PROCEDURE GetReduction;
BEGIN
  R.Assign(1, 1, 60, 8);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(47, 2, 57, 3);
    Bruce:=New(PInputReal, Init(R,5,0.1,10,2,SizeOf(float)));
    Insert(Bruce);
    R.Assign(2, 2, 47, 3);
    Insert(New(PLabel, Init(R, '��������� ������������ �����', Bruce)));
    R.Assign(Size.X-18, Size.Y-3, Size.X-3, Size.Y-1);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);
    R.Move(-18, 0);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @Up);
END;

PROCEDURE GetFirstDiameter;
Const
  T1S : array[1..4] of real = (120, 300, 1500, 1000000);

Type
  TBoxData = record
    List: PCollection;
    Item: integer;
  end;

Var
  Diameters: PTextCollection;
  ScrollBar: PScrollBar;
  Minimum: float;
  BoxData: TBoxData;
  NumberDiameter: byte;

BEGIN
  if Tip_kl = 0 then
  begin
    inc(Tip_kl);
    while 9550*P1/N1 > T1S[Tip_kl] do
      inc(Tip_kl);
    Minimum:=TArrayD[Round(Array_kl[Tip_kl,10])];
    Tip_kl:=0;
  end
  else
    Minimum:=TArrayD[Round(Array_kl[Tip_kl,10])];

  New(Diameters, Init(10, 3));
  Diameters^.Insert(NewStr('AUTO'));
  for NumberDiameter:=1 to 34 do
    if TArrayD[NumberDiameter] >= Minimum then
    begin
       Str(TArrayD[NumberDiameter]:4:0, VS);
       Diameters^.Insert(NewStr(VS));
    end;
  with BoxData do
  begin
    List:=Diameters;
    Item:=0;
  end;

  R.Assign(1, 1, 40, 14);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(36, 3, 37, 9);
    New(ScrollBar, Init(R));
    Insert(ScrollBar);
    R.Assign(2, 3, 36, 9);
    Bruce:=New(PListBox, Init(R, 5, ScrollBar));
    Insert(Bruce);
    R.Assign(2, 2, 36, 3);
    Insert(New(PLabel, Init(R, '������� �������� �����:', Bruce)));

    R.Assign(3, 10, 17, 12);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);
    R.Move(17, 0);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @BoxData);
  Val(PString(Diameters^.At(BoxData.Item))^, d1, TC);
  Dispose(Diameters, Done);
END;

PROCEDURE GetWheelDistance;
Var
  Minimum: float;

BEGIN
  if d1=0 then
    Minimum:= 0.6* 1100 * exp(1/3 * ln(P1/N1))*(up+1)
  else
    Minimum:= 0.6*d1*(up+1);
  Str(Minimum:7:2, VS);

  R.Assign(1, 1, 60, 8);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(47, 2, 57, 3);
    Bruce:=New(PInputAUTOReal, Init(R,7,Minimum,3000,2,SizeOf(float)));
    Insert(Bruce);
    R.Assign(2, 2, 47, 3);
    Insert(New(PLabel, Init(R, '��������� ���������� (�� ����� '+
           VS+')', Bruce)));
    R.Assign(Size.X-18, Size.Y-3, Size.X-3, Size.Y-1);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);
    R.Move(-18, 0);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @a);
END;

PROCEDURE GetAngle;
BEGIN
  R.Assign(1, 1, 60, 9);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(2, 3, 57, 4);
    Bruce:=New(PRadioButtons, Init(R,
      NewSItem('����� 60�',
      NewSItem('�� 60� �� 80�',
      NewSItem('����� 80�',
      nil)))
    ));
    Insert(Bruce);
    R.Assign(2, 2, 57, 3);
    Insert(New(PLabel, Init(R, '���� ������� ��������', Bruce)));
    R.Assign(Size.X-18, Size.Y-3, Size.X-3, Size.Y-1);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);
    R.Move(-18, 0);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @Q);
END;

PROCEDURE GetWorkMode;
Const
  WorkMode: word = 0;

BEGIN
  R.Assign(1, 1, 60, 10);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(2, 3, 40, 7);
    Bruce:=New(PRadioButtons, Init(R,
      NewSItem('���������, ��/�� 1.2',
      NewSItem('��������� ���������, ��/�� 1.5',
      NewSItem('������������ ���������, ��/�� 2',
      NewSItem('�������, ��/�� 3',
      nil))))
    ));
    Insert(Bruce);
    R.Assign(2, 2, 40, 3);
    Insert(New(PLabel, Init(R, '�������� �������� ��������', Bruce)));
    R.Assign(Size.X-18, 2, Size.X-3, 4);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);
    R.Move(0, 2);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  if Application^.ExecuteDialog(Dialog, @WorkMode) = cmOk then
    case WorkMode of
      0: Cp:=1;
      1: Cp:=1.15;
      2: Cp:=1.25;
      3: Cp:=1.55;
    end;
END;

PROCEDURE GetStrapType;
BEGIN
  R.Assign(1, 1, 60, 10);
  New(Dialog, Init(R, '�������� ������'));
  with Dialog^ do
  begin
    R.Assign(2, 3, 41, 6);
    Bruce:=New(PRadioButtons, Init(R,
      NewSItem('AUTO',
      NewSItem('��',
      NewSItem('��',
      NewSItem('��',
      NewSItem('��',
      nil)))))
    ));
    Insert(Bruce);
    R.Assign(1, 2, 41, 3);
    Insert(New(PLabel, Init(R, '���������� �����', Bruce)));
    R.Assign(Size.X-18, 2, Size.X-3, 4);
    Bruce:=New(PButton, Init(R, '��', cmOk, bfDefault));
    Bruce^.HelpCtx:=hcOk;
    Insert(Bruce);
    R.Move(0, 2);
    Bruce:=New(PButton, Init(R, '�����', cmCancel, bfNormal));
    Bruce^.HelpCtx:=hcCancel;
    Insert(Bruce);

    Options:=Options or ofCentered;
    SelectNext(False);
  end;
  Application^.ExecuteDialog(Dialog, @Tip_kl);
END;

BEGIN
  case Item of
    0: GetPower;
    1: GetFreqency;
    2: GetReduction;
    3: GetFirstDiameter;
    4: GetWheelDistance;
    5: GetAngle;
    6: GetWorkMode;
    7: Tip_nat:=not Tip_nat;
    8: GetStrapType;
  end;
END;

PROCEDURE TNarrowWedgeStrapTransCAD.MakeVersions;
Var
  id, TransChk: byte;
  StartDiam, StartStrap, UserDist: real;

BEGIN
  StartDiam:=d1;
  StartStrap:=Tip_kl;
  UserDist:=a;
  if StartStrap = 0 then
    Tip_kl:=1;
  repeat
    d1:=StartDiam;
    repeat
      TransChk:=0;
      a:=UserDist;
      MakeVersion(TransChk);
      if TransChk = 0 then
        AddVersion;
      d1:=d1*1.25;
      RoundGOST(TArrayD, 1, 38, d1, d1, id);
    until (TransChk <> 0) or (StartDiam<>0);
    Inc(Tip_kl);
  until (StartStrap <> 0) or (Tip_kl > 4);
  inherited MakeVersions;
END;

PROCEDURE TNarrowWedgeStrapTransCAD.MakeVersion;

PROCEDURE Wheel;
Var
  b0, Aa, he, hf, b, h, y0,C_alfa, C_v, Sigma_t : real;

BEGIN
                    { ���������� }
 b0 := Array_ukl[Tip_kl,1];        Aa := Array_ukl[Tip_kl,5];
 hf := Array_ukl[Tip_kl,14];       he := Array_ukl[Tip_kl,13];
  f := Array_ukl[Tip_kl,11];        t := Array_ukl[Tip_kl,12];
  b := Array_ukl[Tip_kl,2];         h := Array_ukl[Tip_kl,3];
 y0 := Array_ukl[Tip_kl,4];


 d_e1 := d1 + 2 * he;      d_e2 := d2 + 2 * he;
 d_f1 := d1 - 2 * hf;      d_f2 := d2 - 2 * hf;
 C_alfa := 1.24 * (1 - exp(-alfa / 110));
 C_v := 1 - 0.05 * (0.01 * sqr(V) - 1);
 Ft := 1000 * P1/V;
 Sigma_t := (27.1-2.215*ln(nyu))*exp(-0.421*ln(Array_ukl[Tip_kl, 1]))
             -49*Array_ukl[Tip_kl, 1]/d_e1-1.12E-03*V*V;
 z := Round(Ft * Cp / (Sigma_t * A * 0.9 * C_alfa * C_v) + 0.5);
 if z < 1 then
   ErrorCode:=erWidth;
 Bs := 2 * f + t * (z-1);
 if z > 11 then
   ErrorCode:=erStraps;
END; { ����� ��������� Shkiv_kl }

PROCEDURE Diameter;
Const
  T1S : array[1..4] of real = (120, 300, 1500, 1000000);

BEGIN
{----------------- ������ �������� �������� ����� -------------------}
  if d1 <> 0 then
    Exit;
  if Tip_kl = 0 then
  begin
    inc(Tip_kl);
    while 9550*P1/N1 > T1S[Tip_kl] do
      inc(Tip_kl);
    d1:=TArrayD[Round(Array_ukl[Tip_kl,10])];
    Tip_kl:=0;
  end
  else
    d1:=TArrayD[Round(Array_ukl[Tip_kl,10])];
END; {--------- ����� ������� d1 --------------------------------------}

PROCEDURE Geometric;
Var
  id2: byte;
  l_max: real;

BEGIN
{----------------------- ������ ��������� �������� ------------------------}
  l_max :=  TArrayL[Round(Array_ukl[Tip_kl, 9])];
  d2:=d1 * up;
  RoundGOST(TArrayD, 1, 38, d2, d2, id2) ;
  if a = 0 then
    a:=1.5 * (d1 + d2);
  l:=2 * a + Pi * (d1 + d2) / 2 + sqr(d2 - d1) / (4 * a);
  if l > l_max then
  begin
    ErrorCode:=erLength;
    Exit;
  end;
  RoundGost(TArrayL,1,Round(Array_ukl[Tip_kl, 9]),l,l,id2);
    a := (l- pi * (d1 + d2) / 2) / 4 + sqrt(sqr(l - pi * (d1 + d2) / 2) -
          2 * sqr(d1 - d2)) / 4;
  alfa:=180 - (d2 - d1) * 57 / a;
  if alfa < alfa_min then
    ErrorCode:=erAngle;
END;{------------------------------------------------------}

PROCEDURE Kinematic;
{--------- ������ �������������� ���������� �������� -------}
Var
  C: real;

BEGIN
  C:=0.99;
  u:=d2/(C * d1);
  n2:=n1 * d1 * C / d2;
  V:=Pi * d1 * n1 / 60000;
  if V > 35 then
    ErrorCode:=erSpeed;
  nyu:=1000 * V/l;
  if nyu > nyu_max then
    ErrorCode:=erRunway;
END; {-------- ����� ��������� Kinematic-----------------------}

PROCEDURE Forces;
{------------------ ������ ��� ------------------------}

Var  F1, F2, alfa_c, m, Sigma_E, q, b0, Aa, qqq : real;
{     F1 - ��������� ������� �����;
     F2 - ��������� ������� �����;
     Fb - �������� �� ���� �����;
     F0 - ������ ���������������� ���������;
     Ft - �������� ������ � �������� }
Const
  f = 0.25;

BEGIN
  b0 := Array_ukl[Tip_kl,1];        Aa := Array_ukl[Tip_kl,5];
  alfa_c:=0.7 * alfa * pi / 180;
  m := exp(f_pr * alfa_c);
  F1 := m / (m-1) * Ft;
  F2 := F1 - Ft;
  F0 := Ft / 2 * ((m + 1) / (m - 1));
  Fb := sqrt(sqr(F1) + sqr(F2) - 2 * F1 * F2 * cos((180-alfa)*Pi/180));
  Vol:=(bs*(Pi*(sqr(d1)+sqr(d2))+4*a*(d1+d2)))/8*1E-6;
  alfa_c := 0.7 * alfa * pi / 180;
  q := exp(f * alfa_c);
  qqq := 0.35*q*Ft/((q-1)*Aa) + 7.5*exp(1.57*ln(b0))/d_e1 + 1.27E-3*V*V;
  Lh := 283*l/(V*qqq)+250;
  if Lh > 6000 then Lh := exp(0.8*ln(Lh));
  END; {------------- ����� ��������� Forces-------------------------}

BEGIN
  Diameter;
  if ErrorCode<>0 then Exit;
  Geometric;
  if ErrorCode<>0 then Exit;
  Kinematic;
  if ErrorCode<>0 then Exit;
  Wheel;
  if ErrorCode<>0 then Exit;
  Forces;
END;

FUNCTION TNarrowWedgeStrapTransCAD.DataEntryPoint;
BEGIN
  DataEntryPoint:=@P1;
END;

FUNCTION TNarrowWedgeStrapTransCAD.QualityNumber;
BEGIN
  QualityNumber:=7;
END;

FUNCTION TNarrowWedgeStrapTransCAD.QualityEntryPoint;
BEGIN
  QualityEntryPoint:=@a;
END;

PROCEDURE TNarrowWedgeStrapTransCAD.PlotVersion;
BEGIN
  inherited PlotVersion(VersionID,Dest);
  writeln(Dest,'2');
  writeln(Dest,D_e1:0:2);
  writeln(Dest,d1:0:2);
  writeln(Dest,d_f1:0:2);
  writeln(Dest,D_e2:0:2);
  writeln(Dest,d2:0:2);
  writeln(Dest,d_f2:0:2);
  writeln(Dest,Tip_kl+10);
  writeln(Dest,z:0:0);
  writeln(Dest,bs:0:2);
  writeln(Dest,9550*P1/N1:0:2);
  writeln(Dest,9550*P1/N1*Up:0:2);
END;
END.