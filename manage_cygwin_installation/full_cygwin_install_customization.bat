REM Use this batch file when you want to customize everything about the install process.  Use of other scripts will use mirror settings made here.

set CURRENT_BATCH_DIR=%~dp0%
cd /D %CURRENT_BATCH_DIR%
powershell -executionpolicy bypass -File .\get_cygwin_installer.ps1

..\bin\bash -c "export PATH=$PATH:../bin; chmod ug+rx ./create_variable_files_for_cygwin_setup.sh; ./create_variable_files_for_cygwin_setup.sh"

set /p myPackages= < %CURRENT_BATCH_DIR%myPackagesVariable.txt

setup-x86_64.exe^
 -R %CURRENT_BATCH_DIR%..^
 -P %myPackages%^
 -a x86_64^
 -W^
 -l %CURRENT_BATCH_DIR%^
 -n^
 -d^
 -g^
 -o^
 -A^
 -K http://cygwinports.org/ports.gpg
 
..\bin\bash -c "export PATH=$PATH:../bin; chmod ug+rx ./dump_installed_packages.sh; ./dump_installed_packages.sh"
