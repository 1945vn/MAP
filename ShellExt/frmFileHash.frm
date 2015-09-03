VERSION 5.00
Begin VB.Form frmFileHash 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "File Hash"
   ClientHeight    =   1710
   ClientLeft      =   45
   ClientTop       =   615
   ClientWidth     =   6270
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1710
   ScaleWidth      =   6270
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox pictIcon 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   675
      Left            =   5580
      ScaleHeight     =   675
      ScaleWidth      =   675
      TabIndex        =   5
      Top             =   0
      Visible         =   0   'False
      Width           =   675
   End
   Begin VB.Frame fraLower 
      BorderStyle     =   0  'None
      Height          =   435
      Left            =   60
      TabIndex        =   1
      Top             =   1260
      Width           =   5835
      Begin VB.CommandButton cmdCopyHash 
         Caption         =   "Copy Hash"
         Height          =   345
         Left            =   3060
         TabIndex        =   3
         Top             =   0
         Width           =   1125
      End
      Begin VB.CommandButton cmdCopyAll 
         Caption         =   "Copy All"
         Height          =   345
         Left            =   4560
         TabIndex        =   2
         Top             =   0
         Width           =   1215
      End
      Begin VB.Label lblMore 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BorderStyle     =   1  'Fixed Single
         Caption         =   "More"
         ForeColor       =   &H80000008&
         Height          =   255
         Left            =   60
         TabIndex        =   4
         Top             =   60
         Width           =   615
      End
   End
   Begin VB.TextBox Text1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1065
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   5775
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Begin VB.Menu mnuNameMD5 
         Caption         =   "Rename to MD5"
      End
      Begin VB.Menu mnuStrings 
         Caption         =   "Strings"
      End
      Begin VB.Menu mnuFileProps 
         Caption         =   "File Properties"
      End
      Begin VB.Menu mnuOffsetCalc 
         Caption         =   "Offset Calculator"
      End
      Begin VB.Menu mnuSpacer 
         Caption         =   "-"
      End
      Begin VB.Menu mnuVt 
         Caption         =   "Virus Total"
      End
      Begin VB.Menu mnuSubmitToVT 
         Caption         =   "Submit To VirusTotal"
      End
      Begin VB.Menu mnuSpacer2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuExternal 
         Caption         =   "External"
         Begin VB.Menu mnuKryptoAnalyzer 
            Caption         =   "Krypto Analyzer"
         End
         Begin VB.Menu mnuSearchFileName 
            Caption         =   "Google File Name"
         End
         Begin VB.Menu mnuSearchHash 
            Caption         =   "Google File MD5"
         End
         Begin VB.Menu mnuExt 
            Caption         =   "Edit Cfg"
            Index           =   0
         End
         Begin VB.Menu mnuExt 
            Caption         =   "-"
            Index           =   1
         End
      End
   End
End
Attribute VB_Name = "frmFileHash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim myMd5 As String
Dim LoadedFile As String
Dim isPE As Boolean
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long
Private Declare Function ExtractIcon Lib "shell32.dll" Alias "ExtractIconA" (ByVal hInst As Long, ByVal lpszExeFileName As String, ByVal nIconIndex As Long) As Long
Private Declare Function DrawIcon Lib "user32" (ByVal hDC As Long, ByVal x As Long, ByVal Y As Long, ByVal hIcon As Long) As Long

Function ShowIcon(ByVal fileName As String, ByVal hDC As Long, Optional ByVal iconIndex As Long = 0, Optional ByVal x As Long = 0, Optional ByVal Y As Long = 0) As Boolean
    Dim hIcon As Long
    hIcon = ExtractIcon(App.hInstance, fileName, iconIndex)

    If hIcon Then
        DrawIcon hDC, x, Y, hIcon
        ShowIcon = True
    End If
    
End Function

Sub ShowFileStats(fPath As String)
    
    On Error Resume Next
    Dim ret() As String
    Dim istype As Boolean
    Dim compiled As String
    Dim fs As Long, sz As Long
    Dim fname As String
    Dim mySHA As String
    Dim Sections As String
    Dim pe As New CPEEditor
    
    LoadedFile = fPath
    fs = DisableRedir()
    myMd5 = hash.HashFile(fPath)
    
    If myMd5 = fso.FileNameFromPath(fPath) Then
        mnuNameMD5.enabled = False
    End If
    
    'mySHA = hash.HashFile(fpath, SHA, HexFormat)
    sz = FileLen(fPath)
    RevertRedir fs
    
    fname = fso.FileNameFromPath(fPath)
    If Len(fname) > 50 Then
        fname = GetShortName(fPath)
        fname = fso.FileNameFromPath(fname)
    End If
    
    If LCase(fname) <> LCase(myMd5) Then
        push ret(), rpad("File:") & fname
    End If
    
    push ret(), rpad("Size:") & sz
    push ret(), rpad("MD5:") & myMd5
    'push ret(), rpad("SHA:") & mySHA
    
    compiled = GetCompileDateOrType(fPath, istype, isPE)
    push ret(), IIf(istype, rpad("FileType: "), rpad("Compiled:")) & compiled
    
    If isPE Then
        
        'If pe.LoadFile(fPath, Sections) Then 'little wasteful to load the pe twice (compile date 1st) but managable..
        '    If Len(Sections) > 0 Then push ret(), "Sections: " & Sections
        'End If
        
        Dim fp As FILEPROPERTIE
        fp = FileProps.FileInfo(fPath) 'should we include more here? we need a config pane now :(
        If Len(fp.FileVersion) > 0 Then
            push ret(), rpad("Version:") & fp.FileVersion
        End If
        
    End If
        
    Dim v As SigResults
    Dim subject As String, issuer As String
    v = VerifyFileSignature(fPath)
    If isSigned(v) Then
        push ret(), rpad("Signature ") & SigToStr(v)
        If GetSigner(fPath, issuer, subject) Then
            If Len(subject) > 0 Then push ret(), rpad("Subject:") & subject
            If Len(issuer) > 0 Then push ret(), rpad("Issuer:") & issuer
        End If
    End If
              
    mnuFileProps.enabled = isPE
    mnuOffsetCalc.enabled = isPE
    
    Text1 = Join(ret, vbCrLf)
    
    Font = Text1.Font
    Text1.Height = TextHeight(Text1.Text) + 200
    Text1.Width = TextWidth(Text1.Text) + 200
    Me.Height = Text1.Top + Text1.Height + fraLower.Height + 400
    Me.Width = Text1.Width + Text1.Left + 400
    fraLower.Top = Me.Height - fraLower.Height - 400
    
    If ShowIcon(fPath, pictIcon.hDC) Then
        'Me.Width = Me.Width + pictIcon.Width '+ 50
        pictIcon.Left = Me.Width - pictIcon.Width
        pictIcon.Visible = True
    End If
    
    Dim minWidth  As Long
    minWidth = fraLower.Width + fraLower.Left + 300
    If Me.Width < minWidth Then Me.Width = minWidth
    
    Me.Show '1 why was using a modal show? any reason?? made popup menus on subforms not show up..
        
End Sub

Private Sub cmdCopyAll_Click()
    Clipboard.Clear
    Clipboard.SetText Text1
    Unload Me
    End
End Sub

Private Sub cmdCopyHash_Click()
    Clipboard.Clear
    Clipboard.SetText myMd5
    Unload Me
    End
End Sub

