unit MainFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ToolWin, Vcl.StdCtrls, Vcl.ImgList,
  Vcl.StdActns, GearClassesUnit, GearTypesUnit;
// Windows, Messages,SysUtils,Variants,
// Classes, Graphics,
// Controls, Forms, Dialogs, Menus,
// ComCtrls, ExtCtrls,ToolWin, StdCtrls, ImgList,
// StdActns, GearClassesUnit, GearTypesUnit,
// ActnList;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    MainActionList: TActionList;
    StatusBar: TStatusBar;
    ToolBar: TToolBar;
    TypeListboxPanel: TPanel;
    Splitter: TSplitter;
    DoingTreeViewPanel: TPanel;
    TypeListBox: TListBox;
    ToolButton1: TToolButton;
    FileNew: TAction;
    FileOpen: TAction;
    FileSave: TAction;
    ApplicationClose: TAction;
    FileSaveAs: TAction;
    HelpAbout: TAction;
    Action7: TAction;
    Action8: TAction;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    EnabledImageList: TImageList;
    DisablesImageList: TImageList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    ToolButton8: TToolButton;
    N1: TMenuItem;
    FileNew1: TMenuItem;
    FileOpen1: TMenuItem;
    FileSave1: TMenuItem;
    FileSaveAs1: TMenuItem;
    N2: TMenuItem;
    ApplicationClose1: TMenuItem;
    N3: TMenuItem;
    Copy1: TMenuItem;
    Copy2: TMenuItem;
    Paste1: TMenuItem;
    N4: TMenuItem;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ListBoxImageList: TImageList;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ViewAsReport: TAction;
    ViewAsList: TAction;
    ViewAsSmallIcon: TAction;
    ViewAsIcon: TAction;
    DoingListView: TListView;
    HelpAbout1: TMenuItem;
    DoingSmImageList: TImageList;
    DoingLgImageList: TImageList;
    DoingStImageList: TImageList;
    ToolButton16: TToolButton;
    ApplicationDebug: TAction;
    procedure FormCreate(Sender: TObject);
    procedure TypeListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ViewAsIconExecute(Sender: TObject);
    procedure ViewAsListExecute(Sender: TObject);
    procedure ViewAsSmallIconExecute(Sender: TObject);
    procedure ViewAsReportExecute(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure ApplicationDebugExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses DebugNarrowFormUnit, DebugMultiGrooveFormUnit, DebugVeeFormUnit, DebugFilmFormUnit, DebugFlatFormUnit;

{$R *.dfm}

procedure TMainForm.ApplicationDebugExecute(Sender: TObject);
var
  DebugNarrowForm: TDebugNarrowForm;
  DebugMultiGrooveForm: TDebugMultiGrooveForm;
  DebugVeeForm: TDebugVeeForm;
  DebugFilmForm: TDebugFilmForm;
  DebugFlatForm: TDebugFlatForm;
begin
  case TypeListBox.ItemIndex of
     0:
      try
        DebugMultiGrooveForm := TDebugMultiGrooveForm.Create(Self);
        DebugMultiGrooveForm.ShowModal;
      finally
        DebugMultiGrooveForm.Free;
        DebugMultiGrooveForm := nil;
      end;
    1:
      try
        DebugNarrowForm := TDebugNarrowForm.Create(Self);
        DebugNarrowForm.ShowModal;
      finally
        DebugNarrowForm.Free;
        DebugNarrowForm := nil;
      end;
    2:
      try
        DebugVeeForm := TDebugVeeForm.Create(Self);
        DebugVeeForm.ShowModal;
      finally
        DebugVeeForm.Free;
        DebugVeeForm := nil;
      end;
    3:
      try
        DebugFilmForm := TDebugFilmForm.Create(Self);
        DebugFilmForm.ShowModal;
      finally
        DebugFilmForm.Free;
        DebugFilmForm := nil;
      end;
    4:
      try
        DebugFlatForm := TDebugFlatForm.Create(Self);
        DebugFlatForm.ShowModal;
      finally
        DebugFlatForm.Free;
        DebugFlatForm := nil;
      end;
  else
    ShowMessage('�� ������� ��� �������� ��� ������� ���� ��� �� ����� ������');
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  a: TAllGears;
  i: Integer;
begin
  a := TAllGears.Create;
  for i := 0 to a.Gears.Count - 1 do
  begin
    TypeListBox.Items.Add(TGear(a.Gears[i]).FullName)
  end;
  TypeListBox.ItemIndex := 0;
end;

procedure TMainForm.HelpAboutExecute(Sender: TObject);
begin
  { TODO : �������� ���� �� ������� }
  ShowMessage('����� ����� ���������� �� �������');
end;

procedure TMainForm.TypeListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  (Control as TListBox).Canvas.FillRect(Rect);
  ListBoxImageList.Draw((Control as TListBox).Canvas, Rect.Left + 5,
    Rect.Top + 5, Index, True);
  (Control as TListBox).Canvas.TextOut(Rect.Left + 30, Rect.Top + 7,
    (Control as TListBox).Items[Index]);
end;

procedure TMainForm.ViewAsIconExecute(Sender: TObject);
begin
  DoingListView.ViewStyle := vsIcon;
end;

procedure TMainForm.ViewAsListExecute(Sender: TObject);
begin
  DoingListView.ViewStyle := vsList;
end;

procedure TMainForm.ViewAsReportExecute(Sender: TObject);
begin
  DoingListView.ViewStyle := vsReport;
end;

procedure TMainForm.ViewAsSmallIconExecute(Sender: TObject);
begin
  DoingListView.ViewStyle := vsSmallIcon;
end;

end.
