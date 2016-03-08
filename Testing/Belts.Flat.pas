unit Belts.Flat;
{ {
  �������� ������� ��������
}

interface

uses Classes, GearTypesUnit, Graphics, SysUtils, Dialogs,
  GearClassesUnit, Gost;
// System.Classes, GearTypesUnit, Vcl.Graphics, System.SysUtils, Vcl.Dialogs,
// GearClassesUnit, Gost;

type
  TFlatBelt = class(TBelt)
  private
    // 1 ���������, ������������ � ������������
    alfa_min, nyu_max, V_max, f_pr: extended;
    // 1 ����, �������� ���� ������� �������� � ���������
    { 0 - ����� 60�, 1 - �� 60� �� 80�, 2 - ����� 80� }
    FQ: integer;
    // 1 ����, �������� ����� ���� ����-�����
    Fz: integer;
    // 1 ����, �������� ������� ������ ��� ���������
    FInput: TFlatInput;
    // 1 ����, �������� ��������� �������� ������
    FGears: TFlatOutputs;
    // 1 ������� �������� �������� �� ����������������� True - ��������������
    function Check(Gear: TFlatOutput): Boolean;
    // 1 ������� ������� ����� ��������
    function Calculate(VarD1: extended; VarCordType: integer): TFlatOutput;
    // 1 ������� ���������� �������� � ���������
    function Add(Gear: TFlatOutput): integer;
    function GetGears(Index: integer): TFlatOutput;
    procedure SetGears(Index: integer; const Value: TFlatOutput);
    procedure SetQ(const Value: integer);
    procedure SetZ(const Value: integer);
  protected
    procedure SetD1(const Value: extended); override;
    procedure SetA(const Value: extended); override;
    // 1 ��������� �������� ������������ ������� ������
    procedure Checking; override;
  public
    { TODO : ������� ���� CordTypeIndex ��������� }
    // 1 ����, �������� ��� ����-����� �����
    CordTypeIndex: integer;
    // 1 ������� ���������� ���. ������. ������� �������� ����� ��� ������� ����������
    function MinDiameter: extended; override;
    // 1 ������� ������� ��� ����-����� (����� ����� � CordTypeIndex)
    function CordBeltType(CordTypeIndex: integer): String;
    constructor Create(Input: TFlatInput); overload;
    constructor Create; overload;
    // 1 ����� ������� ������ ������� ���������
    function First: TFlatOutput;
    // 1  ����� ������� ��������� ������� ���������
    function Last: TFlatOutput;
    // 1 ����� ������� ���������
    procedure Clear; override;
    // 1  ����� ������� ���������� ��������� � ���������
    function Count: integer; override;
    // 1 �������� ��� ������ ������� ������ ��� ���������
    property Input: TFlatInput read FInput;
    // 1 ������� ��������� ��������� �������
    function Collect: integer;
    // 1 �������� ��� ������ � ����������
    property Gears[Index: integer]: TFlatOutput read GetGears
      write SetGears; default;
    // 1 ���� ������� �������� � ���������
    property Q: integer read FQ write SetQ;
    // 1 ����� ���� ����-�����
    property z: integer read Fz write SetZ;
  end;

implementation

{
  ******************************** TFlatBelt *******************************
}
constructor TFlatBelt.Create(Input: TFlatInput);
begin
  // inherited Create;

  FFullName := '������������� ��������';
  FBeltType := btFlat;

  { � ������ ������� ����� ���������� �������������� ��������� � ����� ������ }
{$IFDEF Debug}
  try
{$ENDIF}
    P1 := Input.P1;
    n1 := Input.n1;
    CordTypeIndex := Input.CordTypeIndex;
    d1 := Input.d1;
    up := Input.up;
    a := Input.a;
    Cp := Input.Cp;
    Tension := Input.Tension;
{$IFDEF Debug}
  except
    on E: Exception do
      ShowMessage('[Input] ������� ������ ' + E.ClassName + ' � ���������� : ' +
        E.Message);
  end;
{$ENDIF}
  // ����������� ���������
  alfa_min := 150; { ���������� ���������� ���� ������� }
  nyu_max := 5; { ����������� ���������� ����� �������� }
  V_max := 20; { ����������� ���������� �������� ����� }
  f_pr := 0.25; { ����������� ����������� ������ }

  SetLength(FGears, 0);

{$IFDEF Debug}
  try
{$ENDIF}
    Collect;
{$IFDEF Debug}
  except
    on E: Exception do
      ShowMessage('[Collect] ������� ������ ' + E.ClassName + ' � ���������� : '
        + E.Message);
  end;
{$ENDIF}
end;

function TFlatBelt.First: TFlatOutput;
begin
  if Count > 0 then
    Result := Gears[0]
  else
    raise EListError.Create
      ('[TFlatBelt.First] ������� ������� ������ �������� � ������ ���������');
end;

function TFlatBelt.GetGears(Index: integer): TFlatOutput;
begin
  if Index < Count then
    Result := FGears[Index]
  else
    raise EListError.Create
      ('[TFlatBelt.GetGears] ������� ���������� � �������� � ������� ������ �������������');
end;

function TFlatBelt.CordBeltType(CordTypeIndex: integer): String;
begin
  inherited;

  if CordTypeIndex <= High(FlatT) then
    Result := FlatT[CordTypeIndex]
  else
    raise EAccessViolation.Create
      ('[TFlatBelt.CordBeltType] ����������� ����� ����� ����-����� (CordTypeIndex)');
end;

function TFlatBelt.Last: TFlatOutput;
begin
  if Count > 0 then
    Result := Gears[High(FGears)]
  else
    raise EListError.Create
      ('[TFlatBelt.Last] ������� ������� ��������� �������� � ������ ���������');
end;

function TFlatBelt.MinDiameter: extended;
begin
  try
    Result := 1100 * exp(ln(P1 / n1) / 3);
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TFlatBelt.MinDiameter] ������� ������� �� ���� ��� ������� ���������� ����������� �������� ����� (D1). ������� �������� �������� ����� (n1) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TFlatBelt.MinDiameter] ������ ��� ������� ���������� ����������� �������� ����� (D1)');
  end;
