library BkOpenURL;
////////////////////////////////////////////////////////////////////////////////// Test DLL for plugin.
//
(*
Copyright (c) 2000 Ryota Ando <rando@ca2.so-net.ne.jp>  All rights reserved.

NOTICE:
You can freely use, modify, redistribute this source code unless you modify 
this notice. This software is provided by the author and contributors 'AS IS'
and any express or implied warranties are disclaimed.

Note:
  BeckyAPI.pas must be exist in either specified library folder (recommended)
  or the same folder as .dpr file.
*)

uses
  Windows,
  Sysutils,
  Classes,
  Messages,
  Clipbrd,
  Shellapi,
  BeckyAPI,
  Dialogs,
  IniFiles,
  ClipBoardPushPop;

const
  Ver = '1.001';

type
  TSearchEngine = record
    Name:String;
    Url:String;
end;

//const
//  g_hInstance : Longint = 0;  // not used

var
  bka : TBeckyAPI; // You can have only one instance in a project.
  szIni : array[0..MAX_PATH+2] of char; // Ini file to save your plugin settings.
  SaveExit : Pointer;  //delphi specific

  DataFolder:String;
  PlugInFolder:String;
  BrowserPath:String;
  SearchEngine1:TSearchEngine;

  g_nIDOpenURL: UINT;
  g_nIDHttpOpenURL: UINT;
  g_nIDMailtoOpenURL: UINT;
  g_nIDFtpOpenURL: UINT;
  g_nIDExpOpenURL: UINT;
  g_nIDSearchURL: UINT;

{$R *.RES}

/////////////////////////////////////////////////////////////////////////////
// DLL entry point
(*
BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
procedure LibraryProc(reason : Integer);
begin
  g_hInstance := HInstance;
  case ul_reason_for_call of
    DLL_PROCESS_ATTACH:
    begin
      LibInit;
    end;
    DLL_THREAD_ATTACH:
      break;
    DLL_THREAD_DETACH:
      break;
    DLL_PROCESS_DETACH:
      break;
  end;
end;
*)

(*
  *** Delphi-specific issue ***
  You must not create forms in LibInit. It causes GPF.
  Forms should be created in BKC_OnStart or other routines (on demand).
*)
function LibInit : boolean;
var
  lpExt : PChar;
begin
  try
    bka := TBeckyAPI.Create;
    if not bka.InitAPI then
    begin
      Result := FALSE;
      exit;
    end;
    GetModuleFileName(HInstance, szIni, MAX_PATH);
    lpExt := StrRScan(szIni, '.');
    if lpExt <> nil then
    begin
      StrCopy(lpExt, '.ini');
    end
    else
    begin
      // just in case
      strcat(szIni, '.ini');
    end;
  except
    Result := FALSE;
    exit;
  end;
  Result := TRUE;
end;

procedure LibExit;
begin
  if bka <> nil then
    bka.Destroy;
  bka := nil;
  ExitProc := SaveExit;  // set original finalization procedure chain
end;

function GetSelfFileName: String;
var
  buf: array[0..MAX_PATH-1] of char;
  R: Integer;
begin
  R := GetModuleFileName(HInstance, @buf, MAX_PATH);
  Result := Copy(buf, 1, R -1);
end;

function MyShellExecute(const BrowserName, URL: String ): Boolean;
var
  myInfo: SHELLEXECUTEINFO;
begin
  // prepare SHELLEXECUTEINFO structure
  // http://hp.vector.co.jp/authors/VA024411/vbtips02.html
  ZeroMemory(@myInfo, SizeOf(SHELLEXECUTEINFO));
  myInfo.cbSize := SizeOf(SHELLEXECUTEINFO);
  myInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  myInfo.lpFile := PChar(BrowserName);
  myInfo.lpParameters := PChar(URL);

  // start file
  Result := ShellExecuteEx(@myInfo);
end;

//*************************************************************
//
//  コマンドが実行されたよ(選択文字列を URL と見なして開く)
//
//    LPARAM : LOWORD = COMMAND ID
//
procedure ProcOpenURL(h : HWND; LPARAM : Longint); stdcall;
const
  BKC_COPY  = $E122;  { 編集 -> コピー }
