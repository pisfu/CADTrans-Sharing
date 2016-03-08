unit Belts.MultiGroove;
{ {
  ������������ ������� ��������
}

interface

uses System.Classes, GearTypesUnit, Vcl.Graphics, System.SysUtils, Vcl.Dialogs,
  GearClassesUnit, Gost;

type
  TMultiGrooveBelt = class(TBelt)
  private
    // 1 ���������, ������������ � ������������
    alfa_min, nyu_max, V_max, f_pr: extended;
    // 1 ����, �������� ������� ������ ��� ���������
    FInput: TMultiGrooveInput;
    // 1 ����, �������� ��������� �������� ������
    FGears: TMultiGrooveOutputs;
    // 1 ������� �������� �������� �� ����������������� True - ��������������
    function Check(Gear: TMultiGrooveOutput): Boolean;
    // 1 ������� ������� ����� ��������
    function Calculate(VarD1: extended; VarSection: integer)
      : TMultiGrooveOutput;
    // 1 ������� ���������� �������� � ���������
    function Add(Gear: TMultiGrooveOutput): integer;
    function GetGears(Index: integer): TMultiGrooveOutput;
    procedure SetGears(Index: integer; const Value: TMultiGrooveOutput);
  protected
    procedure SetD1(const Value: extended); override;
    procedure SetA(const Value: extended); override;
    // 1 ��������� �������� ������������ ������� ������
    procedure Checking; override;
  public
    // 1 ������� ���������� ���. ������. ������� �������� ����� ��� ������� ����������
    function MinDiameter: extended; override;
    // 1 ������� ������� ��� ����� (����� ����� � SectionIndex)
    function Section(SectionIndex: integer): String; override;
    constructor Create(Input: TMultiGrooveInput); overload;
    constructor Create; overload;
    // 1 ����� ������� ������ ������� ���������
    function First: TMultiGrooveOutput;
    // 1  ����� ������� ��������� ������� ���������
    function Last: TMultiGrooveOutput;
    // 1 ����� ������� ���������
    procedure Clear; override;
    // 1  ����� ������� ���������� ��������� � ���������
    function Count: integer; override;
    // 1 �������� ��� ������ ������� ������ ��� ���������
    property Input: TMultiGrooveInput read FInput;
    // 1 ������� ��������� ��������� �������
    function Collect: integer;
    // 1 �������� ��� ������ � ����������
    property Gears[Index: integer]: TMultiGrooveOutput read GetGears
      write SetGears; default;
  end;

implementation

{
  ******************************** TMultiGrooveBelt *******************************
}
constructor TMultiGrooveBelt.Create(Input: TMultiGrooveInput);
begin
  // inherited Create;

  FFullName := '������������ ������� ��������';
  FBeltType := btMultiGroove;

  { � ������ ������� ����� ���������� �������������� ��������� � ����� ������ }
{$IFDEF Debug}
  try
{$ENDIF}
    P1 := Input.P1;
    n1 := Input.n1;
    SectionIndex := Input.SectionIndex;
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
  alfa_min := 120; { ���������� ���������� ���� ������� }
  nyu_max := 20; { ����������� ���������� ����� �������� }
  V_max := 35; { ����������� ���������� �������� ����� }
  f_pr := 0.73; { ����������� ����������� ������ }

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

function TMultiGrooveBelt.First: TMultiGrooveOutput;
begin
  if Count > 0 then
    Result := Gears[0]
  else
    raise EListError.Create
      ('[TMultiGrooveBelt.First] ������� ������� ������ �������� � ������ ���������');
end;

function TMultiGrooveBelt.GetGears(Index: integer): TMultiGrooveOutput;
begin
  if Index < Count then
    Result := FGears[Index]
  else
    raise EListError.Create
      ('[TMultiGrooveBelt.GetGears] ������� ���������� � �������� � ������� ������ �������������');
end;

function TMultiGrooveBelt.Section(SectionIndex: integer): String;
begin
  inherited;

  if SectionIndex <= High(PClinT) then
    Result := PClinT[SectionIndex]
  else
    raise EAccessViolation.Create
      ('[TMultiGrooveBelt.GetSection] ����������� ����� ����� ������� (SectionIndex)');
end;

function TMultiGrooveBelt.Last: TMultiGrooveOutput;
begin
  if Count > 0 then
    Result := Gears[High(FGears)]
  else
    raise EListError.Create
      ('[TMultiGrooveBelt.Last] ������� ������� ��������� �������� � ������ ���������');
end;

function TMultiGrooveBelt.MinDiameter: extended;
var
  Tip_pkl: integer;
  // ���� ������� ������ ��� ����, �� ���������� ���������� ��� �������
  // ������������ � ����� ��������� � ���� ����������
begin
  if n1 = 0 then
    raise EZeroDivide.CreateFmt
      ('[TMultiGrooveBelt.MinDiameter] ������ ������� �� ���� ��� ������� ���������� ����������� �������� ����� (D1). ������� �������� �������� ����� (n1) �� ����� ���� ����� ����',
      []);

  Tip_pkl := 0;
  if SectionIndex = 0 then
  begin
    inc(Tip_pkl);

    // ������� ����������� ������������� ������-�� ���� �����
    while 9550 * P1 / n1 > T2S[Tip_pkl] do
      inc(Tip_pkl);

    if Tip_pkl <= High(PClinT) then
      Result := TArrayD[Round(Array_pkl[Tip_pkl, 10])]
    else
      raise ERangeError.CreateFmt
        ('[TMultiGrooveBelt.MinDiameter] ��� ������� ���������� ���������� ���������� ������� ����� (D1) ����������� ���������� ������� (Tip_pkl=%d)',
        [Tip_pkl]);
  end
  else
    // ���� ������� ������, �� ����������� ������� ��������� �� 10 �������
    // ������� Array_pkl (��������� ����� ��������, � �� ���� ��������)
    Result := TArrayD[Round(Array_pkl[SectionIndex, 10])];
end;

procedure TMultiGrooveBelt.SetA(const Value: extended);
begin
  inherited;

end;

procedure TMultiGrooveBelt.SetD1(const Value: extended);
var
  Tip_pkl: integer;
  // ���� ���� ������� ������ ��� ����, �� ���������� ���������� ��� �������
  // ������������ � ����� ��������� � ���� ����������
begin
  if n1 = 0 then
    raise EZeroDivide.Create
      ('[TMultiGrooveBelt.SetD1] ������ ������� �� ���� ��� ������ �������� ����� (D1), ������� �������� (n1) �� ������ ���� ����� ����');

  Tip_pkl := 0;
  if SectionIndex = 0 then
  begin
    inc(Tip_pkl);
    // ������� ����������� ������������� ������-�� ���� �����
    while 9550 * P1 / n1 > T2S[Tip_pkl] do
      inc(Tip_pkl);
    if Tip_pkl > High(PClinT) then
      raise ERangeError.CreateFmt
        ('[TMultiGrooveBelt.SetD1] ��� ������� ���������� ���������� ���������� ������� ����� (D1) ����������� ���������� ������� (Tip_pkl=%d)',
        [Tip_pkl]);
  end
  else
    Tip_pkl := SectionIndex;

  { ����������� ������ �� TArrayD[Round(Array_pkl[Section,10])], 10 ������� �
    ������� Array_pkl ��� ����� (� ������� TArrayD) ���������� ����������� �������� ����� }

  { TODO : ��� ������� ���������, ���� ������������ ��������� ������ �������,
    ���� ������������ ��������� ������ ������� ������ ���� ������� ������ ������� }

  if (Value < MinDiameter) and (Value <> 0) then
    raise ERangeError.CreateFmt
      ('[TMultiGrooveBelt.SetD1] ������� ����� (D1) �� ����� ���� ����� %g, ���������� ���������� �������� ��� ����� %s ����� %g �� (���� 20889-88)',
      [Value, PClinT[Tip_pkl], MinDiameter]);

  inherited;
end;

procedure TMultiGrooveBelt.SetGears(Index: integer;
  const Value: TMultiGrooveOutput);
begin
  if Index < Count then
    Gears[Index] := Value
  else
    raise EListError.Create
      ('[TMultiGrooveBelt.SetGears] ������� �������� ������ � �������� � ������� ������ �������������');
end;

function TMultiGrooveBelt.Add(Gear: TMultiGrooveOutput): integer;
begin
  SetLength(FGears, Length(FGears) + 1);
  FGears[High(FGears)] := Gear;
  Result := Length(FGears);
end;

function TMultiGrooveBelt.Calculate(VarD1: extended; VarSection: integer)
  : TMultiGrooveOutput;
Var
  b0, Aa, he, hf, b, h, delta, h2, z_max, L0, y0, F0, C_alfa, C_v, C_l, Sigma_t,
    f1, t1, t, C_d, q: extended;
  Ft, p_dop, Ft_dop: extended;
  Output: TMultiGrooveOutput;
  id2: integer;
  l_max: extended;
  F2, Fb, alfa_c, m, qqq, qw: extended;
  {



  }
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

  { TODO : �������� �������� try except }

  Output.a := a;
  Output.d1 := VarD1;
  Output.SectionIndex := VarSection;

  { ----------------------- ������ ��������� �������� -------------------------- }

  try
    if up > 1 then
      Output.d2 := Output.d1 * up
    else
      Output.d2 := Output.d1 / up;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �� ���� ��� ������� �������� �������� ����� (d2), ������������ ��������� (up) �� ����� ���� ����� ����');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� �������� �������� ����� (d2)');
  end;

  try
    RoundGOST(TArrayD, 1, 38, Output.d2, Output.d2, id2);
  except
    on E: Exception do
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] �� ������� ��������� ������� �������� ����� (d2) �� ���������� �������� �� ���� �������� ��������');
  end;

  // ���� ��������� ���������� ������ ����, ������������ ��� �� ���������
  if a = 0 then
    Output.a := 1.5 * (Output.d1 + Output.d2);
  // ����� a ������� �� ������������, ������ Output.a

  Output.l := 2 * Output.a + Pi * (Output.d1 + Output.d2) / 2 +
    sqr(Output.d2 - Output.d1) / (4 * Output.a);

  try
    RoundGOST(TArrayL, 1, Round(Array_pkl[Output.SectionIndex, 7]), Output.l,
      Output.l, id2);
  except
    on E: Exception do
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] �� ������� ��������� ����� ����� (L) �� ���������� ����������� �������� �� ������� ���� �������� ������');
  end;

  try
    Output.a := (Output.l - Pi * (Output.d1 + Output.d2) / 2) / 4 +
      sqrt(sqr(Output.l - Pi * (Output.d1 + Output.d2) / 2) - 2 *
      sqr(Output.d1 - Output.d2)) / 4;
  except
    on E: Exception do
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� ���������� ���������� (a). ��������, ����������� ������������ ����� ����� (L)');
  end;

  try
    Output.alfa := 180 - (Output.d2 - Output.d1) * 57 / Output.a;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �� ���� ��� ������� ���� ������� ����� (alfa), ���������� ��������� ���������� (a) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� ���� ������� ����� (alfa)');
  end;

  { ----------------------- ������ �������������� ���������� �������� ---------- }


  // u := Output.d2 / (C * Output.d1);
  // n2 := n1 * Output.d1 * C / Output.d2;

  if up > 1 then
  begin
    Output.V := Pi * Output.d1 * n1 / 60000
  end
  else
  begin
    Output.V := Pi * Output.d2 * n1 / 60000;
  end;

  try
    Output.nyu := 1000 * Output.V / Output.l;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �� ���� ��� ������� ������� ����� (nyu), ����� ����� (L) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� ������� ����� (nyu)');
  end;

  { ----------------------- �������� ������ ���������� �������� ---------------- }

  try
    F0 := Array_pkl[Output.SectionIndex, 3];
    delta := Array_pkl[Output.SectionIndex, 13];
    t := Array_pkl[Output.SectionIndex, 10];
    z_max := Array_pkl[Output.SectionIndex, 7];
    b := Array_pkl[Output.SectionIndex, 1];
    h2 := Array_pkl[Output.SectionIndex, 12];
    f1 := Array_pkl[Output.SectionIndex, 9];
    L0 := Array_pkl[Output.SectionIndex, 5];
  except
    on E: Exception do
      raise EAccessViolation.Create
        ('[TMultiGrooveBelt.Calculate] ������ �������������� �������� �� ������ ������ ������, ������� ����� ����� ������� (SectionIndex)');
  end;

  Output.d_e1 := Output.d1 - 2 * delta;
  Output.d_e2 := Output.d2 - 2 * delta;
  Output.d_f1 := Output.d_e1 - 2 * h2;
  Output.d_f2 := Output.d_e2 - 2 * h2;

  C_alfa := 1.37 * (1 - exp(-Output.alfa / 135));
  C_l := exp(0.16666667 * ln(Output.l / L0));

  case Output.SectionIndex of
    1:
      begin
        if up > 1 then
        begin
          C_d := 2.38 - 55 / Output.d1
        end
        else
        begin
          C_d := 2.38 - 55 / Output.d2
        end;

        C_v := 1.086 - 0.013 * Output.V;
        if C_v <= 0 then
          if up >= 1 then
            raise Exception.CreateFmt
              ('[TMultiGrooveBelt.Calculate] ������� �������� (n1) �� ����� ���� ����� %g, ����������� ���������� �������� ��� ����� ��������� %g ����� %f ��/��� (���� 20889-88)',
              [n1, Output.d1, 60000 * (1.086 / 0.013) / (Output.d1 * Pi)])

          else
            raise Exception.CreateFmt
              ('[TMultiGrooveBelt.Calculate] ������� �������� (n1) �� ����� ���� ����� %g, ����������� ���������� �������� ��� ����� ��������� %g ����� %f ��/��� (���� 20889-88)',
              [n1, Output.d2, 60000 * (1.086 / 0.013) / (Output.d2 * Pi)])
      end;
    2:
      begin
        if up > 1 then
        begin
          C_d := 2.95 - 155 / Output.d1
        end
        else
        begin
          C_d := 2.95 - 155 / Output.d2
        end;

        C_v := 0.908 - 0.0155 * Output.V;
        if C_v <= 0 then
          if up >= 1 then
            raise Exception.CreateFmt
              ('[TMultiGrooveBelt.Calculate] ������� �������� (n1) �� ����� ���� ����� %g, ����������� ���������� �������� ��� ����� ��������� %g ����� %f ��/��� (���� 20889-88)',
              [n1, Output.d1, 60000 * (0.908 / 0.0155) / (Output.d1 * Pi)])
          else
            raise Exception.CreateFmt
              ('[TMultiGrooveBelt.Calculate] ������� �������� (n1) �� ����� ���� ����� %g, ����������� ���������� �������� ��� ����� ��������� %g ����� %f ��/��� (���� 20889-88)',
              [n1, Output.d2, 60000 * (0.908 / 0.0155) / (Output.d2 * Pi)])
      end;
    3:
      begin
        if up > 1 then
        begin
          C_d := 3.04 - 328 / Output.d1
        end
        else
        begin
          C_d := 3.04 - 328 / Output.d2
        end;

        C_v := 0.910 - 0.0167 * Output.V;
        if C_v <= 0 then
          if up >= 1 then
            raise Exception.CreateFmt
              ('[TMultiGrooveBelt.Calculate] ������� �������� (n1) �� ����� ���� ����� %g, ����������� ���������� �������� ��� ����� ��������� %g ����� %f ��/��� (���� 20889-88)',
              [n1, Output.d1, 60000 * (0.91 / 0.0167) / (Output.d1 * Pi)])
          else
            raise Exception.CreateFmt
              ('[TMultiGrooveBelt.Calculate] ������� �������� (n1) �� ����� ���� ����� %g, ����������� ���������� �������� ��� ����� ��������� %g ����� %f ��/��� (���� 20889-88)',
              [n1, Output.d2, 60000 * (0.91 / 0.0167) / (Output.d2 * Pi)])
      end;
  end;

  try
    Ft := 1000 * P1 / Output.V;
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �� ���� ��� ������� ��������� ������ (Ft), �������� ����� (V) ��������� ����� ����');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� ��������� ������ (Ft)');
  end;

  if C_d < 0.6 then
    C_d := 0.6;

  // C_alfa := 1.24 * (1 - exp(-Output.alfa / 110));
  // C_v := 1 - 0.05 * (0.01 * sqr(Output.V) - 1);

  try
    Output.z := Round(Ft / (F0 * C_alfa * C_l * C_v * C_d) + 0.5);
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �� ���� ��� ������� ����� ������ (z)');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� ����� ������ (z)');
  end;

  { ��-�� ������������� ��������� ��������� ����������� C_v ������ ��������� ������������� ��������
    ��� ��������� ����� ���������� ���� ���������� ���� ������, ����� ���� ���������� ������� �� ����
    ��� ������� ������������� ����� }
  // if Output.z = 0 then
  // Output.z := 1;

  Output.Bs := 2 * f1 + t * (Output.z - 1);

  { ----------------------- ������ ��� ----------------------------------------- }

  try
    Aa := Array_pkl[Output.SectionIndex, 3];
    y0 := Array_pkl[Output.SectionIndex, 1];
  except
    on E: Exception do
      raise EAccessViolation.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �������� �� ������ ������ ������, ������� ����� ����� ������� (SectionIndex)');
  end;

  alfa_c := 0.7 * Output.alfa * Pi / 180;
  // ���� ��� �������� �� m, ������ ��� ��� �������������� ������ �������
  m := exp(f_pr * alfa_c);
  f1 := m / (m - 1) * Ft;
  F2 := f1 - Ft;
  Output.F0 := Ft / 2 * ((m + 1) / (m - 1));

  try
    Output.Fb := sqrt(sqr(f1) + sqr(F2) - 2 * f1 * F2 * cos(Output.alfa));
  except
    on E: EInvalidOp do
      raise EInvalidOp.Create
        ('[TMultiGrooveBelt.Calculate] ���� ������ �� �������������� �������� ��� ������� �������� �� ���� ����� (Fb)');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� �������� �� ���� ����� (Fb)');
  end;

  Output.Vol := (Output.Bs * (Pi * (sqr(Output.d1) + sqr(Output.d2)) + 4 *
    Output.a * (Output.d1 + Output.d2))) / 8 * 1E-6;

  alfa_c := 0.7 * Output.alfa * Pi / 180;
  q := exp(f * alfa_c);

  try
    qqq := 0.25 * q * Ft / ((q - 1) * Aa * 0.1 * Output.z) + 7.5 *
      exp(1.57 * ln(y0)) / Output.d_e1 + 1.27E-3 * Output.V * Output.V;
    Output.Lh := 995 * Output.l / (Output.V * qqq) + 250;
    if Output.Lh > 6000 then
      Output.Lh := exp(0.8 * ln(Output.Lh));
  except
    on E: EZeroDivide do
      raise EZeroDivide.Create
        ('[TMultiGrooveBelt.Calculate] ������ ������� �� ���� ��� ������� ������������� (Lh)');
    on E: EInvalidOp do
      raise EInvalidOp.Create
        ('[TMultiGrooveBelt.Calculate] ��� ���������� ��������� ������������� ��� ������� �������� ��� ������� ������������� (Lh)');
    else
      raise Exception.Create
        ('[TMultiGrooveBelt.Calculate] ������ ��� ������� ������������� (Lh)');
  end;

  Result := Output;