end;

procedure TFlatBelt.SetA(const Value: extended);
begin
  inherited;

end;

procedure TFlatBelt.SetD1(const Value: extended);
var
  Tip_Flat: integer;
  // ���� ���� ������� ������ ��� ����, �� ���������� ���������� ��� �������
  // ������������ � ����� ��������� � ���� ����������
begin
  if n1 = 0 then
    raise EZeroDivide.Create
      ('[TFlatBelt.SetD1] ������ ������� �� ���� ��� ������ �������� ����� (D1), ������� �������� (n1) �� ������ ���� ����� ����');

  Tip_Flat := 0;

  if CordTypeIndex = 0 then
  begin
    inc(Tip_Flat);
    if Tip_Flat > High(FlatT) then
      raise ERangeError.CreateFmt
        ('[TFlatBelt.SetD1] ��� ������� ���������� ���������� ���������� ������� ����� (D1) ����������� ���������� ��� ����-����� (Tip_Flat=%d)',
        [Tip_Flat]);
  end
  else
    Tip_Flat := CordTypeIndex;

  { ����������� ������ �� TArrayD[Round(Array_plen[Section,2])], 2 ������� �
    ������� Array_plen ��� ����� (� ������� TArrayD) ���������� ����������� �������� ����� }

  { TODO : ��� ������� ���������, ���� ������������ ��������� ������ �������,
    ���� ������������ ��������� ������ ������� ������ ���� ������� ������ ������� }

  if (Value < MinDiameter) and (Value <> 0) then
    raise ERangeError.CreateFmt
      ('[TFlatBelt.SetD1] ������� ����� (D1) �� ����� ���� ����� %g, ���������� ���������� �������� ��� ����-����� %s, ����� %g ��',
      [Value, CordBeltType(Tip_Flat), MinDiameter]);

  inherited;
