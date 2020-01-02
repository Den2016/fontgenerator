unit SDIMAIN;

interface

uses Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.Menus, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdActns, Vcl.ActnList, Vcl.ToolWin, System.ImageList,
  System.Actions, Vcl.Samples.Spin, Vcl.Grids, SysUtils, Vcl.CheckLst, StrUtils,
  Vcl.DBActns;

type
  TSDIAppForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    FileNew1: TAction;
    FileOpen1: TAction;
    FileSave1: TAction;
    FileSaveAs1: TAction;
    FileExit1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    HelpAbout1: TAction;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    PC: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    TabSheet3: TTabSheet;
    DatasetInsert1: TDataSetInsert;
    ToolButton8: TToolButton;
    Memo2: TMemo;
    PopupMenu1: TPopupMenu;
    N2: TMenuItem;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CBLClickCheck(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure PCContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure N2Click(Sender: TObject);
  private
    { Private declarations }
    FrmCnt:Integer;
    procedure NeedMakeProg(Sender: TObject);
    procedure InsertFrame(PageIndex:Integer);
  public
    { Public declarations }
    procedure MakeProg;
  end;


var
  SDIAppForm: TSDIAppForm;

implementation

uses About, FontFrame;

{$R *.dfm}

procedure TSDIAppForm.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;

procedure TSDIAppForm.FileOpen1Execute(Sender: TObject);
begin
  OpenDialog.Execute;
end;

procedure TSDIAppForm.FileSave1Execute(Sender: TObject);
begin
  SaveDialog.Execute;
end;

procedure TSDIAppForm.FormShow(Sender: TObject);
begin
  PC.TabIndex:=0;
  InsertFrame(0);
end;

procedure TSDIAppForm.Button1Click(Sender: TObject);
begin
  MakeProg;
end;

procedure TSDIAppForm.Button3Click(Sender: TObject);
begin
  MakeProg;
end;

procedure TSDIAppForm.CBLClickCheck(Sender: TObject);
begin
  MakeProg;
end;




procedure TSDIAppForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TSDIAppForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;


procedure TSDIAppForm.InsertFrame(PageIndex: Integer);
var Frm:TFontFrm;
begin
  Frm:=TFontFrm.Create(Self);
  FRM.Name:=Frm.Name+IntToStr(FrmCnt);
  FRM.Parent:=PC.Pages[PageIndex];
  FRM.InitFont;
  FRM.OnNeedMakeProg:=NeedMakeProg;
  FrmCnt:=FrmCnt+1;

end;

procedure TSDIAppForm.MakeProg;
var S,FntNm,Comment:String;
    p,a,x,y,m,size,FntNmL:Integer;
    b,bc,cnt:word;
    L:TLetter;
    LS,LI:TStrings;
    indexes:array [0..224] of word;
//    symbols:array [0..223] of integer;
    widths:array [0..223] of byte;
    ipoint:byte;
    CBL:TCheckListBox;
    Fnt:TFont;
    Frm:TFontFrm;

begin
  memo1.Lines.Clear;
  memo1.Lines.Add('/**');
  memo1.Lines.Add('  ******************************************************************************');
  memo1.Lines.Add('  * @file           : varyfonts.c');
  memo1.Lines.Add('  * @brief          : fonts descriptions for st7735 and ssd1306');
  memo1.Lines.Add('  ******************************************************************************');
  memo1.Lines.Add('  * @attention');
  memo1.Lines.Add('  *');
  memo1.Lines.Add('  *	"Дом свободный, живите, кто хотите" (с) Простоквашино ))');
  memo1.Lines.Add('  *	');
  memo1.Lines.Add('  *	Created on: '+DateToStr(Now));
  memo1.Lines.Add('  *	Author: FontGenerator;');
  memo1.Lines.Add('  ******************************************************************************');
  memo1.Lines.Add('  */');
  memo1.Lines.Add('');
  memo1.Lines.Add('#include "varyfonts.h"');
  memo1.Lines.Add('#include "string.h"');
  memo1.Lines.Add('');
  LS:=TStringList.Create;
  LI:=TStringList.Create;
  FntNmL:=0;
  try
    for p := 0 to PC.PageCount-1 do begin
      if PC.Pages[p].Tag=0 then begin
        LI.Clear;
        FRM:=TFontFrm(PC.Pages[p].Controls[0]);
        CBL:=Frm.CBL;

        FntNm:=FRM.FontName;
        FntNm:=ReplaceStr(FntNm,' ','_');
        FntNm:=ReplaceStr(FntNm,',','');
        if Length(FntNm)>FntNmL then FntNmL:=Length(FntNm);
        S:='static uint16_t Font_'+FntNm+' [] = {';
        LS.Add('  {"'+FntNm+'", '+IntToStr(FRM.MaxH)+', VFontMetrics_'+FntNm+', Font_'+FntNM+'},');
  //		{"Tahoma_8",13,FontWidths_Tahoma_8,FontOffsets_Tahoma_8,Font_Tahoma_8},
  //		{"Tahoma_8_bold",13,FontWidths_Tahoma_8_bold,FontOffsets_Tahoma_8_bold,Font_Tahoma_8_bold},

        Memo1.Lines.Add(S);
        ipoint:=0;
        indexes[0]:=0;
        indexes[1]:=0;
        //symbols[0]:=0;
        for a := 0 to CBL.Count-1 do begin
          widths[a]:=0;
          if CBL.Checked[a] then begin
            indexes[ipoint+1]:=indexes[ipoint];
            L:=TLetter(FRM.List.objects[a]);
            widths[a]:=L.Width;
            S:='';
            b:=0;
            bc:=32768;
            cnt:=0;
            for y := 0 to FRM.MaxH-1 do begin
              for x := 0 to L.Width-1 do begin
                if L.Matrix[x][y]=clBlack then b:=b + bc;
                bc:=Trunc(bc/2);
                if bc=0 then begin
                  bc:=32768;
                  S:=S+'0x'+IntToHex(b)+', ';
                  b:=0;
                  cnt:=cnt+1;
//                  indexes[ipoint+1]:=indexes[ipoint+1]+1;
                end;
              end;
            end;
            if bc<>32768 then begin
              S:=S+'0x'+IntToHex(b)+', ';
              cnt:=cnt+1;
//              indexes[ipoint+1]:=indexes[ipoint+1]+1;
            end;
            indexes[ipoint+1]:=indexes[ipoint+1]+cnt;

            if a=0 then Comment:=' // '+IntToStr(a+32)+' sp'
            else if a=60 then Comment:=' /* '+IntToStr(a+32)+' \ */'
            else Comment:=' // '+IntToStr(a+32)+' '+AnsiChar(a+32);
            LI.Add('  {'+IntToStr(widths[a])+', '+IntToStr(cnt)+', '+IntToStr(indexes[ipoint])+'}, '+Comment);

            S:=S+Comment+' // offset '+IntToStr(Indexes[ipoint])+' 0x'+IntToHex(indexes[ipoint]);
            Memo1.Lines.Add(S);
            ipoint:=ipoint+1;
          end else begin
            //symbols[a]:=-1;
            LI.Add('  {0,0,0}, // no symbol');
          end;
        end;
        Memo1.Lines.Add('};');
        Memo1.Lines.Add('');
        Memo1.Lines.Add('VLetterMetrics VFontMetrics_'+FntNm+'[]={');
        Memo1.Lines.AddStrings(LI);
        memo1.Lines.Add('};');
        Memo1.Lines.Add('');
       // Memo1.Lines.Add('// bytes '+IntToStr(Cnt*2));
        Memo1.Lines.Add('');

//        S:='static const uint8_t FontWidths_'+FntNm+' [] = {';
//        Memo1.Lines.Add(S);
//        for a := 0 to 223 do begin
//          S:='0x'+IntToHex(widths[a])+', ';
//          if a=0 then S:=S+' // '+IntToStr(a+32)+' sp'
//          else if a=60 then S:=S+' /* '+IntToStr(a+32)+' \ */'
//          else S:=S+' // '+IntToStr(a+32)+' '+AnsiChar(a+32);
//          Memo1.Lines.Add(S);
//        end;
//        Memo1.Lines.Add('};');
//        Memo1.Lines.Add('');
//        S:='static const uint16_t FontOffsets_'+FntNm+' [] = {';
//        Memo1.Lines.Add(S);
//        ipoint:=0;
//        for a := 0 to CBL.Count-1 do begin
//          if CBL.Checked[a] then begin
//            S:='0x'+IntToHex(indexes[ipoint])+', ';
//            if a=0 then S:=S+' // '+IntToStr(a+32)+' sp'
//            else if a=60 then S:=S+' /* '+IntToStr(a+32)+' \ */'
//            else S:=S+' // '+IntToStr(a+32)+' '+AnsiChar(a+32);
//            Memo1.Lines.Add(S);
//            ipoint:=ipoint+1;
//          end;
//        end;
//        Memo1.Lines.Add('};');

      end;
    end;
    memo1.Lines.Add('VFontDef VFontList[] = {');
    Memo1.Lines.AddStrings(LS);
    memo1.Lines.Add('  {NULL,0,0,0},');
    memo1.Lines.Add('};');
    memo1.Lines.Add('');
    memo1.Lines.Add('VFontDef GetVFont(char *name){');
    memo1.Lines.Add('	uint8_t i = 0;');
    memo1.Lines.Add('	VFontDef res = {NULL,0,0,0};');
    memo1.Lines.Add('	for(;;){');
    memo1.Lines.Add('		if(VFontList[i].Name==NULL){');
    memo1.Lines.Add('			break;');
    memo1.Lines.Add('		}');
    memo1.Lines.Add('		if(strcmp(name,VFontList[i].Name)==0){');
    memo1.Lines.Add('			res=VFontList[i];');
    memo1.Lines.Add('			break;');
    memo1.Lines.Add('		}');
    memo1.Lines.Add('		i++;');
    memo1.Lines.Add('	}');
    memo1.Lines.Add('	return res;');
    memo1.Lines.Add('}');
    memo1.Lines.Add('');

    memo2.Lines.Clear;
    memo2.Lines.Add('');
    memo2.Lines.Add('/*');
    memo2.Lines.Add(' * varyfonts.h');
    memo2.Lines.Add(' *');
    memo2.Lines.Add(' *  Created on: '+DateToStr(Now));
    memo2.Lines.Add(' *      Author: FontGenerator');
    memo2.Lines.Add(' */');
    memo2.Lines.Add('');
    memo2.Lines.Add('#ifndef VARYFONTS_H_');
    memo2.Lines.Add('#define VARYFONTS_H_');
    memo2.Lines.Add('');
    memo2.Lines.Add('#include "stdint.h"');
    memo2.Lines.Add('');
    memo2.Lines.Add('');
    memo2.Lines.Add('typedef struct {');
    memo2.Lines.Add('	uint8_t Width; // ширина символа в пикселях');
    memo2.Lines.Add('	uint8_t Size; // размер данных в словах');
    memo2.Lines.Add('	uint16_t Offset; // смещение символа в словах от начала массива данных');
    memo2.Lines.Add('} VLetterMetrics;');
    memo2.Lines.Add('');
    memo2.Lines.Add('typedef struct  {');
    memo2.Lines.Add('	char Name['+IntToStr(FntNmL+1)+'];		// наименование шрифта');
    memo2.Lines.Add('	uint8_t Height;		// высота в пикселях');
    memo2.Lines.Add('	VLetterMetrics * Metrics; // ссылка на метрики символов');
    memo2.Lines.Add('	uint16_t * Font;	// ссылка на данные шрифта');
    memo2.Lines.Add('} VFontDef;');
    memo2.Lines.Add('');
    memo2.Lines.Add('VFontDef GetVFont(char *name);');
    memo2.Lines.Add('');
    memo2.Lines.Add('#endif /* VARYFONTS_H_ */');

  finally
    LS.Free;
    LI.Free;
  end;
end;



procedure TSDIAppForm.N2Click(Sender: TObject);
var x,c:Integer;
begin
  if PC.ActivePage.Tag=0 then begin
    c:=0;
    for x := 0 to PC.PageCount-1 do
      if PC.Pages[x].Tag=0 then c:=c+1;
    if c>1 then begin
      if MessageDlg('Закрыть текущую вкладку?',
        mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then begin
          PC.ActivePage.Destroy;
          if PC.ActivePageIndex<>0 then PC.ActivePageIndex:=PC.ActivePageIndex-1;

          MakeProg;
        end;
    end;

  end;
end;

procedure TSDIAppForm.NeedMakeProg(Sender: TObject);
var p:Integer;
    FRM:TFontFrm;
begin
  for p := 0 to PC.PageCount-1 do begin
    if PC.Pages[p].Tag=0 then begin
      FRM:=TFontFrm(PC.Pages[p].Controls[0]);
      if not FRM.Button1.Enabled then PC.Pages[p].Caption:=FRM.FontName;
    end;
  end;
  MakeProg;

end;

procedure TSDIAppForm.PCContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var R:TRect;
begin
  R:=PC.TabRect(PC.ActivePageIndex);
  if(MousePos.Y>R.Bottom) then
  Handled:=true;
end;

procedure TSDIAppForm.ToolButton8Click(Sender: TObject);
var Tab:TTabSheet;
    x:Integer;
begin
  Tab:=TTabSheet.Create(PC);
  Tab.PageControl:=PC;
  Tab.Caption:='Шрифт';
  for x := PC.PageCount-1 downto 0 do begin
    if PC.Pages[x].Tag=-2 then PC.Pages[x].PageIndex:=PC.PageCount-1;
    if PC.Pages[x].Tag=-1 then PC.Pages[x].PageIndex:=PC.PageCount-2;
  end;
  InsertFrame(Tab.PageIndex);
end;

end.
