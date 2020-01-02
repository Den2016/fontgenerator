unit FontFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.CheckLst, Vcl.ComCtrls, Vcl.ToolWin, System.ImageList,
  Vcl.ImgList, Vcl.Buttons;

const
  CharFrom:Integer = 32;
  CharTo:Integer = 255;

type
  TFontFrm = class(TFrame)
    Image1: TImage;
    Panel1: TPanel;
    Label3: TLabel;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    CBL: TCheckListBox;
    Splitter1: TSplitter;
    FD: TFontDialog;
    SB: TStatusBar;
    ImageList1: TImageList;
    TB: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    SBX: TScrollBox;
    procedure Button3Click(Sender: TObject);
    procedure CBLClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CBLClickCheck(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure CBLKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SBXMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SBXMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
  private
    Koeff:Integer;
    FOnNeedMakeProg: TNotifyEvent;
    FMouseFlag:Integer;
    function GetFontName: String;
    procedure SetOnNeedMakeProg(const Value: TNotifyEvent);
    procedure MoveLetterRight(AIndex:Integer);
    procedure MoveLetterLeft(AIndex:Integer);
    procedure MoveLetterTop(AIndex:Integer);
    procedure MoveLetterBottom(AIndex:Integer);
    function CalcPixel(APoint:TPoint):TPoint;
    procedure RefreshLetter;
    { Private declarations }
  public
    { Public declarations }
    tmpBitmap:TBitmap;
    List:TStringList;
    MaxW,MaxH:Integer;
    constructor Create(AOwner:TComponent); override;
    property OnNeedMakeProg:TNotifyEvent read FOnNeedMakeProg write SetOnNeedMakeProg;
    property FontName:String read GetFontName;
    procedure DrawLetter(AIndex:Integer);
    procedure ClearList;
    procedure ImportFont;
    procedure Optimize;
    procedure InitFont;
    procedure InsertLeftCol;
    procedure InsertRightCol;
    procedure InsertTopRow;
    procedure InsertBottomRow;
  end;

  TByteArray = array of byte;

  TLetter=class(TObject)
    Matrix: array of TByteArray;
    BMP:TBitmap;
    Width:Integer;
    constructor Create(W,H:Integer;C:AnsiChar;Font:TFont); virtual;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}


procedure TFontFrm.Button1Click(Sender: TObject);
begin
  ImportFont;
  Button1.Enabled:=false;
  TB.Visible:=true;
  if Assigned(FOnNeedMakeProg) then FOnNeedMakeProg(Self);

end;

procedure TFontFrm.Button2Click(Sender: TObject);
begin
  if FD.Execute(Handle) then begin
    Label3.Font:=FD.Font;
    Label3.Caption:=FontName;
  end;

end;

procedure TFontFrm.Button3Click(Sender: TObject);
begin
  Optimize;
  DrawLetter(CBL.ItemIndex);
  if Assigned(FOnNeedMakeProg) then FOnNeedMakeProg(Self);

end;

function TFontFrm.CalcPixel(APoint: TPoint): TPoint;
var x,Y:Integer;
begin
  Result.X:=Trunc(APoint.X/Koeff);
  Result.Y:=Trunc(APoint.Y/Koeff);
end;

procedure TFontFrm.CBLClick(Sender: TObject);
begin
  DrawLetter(CBL.ItemIndex);
  if Assigned(FOnNeedMakeProg) then FOnNeedMakeProg(Self);
  Application.ProcessMessages;
end;

procedure TFontFrm.CBLClickCheck(Sender: TObject);
begin
  if Assigned(FOnNeedMakeProg) then FOnNeedMakeProg(Self);

end;

procedure TFontFrm.CBLKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  DrawLetter(CBL.ItemIndex);
//  if Assigned(FOnNeedMakeProg) then FOnNeedMakeProg(Self);

end;

procedure TFontFrm.ClearList;
begin
  while List.Count<>0 do begin
    List.Objects[0].Destroy;
    List.Objects[0]:=nil;
    List.Delete(0);
  end;
  CBL.Items.Clear;
end;

constructor TFontFrm.Create(AOwner: TComponent);
begin
  inherited;
  Koeff:=15;
  tmpBitmap:=TBitmap.Create;
  List:=TStringList.Create;

