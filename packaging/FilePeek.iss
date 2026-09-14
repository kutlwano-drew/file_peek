#define MyAppName "File Peek"
#define MyAppPublisher "Kutlwano P. Maruatona"
#define MyAppURL "https://github.com/kutlwano-drew/file_peek"
#define MyAppExeName "file_peek.exe"

[Setup]
AppId={{9E0D5A5D-0D1D-4E2E-9A3A-8B5A0E5F2C71}
AppName={#MyAppName}
AppVersion=1.0.0
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}/releases

DefaultDirName={autopf}\File Peek
DefaultGroupName={#MyAppName}

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

DisableProgramGroupPage=yes

UninstallDisplayIcon={app}\{#MyAppExeName}

Compression=lzma2
SolidCompression=yes
WizardStyle=modern

OutputDir=..\..\dist\windows
OutputBaseFilename=File-Peek-1.0.0-windows-x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\File Peek"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\File Peek"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch File Peek"; Flags: nowait postinstall skipifsilent