var
  hTargetMenu: HMENU;
  hMain, hDmy: HWND;
  MenuPos: Integer;
  i, j, textlen: Integer;
  clip: TClipboard;
  p, p2: PChar;
  buf: String;
  clip_pp: TClipHist;
begin
  bka.GetWindowHandles(@hMain, @hDmy, @hDmy, @hDmy);
  hTargetMenu := GetMenu(hMain);
  if hTargetMenu = 0 then
    exit;

  { 編集メニューID }
  hTargetMenu := GetSubMenu(hTargetMenu, 1);
  SendMessage(hMain, WM_INITMENUPOPUP, hTargetMenu, MakeLParam(0, 0));

  for MenuPos:=0 to GetMenuItemCount(hTargetMenu) - 1 do
  begin
    { 編集 -> コピーを探す }
    if GetMenuItemID(hTargetMenu, MenuPos) = BKC_COPY then
    begin
      { 編集 -> コピーが灰色なら選択文字列無し }
      if (GetMenuState(hTargetMenu, MenuPos, MF_BYPOSITION) and MF_GRAYED) = 0 then
      begin
        { コピー操作を行う }
        clip_pp := TClipHist.Create;
        try
          clip_pp.Push;
          SendMessage(hMain, WM_COMMAND, BKC_COPY, 0);
          clip := TClipboard.Create();
          p := StrAlloc(2048);
          p2 := StrAlloc(2048);
          try
            textlen := clip.GetTextBuf(p, 2048-1);
            if(textlen <> 0) then
            begin
              j := 0;
              for i:=0 to textlen - 1 do
              begin
                { 改行コードは不要 }
                if (p[i] <> #13) and (p[i] <> #10) then
                begin
                  p2[j] := p[i];
                  Inc(j);
                end;
              end;
              { 前後のスペースを取り除く }
              p2[j] := #0;
              buf := p2;
              buf := Trim(buf);
              { 文字列を付加 }
              // http:// と見なして開く
              if LPARAM = g_nIDHttpOpenURL then
              begin
                buf := 'http://' + buf;
              end // mailto: と見なして開く
              else if LPARAM = g_nIDMailtoOpenURL then
              begin
                buf := 'mailto:' + buf;
              end
              else if LPARAM = g_nIDFtpOpenURL then
              begin
                buf := 'ftp://' + buf;
              end
              else if LPARAM = g_nIDExpOpenURL then
              begin
                if (Pos('<',buf) = 1) and (Pos('>',buf) = length(buf)) then
                begin
                  buf := Copy(buf,2,Length(buf));
                  buf := Copy(buf,1,Length(buf)-1);
                end;
                if (AnsiPos('＜',buf) = 1) and (AnsiPos('＞',buf) = length(buf)-1) then
                begin
                	buf := Copy(buf,3,Length(buf));
                  buf := Copy(buf,1,Length(buf)-2);
                end;
                if (Pos('"',buf) = 1) and (Pos('"',buf) = length(buf)) then
                begin
                	buf := Copy(buf,2,Length(buf));
                  buf := Copy(buf,1,Length(buf)-1);
                end;
                if (AnsiPos('”',buf) = 1) and (AnsiPos('”',buf) = length(buf)-1) then
                begin
                	buf := Copy(buf,3,Length(buf));
                  buf := Copy(buf,1,Length(buf)-2);
                end;
                if (Pos('[',buf) = 1) and (Pos(']',buf) = length(buf)) then
                begin
                	buf := Copy(buf,2,Length(buf));
                  buf := Copy(buf,1,Length(buf)-1);
                end;
                if (AnsiPos('「',buf) = 1) and (AnsiPos('」',buf) = length(buf)-1) then
                begin
                	buf := Copy(buf,3,Length(buf));
                  buf := Copy(buf,1,Length(buf)-2);
                end;
                if (Pos('\\',buf) <> 1) and (Pos(':\',Buf) = 0) then
                begin
                	buf := '\\' + buf;
                end;
              end;
              if LPARAM = g_nIDSearchURL then
              begin
                buf:=SearchEngine1.Url+buf;
              end;
                // デバッグ用
//                ShowMessage(buf);
              { 実行 }
              if ( BrowserPath <> '' ) and
                 ( ( LPARAM = g_nIDOpenURL ) or
                   ( LPARAM = g_nIDHttpOpenURL )
                 ) then
              begin
//              MyShellExecute( '"C:\Program Files\Mozilla Firefox\firefox.exe"', buf );
//              MyShellExecute( '"C:\Users\hogehoge\AppData\Local\Google\Chrome\Application\chrome.exe"', buf);
                MyShellExecute( BrowserPath, buf );
              end
              else
              begin
                ShellExecute(hMain, 'open', PChar(buf), nil, nil, SW_SHOW);
              end;
            end;
          finally
            StrDispose(p);
            StrDispose(p2);
            clip.Free;
          end;
        finally
          clip_pp.Pop;
          clip_pp.Free;
        end;
      end;
    end;
  end;
end;

/////////////////////////////////////////////////////////////////////////////////////////////
// Callbacks from Becky!

////////////////////////////////////////////////////////////////////////
// Called when the program is started and the main window is created.
function BKC_OnStart : Integer; stdcall;
var
  AppIni:TIniFile;
begin
    (*
    Since BKC_OnStart is called after Becky!'s main window is
    created, at least BKC_OnMenuInit with BKC_MENU_MAIN is called
    before BKC_OnStart. So, do not assume BKC_OnStart is called
    prior to any other callback.
    *)
  // Always return 0.

DataFolder:=bka.GetDataFolder;
PlugInFolder:=ExtractFileDir(GetSelfFileName)+'\';

AppIni:=TIniFile.Create(PluginFolder+'BkOpenURL.ini');
with AppIni do
begin
  try
    BrowserPath:=ReadString('Browser','Path','');
    SearchEngine1.Name:=ReadString('SearchEngine1','Name','Google');
    SearchEngine1.Url:=ReadString('SearchEngin1','URL','http://www.google.co.jp/search?q=');
  finally
    AppIni.Free;
  end;
end;

  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when the main window is closing.
function BKC_OnExit : Integer; stdcall;
begin

  // Return -1 if you don't want to quit.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when menu is intialized.
function BKC_OnMenuInit(hTargetWnd : HWND; hTargetMenu : HMENU; nType : Integer) : Integer; stdcall;
const
  MENU0_STRING            = '選択文字列を URL と見なして開く';
  // g_nIDOpenURL
  MENU1_STRING            = 'URL と見なして開く';
  MENU1_STATUSBAR_STRING  = '選択文字列を URL と見なして開きます';
  // g_nIDHttpOpenURL
  MENU2_STRING            = 'http:// を付加して開く';
  MENU2_STATUSBAR_STRING  = '選択文字列に http:// を付加して開きます';
  // g_nIDMailtoOpenURL
  MENU3_STRING            = 'mailto: を付加して開く';
  MENU3_STATUSBAR_STRING  = '選択文字列に mailto: を付加して開きます';
  // g_nIDFtpOpenURL
  MENU4_STRING            = 'ftp:// を付加して開く';
  MENU4_STATUSBAR_STRING  = '選択文字列に ftp:// を付加して開きます';
  // g_nIDExpOpenURL
  MENU5_STRING            = 'Explorer で開く';
  MENU5_STATUSBAR_STRING  = '選択文字列を Explorer で開きます';
  // g_nIDSearchURL
  MENU6_STRING            = ' で検索する';
  MENU6_STATUSBAR_STRING  = '選択文字列を検索します';
  BKC_PROPERTY            = $80A7;   { プロパティ   }
var
  MenuPos: Integer;
  hSubMenu: HMENU;
  buf: String;
begin
  case nType of
{   BKC_MENU_MAIN: ;      }
{   BKC_MENU_LISTVIEW: ;  }
{   BKC_MENU_TREEVIEW: ;  }
    BKC_MENU_MSGVIEW:
    begin
      { プロパティの前にメニューを入れる }
      for MenuPos:=0 to GetMenuItemCount(hTargetMenu) - 1 do
      begin
        if GetMenuItemID(hTargetMenu, MenuPos) = BKC_PROPERTY then
          break;
      end;
      hSubMenu := CreatePopupMenu;

      // Explorer
      g_nIDExpOpenURL := bka.RegisterCommand(MENU5_STATUSBAR_STRING, nType, @ProcOpenURL);
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_STRING, g_nIDExpOpenURL, MENU5_STRING);
      // SEPARATOR
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_SEPARATOR, 0, nil);
      // URL
      g_nIDOpenURL := bka.RegisterCommand(MENU1_STATUSBAR_STRING, nType, @ProcOpenURL);
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_STRING, g_nIDOpenURL, MENU1_STRING);
      // SEPARATOR
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_SEPARATOR, 0, nil);
      // Search
      g_nIDSearchURL := bka.RegisterCommand(MENU6_STATUSBAR_STRING, nType, @ProcOpenURL);
      buf:=SearchEngine1.Name+MENU6_STRING;
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_STRING, g_nIDSearchURL, PAnsiChar(buf));
      // SEPARATOR
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_SEPARATOR, 0, nil);
      // http://
      g_nIDHttpOpenURL := bka.RegisterCommand(MENU2_STATUSBAR_STRING, nType, @ProcOpenURL);
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_STRING, g_nIDHttpOpenURL, MENU2_STRING);
      // mailto:
      g_nIDMailtoOpenURL := bka.RegisterCommand(MENU3_STATUSBAR_STRING, nType, @ProcOpenURL);
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_STRING, g_nIDMailtoOpenURL, MENU3_STRING);
      // ftp://
      g_nIDFtpOpenURL := bka.RegisterCommand(MENU4_STATUSBAR_STRING, nType, @ProcOpenURL);
      AppendMenu(hSubMenu, MF_BYPOSITION or MF_STRING, g_nIDFtpOpenURL, MENU4_STRING);

      InsertMenu(hTargetMenu, MenuPos, MF_BYPOSITION or MF_SEPARATOR, 0, nil);
      InsertMenu(hTargetMenu, MenuPos, MF_BYPOSITION or MF_STRING or MF_POPUP, hSubMenu, MENU0_STRING);

    end;
{   BKC_MENU_MSGEDIT: ;   }
{   BKC_MENU_TASKTRAY: ;  }
{   BKC_MENU_COMPOSE: ;   }
{   BKC_MENU_COMPEDIT: ;  }
{   BKC_MENU_COMPREF: ;   }
    else ;
  end;
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when a folder is opened.
function BKC_OnOpenFolder(lpFolderID: PChar) : Integer; stdcall;
begin
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when a mail is selected.
function BKC_OnOpenMail(lpMailID : PChar) : Integer; stdcall;
begin
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called every minute.
function BKC_OnEveryMinute : Integer; stdcall;
begin
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when a compose windows is opened.
function BKC_OnOpenCompose(hTargetWnd : HWND; nMode : Integer(* See COMPOSE_MODE_* in BeckyApi.h *)) : Integer; stdcall;
begin
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when the composing message is saved.
function BKC_OnOutgoing(hTargetWnd : HWND; nMode : Integer(* 0:SaveToOutbox, 1:SaveToDraft, 2:SaveToReminder*))  : Integer; stdcall;
begin
  // Return -1 if you do not want to send it yet.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when a key is pressed.