end;

procedure TFontFrm.DrawLetter(AIndex: Integer);
var x,y,x1,y1,k,c:Integer;
    R,R1:TRect;
    L:TLetter;
begin
  l:=TLetter(List.Objects[AIndex]);
  try
    k:=Koeff;
    tmpBitmap.SetSize(L.Width*k+1,MaxH*k+1);
    R1:=Rect(0,0,L.Width*k-1,MaxH*k-1);
    with tmpBitmap.Canvas do begin
      Brush.Color:=clWhite;
      Pen.Color:=RGB(220,220,220);
      Pen.Style:=psSolid;
      FillRect(R1);

      X:=0;
      x1:=0;
      while x<=L.Width*k do begin
        y:=0;
        y1:=0;
        MoveTo(x,0);
        LineTo(x,MaxH*k);
        while y<=MaxH*k do begin
          MoveTo(0,Y);
          LineTo(L.Width*k,Y);

          R:=Rect(x+1,y+1,x+k,y+k);
          if x1<=L.Width then if y1<=High(L.Matrix[x1]) then begin
            c:=L.Matrix[x1][y1];
            if C<>clBlack then C:=clWhite;

            Brush.Color:=C;
            FillRect(R);
          end;
          y:=y+k;
          y1:=y1+1;
        end;
        x:=x+k;
        x1:=x1+1;
      end;
    end;
  finally
    Image1.Picture.Bitmap:=tmpBitmap;
    Image1.Width:=R1.Width;
    Image1.Height:=R1.Height;

  end;
end;

function TFontFrm.GetFontName: String;
begin
  Result:=FD.Font.Name+', '+IntToStr(FD.Font.Size);
  if fsBold in FD.Font.Style then Result:=Result+', bold';
  if fsItalic in FD.Font.Style then Result:=Result+', italic';
  if fsUnderline in FD.Font.Style then Result:=Result+', underline';
  if fsStrikeOut in FD.Font.Style then Result:=Result+', strikeout';

end;

procedure TFontFrm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then FMouseFlag:=1;
  if Button=mbRight then FMouseFlag:=2;
end;

procedure TFontFrm.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var P:TPoint;
    L:TLetter;
begin
  if CBL.ItemIndex=-1 then exit;
  P.X:=Trunc((x-1)/koeff);
  P.Y:=Trunc((y-1)/koeff);
  SB.Panels[0].Text:=IntToStr(x)+', '+IntToStr(y)+' | '+IntToStr(P.X)+', '+IntToStr(P.Y);
  if FMouseFlag<>0 then begin
    L:=TLetter(List.Objects[CBL.ItemIndex]);
    if FMouseFlag=1 then L.Matrix[p.X][p.Y]:=0;
    if FMouseFlag=2 then L.Matrix[p.X][p.Y]:=255;
    DrawLetter(CBL.ItemIndex);
  end;

end;

procedure TFontFrm.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseFlag:=0;
end;

procedure TFontFrm.ImportFont;
var x:Byte;
    S:String;
    H,W:Integer;
    L:TLetter;
    Enc:TEncoding;
begin
  with tmpBitmap.Canvas do begin
    Font:=FD.Font;
    Font.Color:=clBlack;
    Brush.Color:=clWhite;
    // get max width and height
    MaxW:=0;
    MaxH:=0;
    for x := CharFrom to CharTo do begin
      S:=AnsiChar(X);
      h:=TextHeight(S);
      w:=TextWidth(S);
      if H>MaxH then MaxH:=H;
      if W>MaxW then MaxW:=W;
    end;
    CBL.Items.Clear;
    ClearList;
    CBL.Visible:=false;
    for x := CharFrom to CharTo do begin
      L:=TLetter.Create(MaxW,MaxH,AnsiChar(X),FD.Font);
      List.AddObject(AnsiChar(X),L);
      CBL.Items.Add(IntToStr(X)+' ('+IntToHex(X)+') '+AnsiChar(X));
      if not(((x>=128) and (x<=167)) or ((x>=169)and(x<=183)) or ((x>=185)and(x<=191))) then CBL.Checked[CBL.Items.Count-1]:=true;
    end;
    CBL.Visible:=True;
    CBL.ItemIndex:=0;
    DrawLetter(0);
  end;
  Label1.Caption:='Высота шрифта '+IntToStr(MaxH);
