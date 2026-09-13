#define AppName "File Peek"
#define AppPublisher "Kutlwano P. Maruatona"
#define AppVersion GetEnv("APP_VERSION")
#define ReleaseTag GetEnv("RELEASE_TAG")
#define SourceDir GetEnv("BUILD_DIR")
#define OutputDir GetEnv("OUT_DIR")

[Setup]
AppId={{B8E5E7E4-8E4B-4D6E-9D1D-2D4E7E6C8F91}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/kutlwano-drew
AppSupportURL=https://github.com/kutlwano-drew
AppUpdatesURL=https://github.com/kutlwano-drew
DefaultDirName={autopf}\File Peek
DefaultGroupName=File Peek
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=File-Peek-Setup-{#ReleaseTag}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
UninstallDisplayName=File Peek
Uninstallable=yes
SetupIconFile=..\..\windows\runner\resources\app_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\File Peek"; Filename: "{app}\file_peek.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\File Peek"; Filename: "{app}\file_peek.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\file_peek.exe"; Description: "Launch File Peek"; Flags: nowait postinstall skipifsilent