Private Sub cmdVT_Click()
    On Error Resume Next
    Dim vt As String
    vt = App.path & IIf(IsIde(), "\..\", "") & "\virustotal.exe"
    If Not fso.FileExists(vt) Then
        MsgBox "VirusTotal app not found?: " & vt, vbInformation
        Exit Sub
    End If
    'Shell vt & " /hash " & myMd5
    Shell vt & " " & LoadedFile 'so submit button is active..
End Sub

Private Sub Form_Load()
    
    mnuPopup.Visible = False 'IsIde()
    pictIcon.BackColor = &H8000000F
    
    Me.Icon = myIcon
    
    Dim ext As String
    ext = App.path & IIf(IsIde(), "\..\", "") & "\shellext.external.txt"
    If fso.FileExists(ext) Then
        ext = fso.ReadFile(ext)
        tmp = Split(ext, vbCrLf)
        For Each x In tmp
            AddExternal CStr(x)
        Next
    End If
    
End Sub

Private Sub lblMore_Click()
    PopupMenu mnuPopup
End Sub

Private Sub mnuExt_Click(index As Integer)
    On Error GoTo hell
    Dim cmd As String
    
    If index = 0 Then
        cmd = App.path & IIf(IsIde(), "\..\", "") & "\shellext.external.txt"
        Shell "notepad.exe " & GetShortName(cmd), vbNormalFocus
    Else
        cmd = mnuExt(index).Tag
        cmd = Replace(cmd, "%1", GetShortName(LoadedFile))
        cmd = Replace(cmd, "%app_path%", App.path & IIf(IsIde(), "\..\", "\"))
        Shell cmd, vbNormalFocus
    End If
    
    Exit Sub
hell:
    MsgBox "Error launching program cmdline: " & vbCrLf & vbCrLf & cmd, vbInformation
        
End Sub

Private Sub mnuFileProps_Click()
    On Error Resume Next
    Dim fs As Long, f As String
    fs = DisableRedir()
    tmp = FileProps.QuickInfo(LoadedFile)
    RevertRedir fs
    If Len(tmp) = 0 Then Exit Sub
    f = fso.GetFreeFileName(Environ("temp"))
    fso.WriteFile f, vbCrLf & vbCrLf & tmp
    Shell "notepad.exe """ & f & """", vbNormalFocus
End Sub

Private Sub mnuKryptoAnalyzer_Click()
    LaunchPeidPlugin "kanal.dll", LoadedFile
End Sub

Private Sub mnuNameMD5_Click()
    On Error Resume Next
    Dim fNew As String
    fNew = fso.GetParentFolder(LoadedFile) & "\" & myMd5
    If fso.FileExists(fNew) Then
        MsgBox "A file named the md5 already exists in the target directory", vbExclamation
        Exit Sub
    End If
    Name LoadedFile As fNew
    If Err.Number = 0 Then
        LoadedFile = fNew
        ShowFileStats fNew
    Else
        MsgBox "Error renaming file: " & Err.Description
    End If
End Sub

Private Sub mnuOffsetCalc_Click()
    On Error Resume Next
    Dim pe As New CPEEditor
    If pe.LoadFile(LoadedFile) Then
        frmOffsets.Initilize pe
    End If
End Sub

Private Sub mnuSearchFileName_Click()
    Dim f As String
    f = fso.FileNameFromPath(LoadedFile)
    Google f, Me.hwnd
End Sub

Private Sub mnuSearchHash_Click()
    Google myMd5, Me.hwnd
End Sub

Private Sub mnuStrings_Click()
    On Error Resume Next
    exe = App.path & IIf(IsIde(), "\..\", "") & "\shellext.exe"
    Shell exe & " """ & LoadedFile & """ /peek"
End Sub

Private Sub mnuSubmitToVT_Click()
    On Error Resume Next
    Dim vt As String
    vt = App.path & IIf(IsIde(), "\..\", "") & "\virustotal.exe"
    If Not fso.FileExists(vt) Then
        MsgBox "VirusTotal app not found?: " & vt, vbInformation
        Exit Sub
    End If
    Shell vt & " /submit " & LoadedFile
End Sub

Private Sub mnuVt_Click()
    cmdVT_Click
End Sub

Sub AddExternal(cmd As String)
     
    Dim i As Integer
    cmd = Trim(cmd)
    If Len(cmd) = 0 Then Exit Sub
    If VBA.Left(cmd, 1) = "#" Then Exit Sub
    
    tmp = Split(cmd, "=", 2)
    
    If UBound(tmp) <> 1 Then
        MsgBox "Invalid external menu entry. format is menu_text=command_line" & vbCrLf & vbCrLf & cmd
        Exit Sub
    End If
    
    i = mnuExt.Count
    Load mnuExt(i)
    mnuExt(i).Caption = Trim(tmp(0))
    mnuExt(i).Visible = True
    mnuExt(i).Tag = Trim(tmp(1))
    
End Sub