end;

procedure TFontFrm.InitFont;
begin
  Label3.Font:=FD.Font;
  Label3.Caption:=FontName;

end;

procedure TFontFrm.InsertBottomRow;
begin

end;

procedure TFontFrm.InsertLeftCol;
var a:Integer;
begin
  InsertRightCol;
  for a := 0 to List.Count-1 do begin
    MoveLetterRight(a);
  end;
end;

procedure TFontFrm.InsertRightCol;
var a,x,y:Integer;
    L:TLetter;
begin
  for a := 0 to List.Count-1 do begin
    L:=TLetter(List.Objects[a]);
    SetLength(L.Matrix,L.Width+1);
    SetLength(L.Matrix[L.Width],MaxH);
    L.Width:=L.Width+1;
    for y := 0 to MaxH-1 do begin
      L.Matrix[L.Width-1][y]:=255;
    end;
  end;
end;

procedure TFontFrm.InsertTopRow;
begin

end;

procedure TFontFrm.MoveLetterBottom(AIndex: Integer);
var x,y:Integer;
    L:TLetter;
begin
  L:=TLetter(List.Objects[AIndex]);
  L:=TLetter(List.Objects[AIndex]);
  for x := 0 to L.Width-1 do begin
    for y := MaxH-1 downto 1 do begin
      L.Matrix[x][y]:=L.Matrix[x][y-1];
    end;
  end;
  for x := 0 to L.Width-1 do
    L.Matrix[x][0]:=255;
end;

procedure TFontFrm.MoveLetterLeft(AIndex: Integer);
var x,y:Integer;
    L:TLetter;
begin
  L:=TLetter(List.Objects[AIndex]);
  L:=TLetter(List.Objects[AIndex]);
  for x := 0 to L.Width-2 do begin
    for y := 0 to MaxH-1 do begin
      L.Matrix[x][y]:=L.Matrix[x+1][y];
    end;
  end;
  for y := 0 to MaxH do begin
    L.Matrix[L.Width-1][y]:=255;
  end;

end;

procedure TFontFrm.MoveLetterRight(AIndex: Integer);
var x,y:Integer;
    L:TLetter;
begin
  L:=TLetter(List.Objects[AIndex]);
  for x := L.Width-1 downto 1 do begin
    for y := 0 to MaxH-1 do begin
      L.Matrix[x][y]:=L.Matrix[x-1][y];
    end;
  end;
  for y := 0 to MaxH do begin
    L.Matrix[0][y]:=255;
  end;

end;

procedure TFontFrm.MoveLetterTop(AIndex: Integer);
var x,y:Integer;
    L:TLetter;
begin
  L:=TLetter(List.Objects[AIndex]);
  L:=TLetter(List.Objects[AIndex]);
  for x := 0 to L.Width-1 do begin
    for y := 0 to MaxH-1 do begin
      L.Matrix[x][y]:=L.Matrix[x][y+1];
    end;
  end;
  for x := 0 to L.Width-1 do
    L.Matrix[x][MaxH-1]:=255;
end;

procedure TFontFrm.Optimize;
var x,y,m,lastcol:Integer;
    L:TLetter;
    Flag:Boolean;
begin
  for x := 0 to CBL.Count-1 do begin
    L:=TLetter(List.Objects[x]);
    Flag:=true;
    lastCol:=0;
    repeat
      repeat
        for m := High(L.Matrix[L.Width-1])-1 downto 0 do
          if L.Matrix[L.Width-1][m]=clBlack then begin
            Flag:=false;
            L.Width:=L.Width+1;
            break;
          end;
        if Flag then L.Width:=L.Width-1;

      until (not flag) or (L.Width=0);
//      for y := 0 to High(L.Matrix) do begin
//        for m := 0 to High(L.Matrix[y])-1 do
//          if L.Matrix[y][m]=clBlack then begin
//            Flag:=false;
//            L.Width:=m+1;
//            break;
//          end;
//        if not Flag then break;
//
//      end;

      if L.Width=0 then begin
        Flag:=false;
        L.Width:=Round(MaxW/2);
      end;
    Until not flag;
  end;
end;