end;

procedure TFlatBelt.SetGears(Index: integer; const Value: TFlatOutput);
begin
  if Index < Count then
    Gears[Index] := Value
  else
    raise EListError.Create
      ('[TFlatBelt.SetGears] ������� �������� ������ � �������� � ������� ������ �������������');
end;

procedure TFlatBelt.SetQ(const Value: integer);
begin
  if (Value >= 0) and (Value <= 2) then
    FQ := Value
  else
    raise ERangeError.Create
      ('[TFlatBelt.SetQ] ����� ���� ������� �������� (Q) ����� ���� �����  ������ 0, 1 ��� 2');
end;

procedure TFlatBelt.SetZ(const Value: integer);
begin
  if (Value >= 0) and (Value <= 6) then
    Fz := Value
  else
    raise ERangeError.Create
      ('[TFlatBelt.SetZ] ����� ���� ����-����� (Z) ������ ���������� � ��������� �� 0 �� 6');
end;

function TFlatBelt.Add(Gear: TFlatOutput): integer;
begin
  SetLength(FGears, Length(FGears) + 1);
  FGears[High(FGears)] := Gear;
  Result := Length(FGears);
end;

function TFlatBelt.Calculate(VarD1: extended; VarCordType: integer)
  : TFlatOutput;
Var
  b0, Aa, he, hf, b, h, y0, C_alfa, C_v, Sigma_t, f1, t1, nol, deln: extended;
  Ft, p_dop, Ft_dop: extended;
  b_max, p0, C_Q, Sigma_e, Sdelta: extended;
  ib_max, ib_min: integer;
  Output: TFlatOutput;
  id2: integer;
  l_max: extended;
  F2, alfa_c, m, qqq, qw: extended;
  { F1 - ��������� ������� �����;
    F2 - ��������� ������� �����;
    Fb - �������� �� ���� �����;
    F0 - ������ ���������������� ���������;
    Ft - �������� ������ � �������� }
Const
  f = 0.25;
  // C = 0.99; ���������� ����� ����������� ������ 1%