function BKC_OnKeyDispatch(hTargetWnd : HWND; nKey : Integer(* key code *); nShift : Integer(* Shift state. 0x40:=Shift, 0x20:=Ctrl, 0x60:=Shift+Ctrl, 0xfe:=Alt*))  : Integer; stdcall;
begin
    // Return TRUE if you want to suppress subsequent command associated to this key.
    Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when a message is retrieved and saved to a folder
function BKC_OnRetrieve(lpMessage : PChar(* Message source*); lpMailID : PChar(* Mail ID*)) : Integer; stdcall;
begin
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when a message is spooled
function BKC_OnSend(lpMessage : PChar(* Message source *)) : Integer; stdcall;
begin
  // Return BKC_ONSEND_PROCESSED, if you have processed this message
  // and don't need Becky! to send it.
  // Becky! will move this message to Sent box when the sending
  // operation is done.
  // CAUTION: You are responsible for the destination of this
  // message if you return BKC_ONSEND_PROCESSED.

  // Return BKC_ONSEND_ERROR, if you want to cancel the sending operation.
  // You are responsible for displaying an error message.

  // Return 0 to proceed the sending operation.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when all messages are retrieved
function BKC_OnFinishRetrieve(nNumber : Integer(* Number of messages*)) : Integer; stdcall;
begin
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when plug-in setup is needed.
function BKC_OnPlugInSetup(hTargetWnd : HWND) : Integer; stdcall;
begin
  // Return nonzero if you have processed.
  // return 1;
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when plug-in information is being retrieved.
type
  tagBKPLUGININFO = record
    szPlugInName : array[0..80-1] of char; // Name of the plug-in
    szVendor : array[0..80-1] of char; // Name of the vendor
    szVersion : array[0..80-1] of char; // Version string
    szDescription : array[0..256-1] of char; // Short description about this plugin
  end;
  BKPLUGININFO = tagBKPLUGININFO;
  LPBKPLUGININFO = ^tagBKPLUGININFO;