end;

function TMultiGrooveBelt.Check(Gear: TMultiGrooveOutput): Boolean;
begin
  Result := True;

  if Gear.V > V_max then
    Result := False;

  { ����������� ������ �� Array_pkl, 7 ������� �
    ������� Array_pkl ��� ����������� ���������� ���������� ������ }
  if (Gear.z < 1) or (Gear.z > Array_pkl[Gear.SectionIndex, 7]) then
    Result := False;

  if Gear.alfa < alfa_min then
    Result := False;

  if Gear.nyu > nyu_max then
    Result := False;
end;

procedure TMultiGrooveBelt.Checking;
begin
  inherited;
end;

procedure TMultiGrooveBelt.Clear;
begin
  if Count <> 0 then
    SetLength(FGears, 0);
end;

function TMultiGrooveBelt.Collect: integer;
var
  CurrGear: TMultiGrooveOutput;
  d1x: extended;
  SecIndex, id: integer;
begin

  Clear;
  Result := 0;

  if (SectionIndex <> 0) and (d1 <> 0) then
  begin
    if 9550 * P1 / n1 <= T2S[SectionIndex] then
    begin
      CurrGear := Calculate(d1, SectionIndex);
      if Check(CurrGear) then
        Result := Add(CurrGear);
    end
  end;

  if (SectionIndex = 0) and (d1 <> 0) then
  begin
    for SecIndex := Low(PClinT) + 1 to High(PClinT) do
    begin
      if 9550 * P1 / n1 <= T2S[SecIndex] then
      begin
        CurrGear := Calculate(d1, SecIndex);
        if Check(CurrGear) then
          Result := Add(CurrGear);
      end;
    end;
  end;

  if (SectionIndex <> 0) and (d1 = 0) then
  begin
    if 9550 * P1 / n1 <= T2S[SectionIndex] then
    begin
      d1x := TArrayD[Round(Array_pkl[SectionIndex, 10])];
      repeat
        CurrGear := Calculate(d1x, SectionIndex);
        d1x := 1.25 * d1x;
        RoundGOST(TArrayD, 1, 38, d1x, d1x, id);
        if Check(CurrGear) then
        begin
          Result := Add(CurrGear);
        end;
      until CurrGear.l >= TArrayL[Round(Array_pkl[SectionIndex, 7])];
    end;
  end;

  if (SectionIndex = 0) and (d1 = 0) then
  begin
    for SecIndex := Low(PClinT) + 1 to High(PClinT) do
    begin
      if 9550 * P1 / n1 <= T2S[SecIndex] then
      begin
        d1x := TArrayD[Round(Array_pkl[SecIndex, 10])];
        repeat
          CurrGear := Calculate(d1x, SecIndex);
          d1x := 1.25 * d1x;
          RoundGOST(TArrayD, 1, 38, d1x, d1x, id);
          if Check(CurrGear) then
          begin
            Result := Add(CurrGear);
          end;
        until CurrGear.l >= TArrayL[Round(Array_pkl[SecIndex, 7])];
      end;
    end;
  end;

end;

function TMultiGrooveBelt.Count: integer;
begin
  Result := Length(FGears);
end;

constructor TMultiGrooveBelt.Create;
var
  MB: TMultiGrooveInput;
begin
  MB.P1 := 50;
  MB.n1 := 1000;
  MB.up := 2;
  MB.d1 := 140;
  MB.a := 0;
  MB.q := 1;
  MB.Cp := 1;
  MB.Tension := ttAutomatic;
  MB.SectionIndex := 0;

  Create(MB);
end;

end.