begin
  inherited;

  Output.a := a;
  Output.d1 := VarD1;
  Output.CordTypeIndex := VarCordType;

  { ----------------------- ������ ��������� �������� -------------------------- }

  try
    if up > 1 then
      Output.d2 := Output.d1 * up
    else
      Output.d2 := Output.d1 / up;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TFlatBelt.Calculate] ������ ������� �� ���� ��� ������� �������� �������� ����� (d2), ������������ ��������� (up) �� ����� ���� ����� ����');
    else
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� �������� �������� ����� (d2)');
  end;

  try
    RoundGOST(TArrayD, 1, 38, Output.d2, Output.d2, id2);
  except
    on E: Exception do
      raise Exception.Create
        ('[TFlatBelt.Calculate] �� ������� ��������� ������� �������� ����� (d2) �� ���������� �������� �� ���� �������� ��������');
  end;

  // ���� ��������� ���������� ������ ����, ������������ ��� �� ���������
  if a = 0 then
    Output.a := 1.5 * (Output.d1 + Output.d2);
  // ����� a ������� �� ������������, ������ Output.a

  Output.L := 2 * Output.a + Pi * (Output.d1 + Output.d2) / 2 +
    sqr(Output.d2 - Output.d1) / (4 * Output.a);

  try
    RoundGOST(TArrayLP, 1, Round(Array_plen[Output.CordTypeIndex, 7]), Output.L,
      Output.L, id2);
  except
    on E: Exception do
      raise Exception.Create
        ('[TFlatBelt.Calculate] �� ������� ��������� ����� ����� (L) �� ���������� ����������� �������� �� ������� ���� �������� ������');
  end;

  try
    Output.a := (Output.L - Pi * (Output.d1 + Output.d2) / 2) / 4 +
      sqrt(sqr(Output.L - Pi * (Output.d1 + Output.d2) / 2) - 2 *
      sqr(Output.d1 - Output.d2)) / 4;
  except
    on E: Exception do
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� ���������� ���������� (a). ��������, ����������� ������������ ����� ����� (L)');
  end;

  try
    Output.alfa := 180 - (Output.d2 - Output.d1) * 57 / Output.a;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TFlatBelt.Calculate] ������ ������� �� ���� ��� ������� ���� ������� ����� (alfa), ���������� ��������� ���������� (a) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� ���� ������� ����� (alfa)');
  end;

  { ----------------------- ������ �������������� ���������� �������� ---------- }

  if up > 1 then
  begin
    Output.V := Pi * Output.d1 * n1 / 60000
  end
  else
  begin
    Output.V := Pi * Output.d2 * n1 / 60000;
  end;

  try
    Output.nyu := 1000 * Output.V / Output.L;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TFlatBelt.Calculate] ������ ������� �� ���� ��� ������� ������� ����� (nyu), ����� ����� (L) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� ������� ����� (nyu)');
  end;

  { ----------------------- �������� ������ ���������� �������� ---------------- }

  try
    b_max := Array_plen[VarCordType, 8];
    p0 := Array_plen[VarCordType, 5];
    ib_max := Round(Array_plen[VarCordType, 4]);
    ib_min := Round(Array_plen[VarCordType, 3]);
    Sdelta := Array_plen[VarCordType, 1];
  except
    on E: Exception do
      raise EAccessViolation.Create
        ('[TFlatBelt.Calculate] ������ �������� �� ������ ������ ������, ������� ����� ��� ����-����� (VarCordType)');
  end;

  C_alfa := 1 - 0.003 * (180 - Output.alfa);
  C_v := 1.04 - 0.0004 * Output.V * Output.V;

  if Tension = ttAutomatic then
    case Q of
      0:
        C_Q := 1;
      1:
        C_Q := 0.9;
      2:
        C_Q := 0.8;
    end
  else
    C_Q := 1;

  try
    Ft := 1000 * P1 / Output.V;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TFlatBelt.Calculate] ������ ������� �� ���� ��� ������� ��������� ������ (Ft), �������� ����� (V) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� ��������� ������ (Ft)');
  end;

  { ������ ����� }
  Output.b := Ft / (p0 * C_alfa * C_v * Cp * C_Q);

  If Output.b > b_max then
  begin
    raise ERangeError.CreateFmt
      ('[TFlatBelt.Calculate] ������ ����� (b) �� ����� ���� ����� %g ��, ����������� ���������� �������� (b_max) ����� %g �� ',
      [Output.b, b_max]);
  end
  else
    TruncGost(TArrayBP, ib_min, ib_max, Output.b, Output.b, ib_min);

  Output.Bs := TArrayBP[ib_min + 1];

  { ----------------------- ������ ��� ----------------------------------------- }

  alfa_c := 0.7 * Output.alfa * Pi / 180;
  m := exp(f_pr * alfa_c);

  // ���� ��� �������� �� m, ������ ��� ��� �������������� ������ �������
  f1 := m / (m - 1) * Ft;
  F2 := f1 - Ft;
  Output.F0 := Ft / 2 * ((m + 1) / (m - 1));

  try
    Output.Fb := sqrt(sqr(f1) + sqr(F2) - 2 * f1 * F2 *
      cos((180 - Output.alfa) * Pi / 180));
  except
    on E: EInvalidOp do
      raise EInvalidOp.Create
        ('[TFlatBelt.Calculate] ���� ������ �� �������������� �������� ��� ������� �������� �� ���� ����� (Fb)');
    else
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� �������� �� ���� ����� (Fb)');
  end;

  Output.Vol := (Output.Bs * (Pi * (sqr(Output.d1) + sqr(Output.d2)) + 4 *
    Output.a * (Output.d1 + Output.d2))) / 8 * 1E-6;

  try
    qw := exp(f * alfa_c);

    if (Sdelta * Output.b * (qw - 1) = 0) or (Output.d1 = 0) then
      Sigma_e := -1
    else
      Sigma_e := 0.1 * qw * Ft / (Sdelta * Output.b * (qw - 1)) + 90 * Sdelta /
        Output.d1 + 1.2E-3 * sqr(Output.V);

    if Sigma_e <= 0 then
      Output.Lh := -1
    else
      Output.Lh := 1.1E5 * Output.L / (Output.V * exp(4 * ln(Sigma_e)));
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TFlatBelt.Calculate] ������ ������� �� ���� ��� ������� ������������� (Lh)');
    on E: EInvalidOp do
      raise EInvalidOp.Create
        ('[TFlatBelt.Calculate] ��� ���������� ��������� ������������� ��� ������� �������� ��� ������� ������������� (Lh)');
    else
      raise Exception.Create
        ('[TFlatBelt.Calculate] ������ ��� ������� ������������� (Lh)');
  end;

  Result := Output;
