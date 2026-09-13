#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif

#ifndef BuildDir
#define BuildDir "..\..\build\windows\x64\runner\Release"
#endif

#ifndef OutputDir
#define OutputDir "..\..\dist\windows"
#endif

#define MyAppName "File Peek"
#define MyAppExeName "file_peek.exe"
#define MyAppPublisher "Kutlwano P. Maruatona"
#define MyAppURL "https://github.com/kutlwano-drew/file_peek"

[Setup]
AppId={{9E0D5A5D-0D1D-4E2E-9A3A-8B5A0E5F2C71}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
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

OutputDir={#OutputDir}
OutputBaseFilename=File-Peek-{#MyAppVersion}-windows-x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent