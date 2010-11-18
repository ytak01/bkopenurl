unit BeckyAPI;
(*
Becky! API class library for Delphi

This code is based on BeckyAPI.h and BeckyAPI.cpp in B2PinSDK-beta11.zip

COPYRIGHT NOTICE:
Copyright (c) 2000 All rights reserved.
Original C++ code was written by Tomohiro Norimatsu.
Translated to PASCAL for Borland Delphi(TM) by Ryota Ando.

You can freely use, modify, redistribute this source code unless you modify 
this notice. This software is provided by the author and contributors 'AS IS' 
and any express or implied warranties are disclaimed.
*)

interface

uses
  Windows, Sysutils, Classes;

//#include 'BeckyAPI.h'
const
BKC_MENU_MAIN     =  0;
BKC_MENU_LISTVIEW =  1;
BKC_MENU_TREEVIEW =  2;
BKC_MENU_MSGVIEW  =  3;
BKC_MENU_MSGEDIT  =  4;
BKC_MENU_TASKTRAY =  5;
BKC_MENU_COMPOSE  = 10;
BKC_MENU_COMPEDIT = 11;
BKC_MENU_COMPREF  = 12;

BKC_ONSEND_ERROR     = -1;
BKC_ONSEND_PROCESSED = -2;

MESSAGE_READ       = $00000001;
MESSAGE_FORWARDED  = $00000002;
MESSAGE_REPLIED    = $00000004;
MESSAGE_ATTACHMENT = $00000008;
MESSAGE_PARTIAL    = $00000100;
MESSAGE_REDIRECT   = $00000200;

COMPOSE_MODE_COMPOSE1 =  0;
COMPOSE_MODE_COMPOSE2 =  1;
COMPOSE_MODE_COMPOSE3 =  2;
COMPOSE_MODE_TEMPLATE =  3;
COMPOSE_MODE_REPLY1   =  5;
COMPOSE_MODE_REPLY2   =  6;
COMPOSE_MODE_REPLY3   =  7;
COMPOSE_MODE_FORWARD1 = 10;
COMPOSE_MODE_FORWARD2 = 11;
COMPOSE_MODE_FORWARD3 = 12;

BKMENU_CMDUI_DISABLED = 1;
BKMENU_CMDUI_CHECKED  = 2;

type
  PHWND = ^HWND;
  PBECKYCALLBACK = ^TBeckyCallBackFunc;
  TBeckyCallBackFunc = procedure(hTargetWnd : HWND; LPARAM : Longint);
  PBECKYUICALLBACK = ^TBeckyUICallBackFunc;
  TBeckyUICallBackFunc = function(hTargetWnd : HWND; LPARAM : Longint) : UINT;
  TBeckyConverter = function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
  TBeckyMIMEConverter = function(lpszOutFile : PChar; lpszInFile : PChar; bEncode : boolean) : boolean; stdcall;
  
  TBeckyAPI = class
  public
    GetVersion : function : PChar; stdcall;
    Command : procedure(hTargetWnd : HWND; lpCmd : PChar); stdcall;
    GetWindowHandles : function(lphMain : PHWND; lphTree : PHWND; lphList : PHWND; lphView : PHWND) : BOOL; stdcall;
    RegisterCommand : function(lpszComment : PChar; nTarget : Integer; lpCallback : PBECKYCALLBACK) : UINT; stdcall;
    RegisterUICallback : function(nID : UINT; lpCallback : PBECKYUICALLBACK) : UINT; stdcall;
    GetDataFolder : function : PChar; stdcall;
    GetTempFolder : function : PChar; stdcall;
    GetTempFileName : function(lpType : PChar) : PChar; stdcall;
    GetCurrentMailBox : function : PChar; stdcall;
    SetCurrentMailBox : procedure(lpMailBox : PChar); stdcall;
    GetCurrentFolder : function : PChar; stdcall;
    SetCurrentFolder : procedure(lpFolderID : PChar); stdcall;
    GetFolderDisplayName : function(lpFolderID : PChar) : PChar; stdcall;
    SetMessageText : procedure(hTargetWnd : HWND; lpszMsg : PChar); stdcall;
    GetCurrentMail : function : PChar; stdcall;
    SetCurrentMail : procedure(lpMailID : PChar); stdcall;
    GetNextMail : function(nStart : Integer; lpszMailID : PChar; nBuf : Integer; bSelected : BOOL) : Integer; stdcall;
    SetSel : procedure(lpMailID : PChar; bSel : BOOL); stdcall;
    AppendMessage : function(lpFolderID : PChar; lpszData : PChar) : BOOL; stdcall;
    MoveSelectedMessages : function(lpFolderID : PChar; bCopy : BOOL) : BOOL; stdcall;
    GetStatus : function(lpMailID : PChar) : DWORD; stdcall;
    SetStatus : function(lpMailID : PChar; dwSet : DWORD; dwReset : DWORD) : DWORD; stdcall;
    ComposeMail : function(lpURL : PChar) : HWND; stdcall;
    GetCharSet : function(lpMailID : PChar; lpszCharSet : PChar; nBuf : Integer) : Integer; stdcall;
    GetSource : function(lpMailID : PChar) : PChar; stdcall;
    SetSource : procedure(lpMailID : PChar; lpSource : PChar); stdcall;
    GetHeader : function(lpMailID : PChar) : PChar; stdcall;
    GetText : function(lpszMimeType : PChar; nBuf : Integer) : PChar; stdcall;
    SetText : procedure(nMode : Integer; lpText : PChar); stdcall;
    GetSpecifiedHeader : procedure(lpHeader : PChar; lpszData : PChar; nBuf : Integer); stdcall;
    SetSpecifiedHeader : procedure(lpHeader : PChar; lpszData : PChar); stdcall;
    CompGetCharSet : function(hTargetWnd : HWND; lpszCharSet : PChar; nBuf : Integer) : Integer; stdcall;
    CompGetSource : function(hTargetWnd : HWND) : PChar; stdcall;
    CompSetSource : procedure(hTargetWnd : HWND; lpSource : PChar); stdcall;
    CompGetHeader : function(hTargetWnd : HWND) : PChar; stdcall;
    CompGetSpecifiedHeader : procedure(hTargetWnd : HWND; lpHeader : PChar; lpszData : PChar; nBuf : Integer); stdcall;
    CompSetSpecifiedHeader : procedure(hTargetWnd : HWND; lpHeader : PChar; lpszData : PChar); stdcall;
    CompGetText : function(hTargetWnd : HWND; lpszMimeType : PChar; nBuf : Integer) : PChar; stdcall;
    CompSetText : procedure(hTargetWnd : HWND; nMode : Integer; lpText : PChar); stdcall;
    CompAttachFile : procedure(hTargetWnd : HWND; lpAttachFile : PChar; lpMimeType : PChar); stdcall;
    Alloc : function(dwSize : DWORD) : Pointer; stdcall;
    ReAlloc : function(lpVoid : Pointer; dwSize : DWORD) : Pointer; stdcall;
    Free : procedure(lpVoid : Pointer); stdcall;
    ISO_2022_JP : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    ISO_2022_KR : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    HZ_GB2312 : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    ISO_8859_2 : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    EUC_JP : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    UTF_7 : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    UTF_8 : function(lpSrc : PChar; bEncode : boolean) : PChar; stdcall;
    B64Convert : function(lpszOutFile : PChar; lpszInFile : PChar; bEncode : boolean) : boolean; stdcall;
    QPConvert : function(lpszOutFile : PChar; lpszInFile : PChar; bEncode : boolean) : boolean; stdcall;
    MIMEHeader : function(lpszIn : PChar; lpszCharSet : PChar; nBuf : Integer; bEncode : boolean) : PChar; stdcall;
    SerializeRcpts : function(lpAddresses : PChar) : PChar; stdcall;
    Connect : function(bConnect : boolean) : boolean; stdcall;
    constructor Create;
    destructor Destroy; override;
    function InitAPI : boolean;
  protected
    m_hInstBecky : THandle;
  end;

implementation

constructor TBeckyAPI.Create;
begin
  m_hInstBecky := 0;
end;

destructor TBeckyAPI.Destroy;
begin
  if m_hInstBecky <> 0 then
  begin
    //FreeLibrary(m_hInstBecky);
  end;
  inherited Destroy;
end;

function TBeckyAPI.InitAPI : Boolean;
var
  bRet : boolean;
  lpVer : PChar;
begin
  if m_hInstBecky <> 0 then
  begin
    Result := TRUE;
    exit;
  end;

  bRet := FALSE;
  repeat
    m_hInstBecky := GetModuleHandle(nil);
    if  m_hInstBecky < HINSTANCE_ERROR then
    begin
      m_hInstBecky := 0;
      Result := FALSE;
      exit;
    end;
    @GetVersion := GetProcAddress(m_hInstBecky, 'BKA_GetVersion');
    if @GetVersion = nil then break;
    @Command := GetProcAddress(m_hInstBecky, 'BKA_Command');
    if @Command = nil then break;
    @GetWindowHandles := GetProcAddress(m_hInstBecky, 'BKA_GetWindowHandles');
    if @GetWindowHandles = nil then break;
    @RegisterCommand := GetProcAddress(m_hInstBecky, 'BKA_RegisterCommand');
    if @RegisterCommand = nil then break;
    @RegisterUICallback := GetProcAddress(m_hInstBecky, 'BKA_RegisterUICallback');
    if @RegisterUICallback = nil then break;
    @GetDataFolder := GetProcAddress(m_hInstBecky, 'BKA_GetDataFolder');
    if @GetDataFolder = nil then break;
    @GetTempFolder := GetProcAddress(m_hInstBecky, 'BKA_GetTempFolder');
    if @GetTempFolder = nil then break;
    @GetTempFileName := GetProcAddress(m_hInstBecky, 'BKA_GetTempFileName');
    if @GetTempFileName = nil then break;
    @GetCurrentMailBox := GetProcAddress(m_hInstBecky, 'BKA_GetCurrentMailBox');
    if @GetCurrentMailBox = nil then break;
    @SetCurrentMailBox := GetProcAddress(m_hInstBecky, 'BKA_SetCurrentMailBox');
    if @SetCurrentMailBox = nil then break;
    @GetCurrentFolder := GetProcAddress(m_hInstBecky, 'BKA_GetCurrentFolder');
    if @GetCurrentFolder = nil then break;
    @SetCurrentFolder := GetProcAddress(m_hInstBecky, 'BKA_SetCurrentFolder');
    if @SetCurrentFolder = nil then break;
    @GetFolderDisplayName := GetProcAddress(m_hInstBecky, 'BKA_GetFolderDisplayName');
    if @GetFolderDisplayName = nil then break;
    @SetMessageText := GetProcAddress(m_hInstBecky, 'BKA_SetMessageText');
    if @SetMessageText = nil then break;
    @GetCurrentMail := GetProcAddress(m_hInstBecky, 'BKA_GetCurrentMail');
    if @GetCurrentMail = nil then break;
    @SetCurrentMail := GetProcAddress(m_hInstBecky, 'BKA_SetCurrentMail');
    if @SetCurrentMail = nil then break;
    @GetNextMail := GetProcAddress(m_hInstBecky, 'BKA_GetNextMail');
    if @GetNextMail = nil then break;
    @SetSel := GetProcAddress(m_hInstBecky, 'BKA_SetSel');
    if @SetSel = nil then break;
    @AppendMessage := GetProcAddress(m_hInstBecky, 'BKA_AppendMessage');
    if @AppendMessage = nil then break;
    @MoveSelectedMessages := GetProcAddress(m_hInstBecky, 'BKA_MoveSelectedMessages');
    if @MoveSelectedMessages = nil then break;
    @GetStatus := GetProcAddress(m_hInstBecky, 'BKA_GetStatus');
    if @GetStatus = nil then break;
    @ComposeMail := GetProcAddress(m_hInstBecky, 'BKA_ComposeMail');
    if @ComposeMail = nil then break;
    @GetCharSet := GetProcAddress(m_hInstBecky, 'BKA_GetCharSet');
    if @GetCharSet = nil then break;
    @GetSource := GetProcAddress(m_hInstBecky, 'BKA_GetSource');
    if @GetSource = nil then break;
    @SetSource := GetProcAddress(m_hInstBecky, 'BKA_SetSource');
    if @SetSource = nil then break;
    @GetHeader := GetProcAddress(m_hInstBecky, 'BKA_GetHeader');
    if @GetHeader = nil then break;
    @GetText := GetProcAddress(m_hInstBecky, 'BKA_GetText');
    if @GetText = nil then break;
    @SetText := GetProcAddress(m_hInstBecky, 'BKA_SetText');
    if @SetText = nil then break;
    @GetSpecifiedHeader := GetProcAddress(m_hInstBecky, 'BKA_GetSpecifiedHeader');
    if @GetSpecifiedHeader = nil then break;
    @SetSpecifiedHeader := GetProcAddress(m_hInstBecky, 'BKA_SetSpecifiedHeader');
    if @SetSpecifiedHeader = nil then break;
    @CompGetCharSet := GetProcAddress(m_hInstBecky, 'BKA_CompGetCharSet');
    if @CompGetCharSet = nil then break;
    @CompGetSource := GetProcAddress(m_hInstBecky, 'BKA_CompGetSource');
    if @CompGetSource = nil then break;
    @CompSetSource := GetProcAddress(m_hInstBecky, 'BKA_CompSetSource');
    if @CompSetSource = nil then break;
    @CompGetHeader := GetProcAddress(m_hInstBecky, 'BKA_CompGetHeader');
    if @CompGetHeader = nil then break;
    @CompGetSpecifiedHeader := GetProcAddress(m_hInstBecky, 'BKA_CompGetSpecifiedHeader');
    if @CompGetSpecifiedHeader = nil then break;
    @CompSetSpecifiedHeader := GetProcAddress(m_hInstBecky, 'BKA_CompSetSpecifiedHeader');
    if @CompSetSpecifiedHeader = nil then break;
    @CompGetText := GetProcAddress(m_hInstBecky, 'BKA_CompGetText');
    if @CompGetText = nil then break;
    @CompSetText := GetProcAddress(m_hInstBecky, 'BKA_CompSetText');
    if @CompSetText = nil then break;
    @CompAttachFile := GetProcAddress(m_hInstBecky, 'BKA_CompAttachFile');
    if @CompAttachFile = nil then break;
    @Alloc := GetProcAddress(m_hInstBecky, 'BKA_Alloc');
    if @Alloc = nil then break;
    @ReAlloc := GetProcAddress(m_hInstBecky, 'BKA_ReAlloc');
    if @ReAlloc = nil then break;
    @Free := GetProcAddress(m_hInstBecky, 'BKA_Free');
    if @Free = nil then break;
    @ISO_2022_JP := GetProcAddress(m_hInstBecky, 'BKA_ISO_2022_JP');
    if @ISO_2022_JP = nil then break;
    @ISO_2022_KR := GetProcAddress(m_hInstBecky, 'BKA_ISO_2022_KR');
    if @ISO_2022_KR = nil then break;
    @HZ_GB2312 := GetProcAddress(m_hInstBecky, 'BKA_HZ_GB2312');
    if @HZ_GB2312 = nil then break;
    @ISO_8859_2 := GetProcAddress(m_hInstBecky, 'BKA_ISO_8859_2');
    if @ISO_8859_2 = nil then break;
    @EUC_JP := GetProcAddress(m_hInstBecky, 'BKA_EUC_JP');
    if @EUC_JP = nil then break;
    @UTF_7 := GetProcAddress(m_hInstBecky, 'BKA_UTF_7');
    if @UTF_7 = nil then break;
    @UTF_8 := GetProcAddress(m_hInstBecky, 'BKA_UTF_8');
    if @UTF_8 = nil then break;
    @B64Convert := GetProcAddress(m_hInstBecky, 'BKA_B64Convert');
    if @B64Convert = nil then break;
    @QPConvert := GetProcAddress(m_hInstBecky, 'BKA_QPConvert');
    if @QPConvert = nil then break;
    @MIMEHeader := GetProcAddress(m_hInstBecky, 'BKA_MIMEHeader');
    if @MIMEHeader = nil then break;
    @SerializeRcpts := GetProcAddress(m_hInstBecky, 'BKA_SerializeRcpts');
    if @SerializeRcpts = nil then break;
    @Connect := GetProcAddress(m_hInstBecky, 'BKA_Connect');
    if @Connect = nil then break;

    // v2.00.06 or higher
    @SetStatus := GetProcAddress(m_hInstBecky, 'BKA_SetStatus');
//LPCTSTR lpVer = GetVersion();
    lpVer := GetVersion;
//if (lstrlen(lpVer) > 7 || lstrcmp(lpVer, "2.00.06") >= 0) {
    if (StrLen(lpVer) > 7) or (CompareText(lpVer, '2.00.06') >= 0) then
    begin
      if @SetStatus = nil then break;
    end
    else
    begin
      // Still works if the plugin doesn't use "SetStatus" API.
    end;

    bRet := TRUE;
  until true;
  if not bRet then
  begin
    m_hInstBecky := 0;
  end;
  Result := bRet;
end;

end.