function BKC_OnPlugInInfo(lpPlugInInfo : LPBKPLUGININFO) : Integer; stdcall;
begin
  (* You MUST specify at least szPlugInName and szVendor.
     otherwise Becky! will silently ignore your plug-in. *)
  StrCopy(lpPlugInInfo^.szPlugInName, 'BkOpenURL Plugin');
  StrCopy(lpPlugInInfo^.szVendor, 'Y.Takayanagi');
  StrCopy(lpPlugInInfo^.szVersion, PChar(Ver));
  StrCopy(lpPlugInInfo^.szDescription, 'OpenURLプラグインの改造版です。');
  // Always return 0.
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////
// Called when drag and drop operation occurs.
function BKC_OnDragDrop(lpTgt : PChar; lpSrc : PChar; nCount : Integer; dropEffect : Integer) : Integer; stdcall;
begin
  (*
  lpTgt:  A folder ID of the target folder.
          You can assume it is a root mailbox, if the string
          contains only one '\' character.
  lpSrc:  Either a folder ID or mail IDs. Multiple mail IDs are
          separated by #$0a.
          You can assume it is a folder ID, if the string
          doesn't contain '?' character.
  nCount: Number of items to be dropped.
          It can be more than one, if you drop mail items.
  dropEffect: Type of drag and drop operation
          1: Copy
          2: Move
          4: Link (Used for filtering setup in Becky!)
  *)
  // If you want to cancel the default drag and drop action,
  // return -1;
  // Do not assume the default action (copy, move, etc.) is always
  // processed, because other plug-ins might cancel the operation.
  Result := 0;
end;

exports
BKC_OnStart index 1,
BKC_OnExit index 2,
BKC_OnMenuInit index 3,
BKC_OnOpenFolder index 4,
BKC_OnOpenMail index 5,
BKC_OnEveryMinute index 6,
BKC_OnOpenCompose index 7,
BKC_OnOutgoing index 8,
BKC_OnKeyDispatch index 9,
BKC_OnRetrieve index 10,
BKC_OnSend index 11,
BKC_OnFinishRetrieve index 12,
BKC_OnPlugInSetup index 13,
BKC_OnPlugInInfo index 14,
BKC_OnDragDrop index 15;

begin
  if LibInit then
    ExitCode := 0  // succeeded
  else
    ExitCode := 1; // failed
  SaveExit := ExitProc;  // save original finalization procedure chain
  ExitProc := @LibExit;  // set new finalization procedure LibExit
end.
