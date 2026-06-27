' Launch clip-watch.ps1 fully hidden (no console flash).
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
script = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), "clip-watch.ps1")
sh.Run "powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File """ & script & """", 0, False
