set CURRENT_BATCH_DIR=%~dp0%
cd /D %CURRENT_BATCH_DIR%
powershell -executionpolicy bypass -File .\get_cygwin_installer.ps1
setup-x86_64.exe^
 -R %CURRENT_BATCH_DIR%..^
 -P packageList.txt^
 -C categoryList.txt^
 -a x86_64^
 -W^
 -q^
 -l %CURRENT_BATCH_DIR%^
 -n^
 -d^
 -g^
 -o^
 -A^
 -Y

..\bin\bash -c "export PATH=$PATH:../bin; echo PATH=$PATH"
..\bin\bash -c "export PATH=$PATH:../bin; chmod ug+rx ./dump_installed_packages.sh"
..\bin\bash -c "export PATH=$PATH:../bin; ./dump_installed_packages.sh"
