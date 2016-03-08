unit DebugVeeFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.ComCtrls, Vcl.ExtCtrls, Belts.Vee, Vcl.AppEvnts;
// Windows,Messages,SysUtils,Variants,Classes,Graphics,
// Controls,Forms,Dialogs,StdCtrls,Grids,
// ComCtrls,ExtCtrls, Belts.Narrow, AppEvnts;

type
  TDebugVeeForm = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    Button1: TButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    EditP1: TEdit;
    EditN1: TEdit;
    EditUp: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ComboBoxD1: TComboBox;
    ComboBoxCp: TComboBox;
    ComboBoxQ: TComboBox;
    ComboBoxA: TComboBox;
    ComboBoxSect: TComboBox;
    ComboBoxTens: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ApplicationEvents1: TApplicationEvents;
    Button2: TButton;
    ButtonMonkey: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditP1Exit(Sender: TObject);
    procedure EditN1Exit(Sender: TObject);
    procedure EditUpExit(Sender: TObject);
    procedure ComboBoxD1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxSectChange(Sender: TObject);
    procedure ComboBoxD1Change(Sender: TObject);
    procedure ComboBoxAExit(Sender: TObject);
    procedure ComboBoxCpChange(Sender: TObject);
    procedure ComboBoxTensChange(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure Button2Click(Sender: TObject);
    procedure ButtonMonkeyClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    a: TVeeBelt;
  public
    { Public declarations }
    procedure Refresh;
  end;

implementation

uses GearClassesUnit, GearTypesUnit, Gost, MainFormUnit;

{$R *.dfm}

procedure TDebugVeeForm.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
var
  LogFile: TextFile; // ��������� ���-����
  FileName: string; // ���� � ��� ���-�����
begin
  // ��� ��� ����� ������� ����� �� ��� ��� ����������, ��
  // � ����������� log
  FileName := ChangeFileExt(Application.ExeName, 'log') + '.log';

  AssignFile(LogFile, FileName);

  // ���� ���� ���������� ������������, ����� �������

  if FileExists(FileName) then
    Append(LogFile) // ������� ������������ ����
  else
    Rewrite(LogFile); // ������� ����� ����

  try
    // �������� ����+����� � ����� ������ � ���-����
    Writeln(LogFile, DateTimeToStr(Now) + ' ' + E.Message + #13 + ' P1=' +
      FloatToStr(a.P1) + ' N1=' + FloatToStr(a.N1) + ' UP=' + FloatToStr(a.UP) +
      ' D1=' + FloatToStr(a.d1) + ' A=' + FloatToStr(a.a) + ' Cp=' +
      FloatToStr(a.Cp) + ' Sect=' + FloatToStr(a.SectionIndex));
    // �������� ������
    Application.ShowException(E);
  finally
    CloseFile(LogFile); // ������� ����
  end;
end;

procedure TDebugVeeForm.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  a.P1 := StrToFloat(EditP1.Text);
  a.N1 := StrToFloat(EditN1.Text);
  a.UP := StrToFloat(EditUp.Text);

  if ComboBoxD1.ItemIndex = 0 then
    a.d1 := 0
  else
    a.d1 := StrToFloat(ComboBoxD1.Text);

  if ComboBoxA.Text = '�� �����' then
    a.a := 0
  else
    a.a := StrToFloat(ComboBoxA.Text);

  case ComboBoxCp.ItemIndex of
    0:
      a.Cp := 1;
    1:
      a.Cp := 1.15;
    2:
      a.Cp := 1.25;
    3:
      a.Cp := 1.55;
  end;

  case ComboBoxTens.ItemIndex of
    0:
      a.Tension := ttAutomatic;
    1:
      a.Tension := ttTiming;
  end;

  a.SectionIndex := ComboBoxSect.ItemIndex;

  a.Collect;

  StatusBar1.Panels[0].Text := '���������� ������������ �������: ' +
    IntToStr(a.Count);

  if a.Count <> 0 then
  begin
    StringGrid1.RowCount := a.Count + 1;
    for I := 0 to a.Count - 1 do
    begin
      StringGrid1.Cells[0, I + 1] := IntToStr(I + 1);
      StringGrid1.Cells[1, I + 1] := FloatToStr(a.Gears[I].d1);
      StringGrid1.Cells[2, I + 1] := FloatToStr(a.Gears[I].l);
      StringGrid1.Cells[3, I + 1] := FloatToStr(a.Gears[I].d2);
      StringGrid1.Cells[4, I + 1] := FloatToStr(a.Gears[I].a);
      StringGrid1.Cells[5, I + 1] := a.Section(a.Gears[I].SectionIndex);
      StringGrid1.Cells[6, I + 1] := IntToStr(a.Gears[I].z);
      StringGrid1.Cells[7, I + 1] := FloatToStr(a.Gears[I].d_e1);
      StringGrid1.Cells[8, I + 1] := FloatToStr(a.Gears[I].d_e2);
      StringGrid1.Cells[9, I + 1] := FloatToStr(a.Gears[I].d_f1);
      StringGrid1.Cells[10, I + 1] := FloatToStr(a.Gears[I].d_f2);
      StringGrid1.Cells[11, I + 1] := FloatToStr(a.Gears[I].Bs);
      StringGrid1.Cells[12, I + 1] := FloatToStr(a.Gears[I].F0);
      StringGrid1.Cells[13, I + 1] := FloatToStr(a.Gears[I].Fb);
      StringGrid1.Cells[14, I + 1] := FloatToStr(a.Gears[I].Lh);
      StringGrid1.Cells[15, I + 1] := FloatToStr(a.Gears[I].Vol);
      StringGrid1.Cells[16, I + 1] := FloatToStr(a.Gears[I].alfa);
      StringGrid1.Cells[17, I + 1] := FloatToStr(a.Gears[I].nyu);
      StringGrid1.Cells[18, I + 1] := FloatToStr(a.Gears[I].PMax);
      StringGrid1.Cells[19, I + 1] := FloatToStr(a.Gears[I].V);
    end;
  end;
end;

procedure TDebugVeeForm.Button2Click(Sender: TObject);
var
  I: Integer;
  cnt, resz, zprev, secprev: Integer;
  res, re: extended;
  F: TextFile;
begin
  AssignFile(F, 'ResultN1.txt');
  Rewrite(F);
  resz := 1;
  cnt := 0;
    a.P1 := P1Min;
  a.N1 := N1Min;
  a.UP := UPMin;
//  a.P1 := 10;
//  a.N1 := 1000;
//  a.UP := 2;

  while a.N1 <= N1Max - 50 do
  begin

    a.Clear;
    if ComboBoxD1.ItemIndex = 0 then
      a.d1 := 0
    else
      a.d1 := StrToFloat(ComboBoxD1.Text);

    if ComboBoxA.Text = '�� �����' then
      a.a := 0
    else
      a.a := StrToFloat(ComboBoxA.Text);

    case ComboBoxCp.ItemIndex of
      0:
        a.Cp := 1;
      1:
        a.Cp := 1.15;
      2:
        a.Cp := 1.25;
      3:
        a.Cp := 1.55;
    end;

    case ComboBoxTens.ItemIndex of
      0:
        a.Tension := ttAutomatic;
      1:
        a.Tension := ttTiming;
    end;

    a.SectionIndex := ComboBoxSect.ItemIndex;

    a.Collect;
    inc(cnt);

    StatusBar1.Panels[0].Text := '���������� ������������ �������: ' +
      IntToStr(a.Count);

    zprev := 1;
    secprev := 1;

    if a.Count <> 0 then
    begin
      StringGrid1.RowCount := a.Count + 1;
      for I := 0 to a.Count - 1 do
      begin
        StringGrid1.Cells[0, I + 1] := IntToStr(I + 1);
        StringGrid1.Cells[1, I + 1] := FloatToStr(a.Gears[I].d1);
        StringGrid1.Cells[2, I + 1] := FloatToStr(a.Gears[I].l);
        StringGrid1.Cells[3, I + 1] := FloatToStr(a.Gears[I].d2);
        StringGrid1.Cells[4, I + 1] := FloatToStr(a.Gears[I].a);
        StringGrid1.Cells[5, I + 1] := a.Section(a.Gears[I].SectionIndex);
        StringGrid1.Cells[6, I + 1] := IntToStr(a.Gears[I].z);
        StringGrid1.Cells[7, I + 1] := FloatToStr(a.Gears[I].d_e1);
        StringGrid1.Cells[8, I + 1] := FloatToStr(a.Gears[I].d_e2);
        StringGrid1.Cells[9, I + 1] := FloatToStr(a.Gears[I].d_f1);
        StringGrid1.Cells[10, I + 1] := FloatToStr(a.Gears[I].d_f2);
        StringGrid1.Cells[11, I + 1] := FloatToStr(a.Gears[I].Bs);
        StringGrid1.Cells[12, I + 1] := FloatToStr(a.Gears[I].F0);
        StringGrid1.Cells[13, I + 1] := FloatToStr(a.Gears[I].Fb);
        StringGrid1.Cells[14, I + 1] := FloatToStr(a.Gears[I].Lh);
        StringGrid1.Cells[15, I + 1] := FloatToStr(a.Gears[I].Vol);
        StringGrid1.Cells[16, I + 1] := FloatToStr(a.Gears[I].alfa);
        StringGrid1.Cells[17, I + 1] := FloatToStr(a.Gears[I].nyu);
        StringGrid1.Cells[18, I + 1] := FloatToStr(a.Gears[I].PMax);
        StringGrid1.Cells[19, I + 1] := FloatToStr(a.Gears[I].V);

        if ((a.Gears[I].SectionIndex) > secprev) then
        begin

          secprev := a.Gears[I].SectionIndex;
          res := (a.Gears[I].z);
          re := (a.Gears[I].SectionIndex);
          Writeln(F, FloatToStr(a.N1) + #9 + FloatToStr(res) + #9 +
            (FloatToStr(re)));

        end;

        if ((a.Gears[I].z) > zprev) then
        begin
          zprev := a.Gears[I].z;

          res := (a.Gears[I].z);
          re := (a.Gears[I].SectionIndex);
          Writeln(F, FloatToStr(a.N1) + #9 + FloatToStr(res) + #9 +
            (FloatToStr(re)));

        end;
      end;
    end;
    a.UP := a.UP + 0.5;
  end;
  ShowMessage(IntToStr(cnt));

  CloseFile(F);
end;

procedure TDebugVeeForm.Button3Click(Sender: TObject);
begin
  // Refresh; // ��������� ���������� ������ D1 � � ���������� �� ����
  try
    case Random(9) of // �������� ���� ����� ��� ���������
      0:
        begin
          EditP1.SetFocus;
          EditP1.Text := FloatToStr(Random(20000) / 100);
        end;

      1:
        begin
          EditN1.SetFocus;
          EditN1.Text := FloatToStr(Random(1000000) / 100);
        end;

      2:
        begin
          EditUp.SetFocus;
          EditUp.Text := FloatToStr(Random(1000) / 100);
        end;

      3:
        begin

          ComboBoxD1.SetFocus;
          ComboBoxD1.DroppedDown := True;
          sleep(10);
          ComboBoxD1.ItemIndex := Random(ComboBoxD1.Items.Count - 1) + 1;
        end;

      4:
        begin
          ComboBoxA.SetFocus;
          ComboBoxA.DroppedDown := True;
          sleep(10);
          ComboBoxA.Text := FloatToStr(Random(2000000) / 100);
          // ComboBoxA.ItemIndex := Random(ComboBoxA.Items.Count);
        end;

      5:
        begin
          ComboBoxQ.SetFocus;
          ComboBoxQ.DroppedDown := True;
          sleep(10);
          ComboBoxQ.ItemIndex := Random(ComboBoxQ.Items.Count);
        end;

      6:
        begin
          ComboBoxCp.SetFocus;
          ComboBoxCp.DroppedDown := True;
          sleep(10);
          ComboBoxCp.ItemIndex := Random(ComboBoxCp.Items.Count);
        end;

      7:
        begin
          ComboBoxTens.SetFocus;
          ComboBoxTens.DroppedDown := True;
          sleep(10);
          ComboBoxTens.ItemIndex := Random(ComboBoxTens.Items.Count);
        end;

      8:
        begin
          ComboBoxSect.SetFocus;
          ComboBoxSect.DroppedDown := True;
          sleep(10);
          ComboBoxSect.ItemIndex := Random(ComboBoxSect.Items.Count);
        end;

    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(E.Message);
      ShowMessage(E.ClassName);
    end;
  end;

  Button1Click(Self);
end;

procedure TDebugVeeForm.Button4Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 10000 do // ����� ���������� ��������
  begin
    Refresh; // ��������� ���������� ������ D1 � � ���������� �� ����

    sleep(100); // ��� 100 �����������

    try
      case Random(9) of // �������� ���� ����� ��� ���������
        0:
          begin
            EditP1.SetFocus;
            EditP1.Text := FloatToStr(Random(20000) / 100);
          end;

        1:
          begin
            EditN1.SetFocus;
            EditN1.Text := FloatToStr(Random(1000000) / 100);
          end;

        2:
          begin
            EditUp.SetFocus;
            EditUp.Text := FloatToStr(Random(1000) / 100);
          end;

        3:
          begin
            ComboBoxD1.SetFocus;
            ComboBoxD1.DroppedDown := True;
            ComboBoxD1.ItemIndex := Random(ComboBoxD1.Items.Count - 1) + 1;
            sleep(100); // ��� 100 �����������
            ComboBoxD1.DroppedDown := False;
          end;

        4:
          begin
            ComboBoxA.SetFocus;
            ComboBoxA.Text := FloatToStr(Random(2000000) / 100);
            // ComboBoxA.ItemIndex := Random(ComboBoxA.Items.Count);
          end;

        5:
          begin
            ComboBoxQ.SetFocus;
            ComboBoxQ.DroppedDown := True;
            ComboBoxQ.ItemIndex := Random(ComboBoxQ.Items.Count);
            sleep(100); // ��� 100 �����������
            ComboBoxQ.DroppedDown := False;
          end;

        6:
          begin
            ComboBoxCp.SetFocus;
            ComboBoxCp.DroppedDown := True;
            ComboBoxCp.ItemIndex := Random(ComboBoxCp.Items.Count);
            sleep(100); // ��� 100 �����������
            ComboBoxCp.DroppedDown := False;
          end;

        7:
          begin
            ComboBoxTens.SetFocus;
            ComboBoxTens.DroppedDown := True;
            ComboBoxTens.ItemIndex := Random(ComboBoxTens.Items.Count);
            sleep(100); // ��� 100 �����������
            ComboBoxTens.DroppedDown := False;
          end;

        8:
          begin
            ComboBoxSect.SetFocus;
            ComboBoxSect.DroppedDown := True;
            ComboBoxSect.ItemIndex := Random(ComboBoxSect.Items.Count);
            sleep(100); // ��� 100 �����������
            ComboBoxSect.DroppedDown := False;
          end;

      end;
    except
      Continue; // � ������ ������ ���������� � � ��������� � ���������� ����
    end;

    Button1Click(Self);
  end;
end;

procedure TDebugVeeForm.ButtonMonkeyClick(Sender: TObject);
var
  I: Integer;
  F: TextFile;
begin
  for I := 0 to 1000 do // ����� ���������� ��������
  begin
    Refresh; // ��������� ���������� ������ D1 � � ���������� �� ����
    try
      Button3Click(Self); // ����� ��������� �������� Monkey test
    except
      Continue; // � ������ ������ ���������� � � ��������� � ���������� ����
    end;
  end;
end;

procedure TDebugVeeForm.ComboBoxCpChange(Sender: TObject);
begin
  case ComboBoxCp.ItemIndex of
    0:
      a.Cp := 1;
    1:
      a.Cp := 1.15;
    2:
      a.Cp := 1.25;
    3:
      a.Cp := 1.55;
  end;
end;

procedure TDebugVeeForm.ComboBoxD1Change(Sender: TObject);
begin
  if ComboBoxD1.ItemIndex = 0 then
    a.d1 := 0
  else
    a.d1 := StrToFloat(ComboBoxD1.Text);

  Refresh;
end;

procedure TDebugVeeForm.ComboBoxD1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key <> #13 then
    Key := #0;
end;

procedure TDebugVeeForm.ComboBoxSectChange(Sender: TObject);
begin
  a.SectionIndex := ComboBoxSect.ItemIndex;
  Refresh;
end;

procedure TDebugVeeForm.ComboBoxTensChange(Sender: TObject);
begin
  case ComboBoxTens.ItemIndex of
    0:
      a.Tension := ttAutomatic;
    1:
      a.Tension := ttTiming;
  end;
end;

procedure TDebugVeeForm.EditN1Exit(Sender: TObject);
begin
  try
    a.N1 := StrToFloat(EditN1.Text);
  except
    on EConvertError do
    begin
      raise EConvertError.Create
        ('� ���� ������� �������� �������� ����� ������� �� �������� ��������');
      EditN1.SetFocus;
    end;
  end;
  Refresh;
end;

procedure TDebugVeeForm.EditP1Exit(Sender: TObject);
begin
  try
    a.P1 := StrToFloat(EditP1.Text);
  except
    on EConvertError do
    begin
      raise EConvertError.Create
        ('� ���� �������� �� ������� ���� ������� �� �������� ��������');
      EditP1.SetFocus;
    end;
  end;
  Refresh;
end;

procedure TDebugVeeForm.EditUpExit(Sender: TObject);
begin
  try
    a.UP := StrToFloat(EditUp.Text);
  except
    on EConvertError do
    begin
      raise EConvertError.Create
        ('� ���� ������������ ����� ������� �� �������� ��������');
      EditUp.SetFocus;
    end;
  end;
  Refresh;
end;

procedure TDebugVeeForm.ComboBoxAExit(Sender: TObject);
begin
  try
    if ComboBoxA.Text = '�� �����' then
      a.a := 0
    else
      a.a := StrToFloat(ComboBoxA.Text);
  except
    on EConvertError do
    begin
      raise EConvertError.Create
        ('� ���� ��������� ���������� ������� �� �������� ��������');
      ComboBoxA.SetFocus;
    end;
  end;

  Refresh;
end;

procedure TDebugVeeForm.FormShow(Sender: TObject);
var
  NB: TVeeInput;
begin
  Randomize; // �������������� ��������� ��������� �����

  PageControl1.ActivePageIndex := 0;
  StringGrid1.Cells[0, 0] := '�����';
  StringGrid1.Cells[1, 0] := 'd1';
  StringGrid1.Cells[2, 0] := 'l';
  StringGrid1.Cells[3, 0] := 'd2';
  StringGrid1.Cells[4, 0] := 'a';
  StringGrid1.Cells[5, 0] := 'Sec';
  StringGrid1.Cells[6, 0] := 'z';
  StringGrid1.Cells[7, 0] := 'd_e1';
  StringGrid1.Cells[8, 0] := 'd_e2';
  StringGrid1.Cells[9, 0] := 'd_f1';
  StringGrid1.Cells[10, 0] := 'd_f2';
  StringGrid1.Cells[11, 0] := 'Bs';
  StringGrid1.Cells[12, 0] := 'F0';
  StringGrid1.Cells[13, 0] := 'Fb';
  StringGrid1.Cells[14, 0] := 'Lh';
  StringGrid1.Cells[15, 0] := 'Vol';
  StringGrid1.Cells[16, 0] := 'alfa';
  StringGrid1.Cells[17, 0] := 'nyu';
  StringGrid1.Cells[18, 0] := 'PMax';
  StringGrid1.Cells[19, 0] := 'V';

  NB.P1 := 50;
  NB.N1 := 1000;
  NB.UP := 2;
  NB.d1 := 140;
  NB.a := 0;
  NB.Q := 1;
  NB.Cp := 1;
  NB.Tension := ttAutomatic;
  NB.SectionIndex := 0;

  a := TVeeBelt.Create(NB);

  Refresh;
end;

procedure TDebugVeeForm.Refresh;
var
  DiameterIndex: Integer;
  TempD1, TempA: extended;
begin

  if (ComboBoxA.ItemIndex > 0) or (ComboBoxA.Text <> '�� �����') then
    TempA := StrToFloat(ComboBoxA.Text)
  else
    TempA := 0;

  ComboBoxA.Items.Clear;
  ComboBoxA.Items.Add('�� �����');
  ComboBoxA.Items.Add(FloatToStr(a.MinDistance));

  if TempA < a.MinDistance then
  begin
    ComboBoxA.ItemIndex := 0;
  end
  else
  begin
    ComboBoxA.Text := FloatToStr(TempA);
  end;

  if ComboBoxD1.ItemIndex <> 0 then
    TempD1 := StrToFloat(ComboBoxD1.Text)
  else
    TempD1 := 0;

  ComboBoxD1.Items.Clear;
  ComboBoxD1.Items.Add('�� �����');

  for DiameterIndex := Low(TArrayD) to High(TArrayD) do
  begin
    if (TArrayD[DiameterIndex] >= a.MinDiameter) and
      (TArrayD[DiameterIndex] <= a.MaxDiameter) then
    begin
      ComboBoxD1.Items.Add(FloatToStr(TArrayD[DiameterIndex]));
    end;
  end;

  if (TempD1 = 0) or (TempD1 < a.MinDiameter) or (TempD1 > a.MaxDiameter) then
  begin
    ComboBoxD1.ItemIndex := 0;
  end
  else
  begin
    for DiameterIndex := 1 to ComboBoxD1.Items.Count - 1 do
      if (TempD1 = StrToFloat(ComboBoxD1.Items[DiameterIndex])) then
        ComboBoxD1.ItemIndex := DiameterIndex;
  end;

  StatusBar1.Panels[0].Text := '���������� ������������ �������: ' +
    IntToStr(a.Count);

  StatusBar1.Repaint;
end;

end.
