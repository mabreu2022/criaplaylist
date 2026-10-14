; Script de Instalacao Inno Setup 6 para CriaPlaylist
; Gerador de Playlists e Rotacoes para ZaraRadio

#define MyAppName "CriaPlaylist"
#define MyAppFullName "CriaPlaylist - Gerador de Playlists ZaraRadio"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "mabreu2022"
#define MyAppURL "https://github.com/mabreu2022/criaplaylist"
#define MyAppExeName "CriaPlaylist.exe"

[Setup]
AppId={{9F85B242-4A73-41BE-B29C-A89E62C1802E}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppFullName}
AllowNoIcons=yes
OutputDir=installer_output
OutputBaseFilename=Instalador_CriaPlaylist_v1.0.0
SetupIconFile=app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=auto

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "Project1.exe"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Flags: ignoreversion
Source: "app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "vu_meter\*"; DestDir: "{app}\vu_meter"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppFullName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppFullName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\app_icon.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
