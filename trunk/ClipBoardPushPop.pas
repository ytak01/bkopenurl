{
------------------------------------------------------------------------
                       Clipborad PUSH and POP
                                                    Copyright(C) 2000 K2
------------------------------------------------------------------------
}
unit ClipBoardPushPop;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Clipbrd, StdCtrls;

type
  TClipHist = class(TCollection)
  private
  public
    constructor Create;
    procedure Push;
    procedure Pop;
    function CanPop: Boolean;
  private
    procedure Delete(Index: Integer);
  end;


implementation

type
  TClipObj = class
  private
    FCf: integer;
    FStream: TStream;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetToClipboard;
    procedure GetFromClipboard(Cf: integer);
  end;

  TClipHistItem = class(TCollectionItem)
  private
    FList: TList;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure SetToClipboard;
    procedure GetFromClipboard;
    procedure Clear;
  end;

{ TClipObj }

constructor TClipObj.Create;
begin
  FStream := TMemoryStream.Create;
end;

destructor TClipObj.Destroy;
begin
  inherited;
  FStream.Free;
end;

procedure TClipObj.GetFromClipboard(Cf: integer);
var
  h: THandle;
  Size: integer;
  d: PBYTE;
begin
  FStream.Size := 0;
  FCf := Cf;
  h := Clipboard.GetAsHandle(Cf);
  if h = 0 then exit;
  Size := GlobalSize(h);
  if Size = 0 then exit;
  d := GlobalLock(h);
  FStream.Write(d^, Size);
  GlobalUnlock(h);
end;

procedure TClipObj.SetToClipboard;
var
  h: THandle;
  d: PBYTE;
begin
  h := GlobalAlloc(GMEM_SHARE or GHND, FStream.Size);
  if h = 0 then raise Exception.Create('ƒƒ‚ƒŠŠm•ÛƒGƒ‰[');
  FStream.Position := 0;
  d := GlobalLock(h);
  FStream.Read(d^, FStream.Size);
  GlobalUnlock(h);
  Clipboard.SetAsHandle(FCf, h);
end;

{ TClipHistItem }

procedure TClipHistItem.Clear;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
    TClipObj(FList[i]).Free;
  FList.Clear;
end;

constructor TClipHistItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FList := TList.Create;
end;

destructor TClipHistItem.Destroy;
begin
  inherited;
  Clear;
  FList.Free;
end;

procedure TClipHistItem.GetFromClipboard;
var
  i: integer;
  CO: TClipObj;
begin
  Clear;
  for i := 0 to Clipboard.FormatCount - 1 do
  begin
    CO := TClipObj.Create;
    FList.Add(CO);
    CO.GetFromClipboard(Clipboard.Formats[i]);
  end;
end;

procedure TClipHistItem.SetToClipboard;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
    TClipObj(FList[i]).SetToClipboard;
end;

{ TClipHist }

function TClipHist.CanPop: Boolean;
begin
  Result := (Count > 0);
end;

constructor TClipHist.Create;
begin
  inherited Create(TClipHistItem);
end;

procedure TClipHist.Pop;
begin
  if Count = 0 then exit;
  Clipboard.Open;
  try
    Clipboard.Clear;
    TClipHistItem(Items[Count - 1]).SetToClipboard;
    Delete(Count - 1);
  finally
    Clipboard.Close;
  end;
end;

procedure TClipHist.Push;
begin
  Clipboard.Open;
  try
    TClipHistItem(Add).GetFromClipboard;
  finally
    Clipboard.Close;
  end;
end;

procedure TClipHist.Delete(Index: Integer);
begin
  Items[Index].Free;
end;

end.