procedure TFontFrm.RefreshLetter;
begin
  if CBL.ItemIndex<>-1 then DrawLetter(CBL.ItemIndex);
end;

procedure TFontFrm.SBXMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then Begin
      if CBL.ItemIndex<>-1 then begin
        Koeff:=Koeff-1;
        if Koeff<2 then Koeff:=2;
        
        DrawLetter(CBL.ItemIndex);
      end;
  End;

end;

procedure TFontFrm.SBXMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then Begin
      if CBL.ItemIndex<>-1 then begin
        Koeff:=Koeff+1;
        DrawLetter(CBL.ItemIndex);
      end;
  End;

end;

procedure TFontFrm.SetOnNeedMakeProg(const Value: TNotifyEvent);
begin
  FOnNeedMakeProg := Value;
end;

procedure TFontFrm.ToolButton10Click(Sender: TObject);
begin
  if CBL.ItemIndex<>-1 then begin
    MoveLetterLeft(CBL.ItemIndex);
    DrawLetter(CBl.ItemIndex);
  end;

end;

procedure TFontFrm.ToolButton11Click(Sender: TObject);
begin
  if CBL.ItemIndex<>-1 then begin
    MoveLetterTop(CBL.ItemIndex);
    DrawLetter(CBl.ItemIndex);
  end;

end;

procedure TFontFrm.ToolButton12Click(Sender: TObject);
begin
  if CBL.ItemIndex<>-1 then begin
    MoveLetterRight(CBL.ItemIndex);
    DrawLetter(CBl.ItemIndex);
  end;

end;

procedure TFontFrm.ToolButton13Click(Sender: TObject);
begin
  if CBL.ItemIndex<>-1 then begin
    MoveLetterBottom(CBL.ItemIndex);
    DrawLetter(CBl.ItemIndex);
  end;

end;

procedure TFontFrm.ToolButton1Click(Sender: TObject);
begin
  InsertLeftCol;
  RefreshLetter;
end;

procedure TFontFrm.ToolButton2Click(Sender: TObject);
begin
  InsertRightCol;
  RefreshLetter;
end;

procedure TFontFrm.ToolButton5Click(Sender: TObject);
begin
  InsertTopRow;
  RefreshLetter;

end;

procedure TFontFrm.ToolButton6Click(Sender: TObject);
begin
  InsertBottomRow;
  RefreshLetter;
end;

procedure TFontFrm.ToolButton8Click(Sender: TObject);
begin
  if CBL.ItemIndex<>-1 then begin
    MaxH:=MaxH-1;
    Label1.Caption:='Высота шрифта '+IntToStr(MaxH);
    DrawLetter(CBl.ItemIndex);
  end;

end;

{ TLetter }

constructor TLetter.Create(W,H:Integer;C:AnsiChar;Font:TFont);
var R:TRect;
    x,y:Integer;
    S:String;
    Flag:Boolean;
begin
  TObject.Create;
  Width:=W;
  BMP:=TBitmap.Create;
  BMP.Monochrome:=True;
  BMP.SetSize(W+1,H+1);
  R:=Rect(0,0,W,H);
  BMP.Canvas.Font:=Font;
  BMP.Canvas.Brush.Color:=clWhite;
  BMP.Canvas.Font.Color:=clBlack;
  BMP.Canvas.FillRect(R);
  S:=C;
  DrawText(BMP.Canvas.Handle,S,1,R,DT_SINGLELINE);
  SetLength(Matrix,W);
  for x := 0 to W-1 do begin
    SetLength(Matrix[x],H);
    for y := 0 to H-1 do begin
      Matrix[x][y]:=BMP.Canvas.Pixels[x,y];
    end;
  end;
  // анализ, вдруг надо вставить колонку в конце, чтобы оптимизатор не глючил
  Flag:=False;
  for y := 0 to H-1 do
    if Matrix[w-1][y]=clBlack then Flag:=true;
  if Flag then begin
    //добавим пустую колонку
    SetLength(Matrix,W+1);
    SetLength(Matrix[W],H);
    for y := 0 to H-1 do Matrix[W][y]:=255;
    Width:=W+1;

  end;

end;

destructor TLetter.Destroy;
begin
  SetLength(Matrix,0);
  BMP.Destroy;
  BMP:=nil;
  inherited;
end;


end.
