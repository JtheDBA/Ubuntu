@FOR /F "delims=" %%G IN (updVM.txt) DO @(CALL :snapnupd "%%G")
@GOTO :eof

:snapnupd
@ECHO Updating: %1
%VB% snapshot %1 take "UPDATING" --description "Snapshot before applying updates"
%VB% startvm %1
@ECHO Were all updates successful (delete snapshot?)
@CHOICE /C YN
@IF %ERRORLEVEL% EQU 1 %VB% snapshot %1 delete "UPDATING"