end;

function TFlatBelt.Check(Gear: TFlatOutput): Boolean;
begin
  Result := True;

  if Gear.V > V_max then
    Result := False;

  if Gear.alfa < alfa_min then
    Result := False;

  if Gear.nyu > nyu_max then
    Result := False;
end;

procedure TFlatBelt.Checking;
begin
  inherited;
end;

procedure TFlatBelt.Clear;
begin
  if Count <> 0 then
    SetLength(FGears, 0);
end;

function TFlatBelt.Collect: integer;
var
  CurrGear: TFlatOutput;
  d1x: extended;
  CordIndex, id: integer;
begin
  Clear;
  Result := 0;

  if (CordTypeIndex <> 0) and (d1 <> 0) then
  begin
    CurrGear := Calculate(d1, CordTypeIndex);
    if Check(CurrGear) then
      Result := Add(CurrGear);
  end;

  if (CordTypeIndex = 0) and (d1 <> 0) then
  begin
    for CordIndex := Low(FlatT) + 1 to High(FlatT) do
    begin
      CurrGear := Calculate(d1, CordIndex);
      if Check(CurrGear) then
        Result := Add(CurrGear);
    end;
  end;

  if (CordTypeIndex <> 0) and (d1 = 0) then
  begin
    { TODO : ��������� ��� �������� ������� }
    d1x := TArrayD[Round(Array_plen[CordTypeIndex, 2])];
    repeat
      CurrGear := Calculate(d1x, CordTypeIndex);
      d1x := 1.25 * d1x;
      RoundGOST(TArrayD, 1, 38, d1x, d1x, id);
      if Check(CurrGear) then
      begin
        Result := Add(CurrGear);
      end;
    until CurrGear.L >= TArrayLP[Round(Array_plen[CordIndex, 7])];
  end;

  if (CordTypeIndex = 0) and (d1 = 0) then
  begin
    for CordIndex := Low(FlatT) + 1 to High(FlatT) do
    begin
      { TODO : ��������� ��� �������� ������� }
      d1x := TArrayD[Round(Array_plen[CordTypeIndex, 2])];
      repeat
        CurrGear := Calculate(d1x, CordIndex);
        d1x := 1.25 * d1x;
        RoundGOST(TArrayD, 1, 38, d1x, d1x, id);
        if Check(CurrGear) then
        begin
          Result := Add(CurrGear);
        end;
      until CurrGear.L >= TArrayLP[Round(Array_plen[CordIndex, 7])];
    end;
  end;

end;

function TFlatBelt.Count: integer;
begin
  Result := Length(FGears);
end;

constructor TFlatBelt.Create;
var
  NB: TFlatInput;
begin
  NB.P1 := 3;
  NB.n1 := 1000;
  NB.up := 2;
  NB.d1 := 0;
  NB.a := 0;
  NB.Q := 1;
  NB.Cp := 1;
  NB.Tension := ttAutomatic;
  NB.CordTypeIndex := 0;

  Create(NB);
end;

end.