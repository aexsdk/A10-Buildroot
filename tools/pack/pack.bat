@echo off
set /p stroagef=�̼����� 1:nand 2:sdcard 
set /p ostype=ϵͳ���� 1:linux 2:crane 
set /p boardtype=Ŀ����ͺ� 1:evb1.1 2:evb1.2A 3:evb1.2B

if %stroagef%==2 goto stroageset0
set stroage=nand
goto stroageset1
:stroageset0
set stroage=sdcard
:stroageset1
if %ostype%==2 goto osset0
set os=linux
goto osset1
:osset0
set os=crane
:osset1
if %boardtype%==3 goto boardset1
if %boardtype%==2 goto boardset0
set board=evb1.1
goto boardset2
:boardset0
set board=evb1.2A
goto boardset2
:boardset1
set board=evb1.2B
:boardset2

echo %board%
echo %os%
echo %stroage%
pause
set TOOLS_DIR=%CD%\pctools\windows
set PATH=%TOOLS_DIR%\mod_update;%TOOLS_DIR%\fsbuild200;%TOOLS_DIR%\edragonex200;%PATH%

echo %TOOLS_DIR%
echo %PATH%

if exist out (
    echo Delete old out dir , and create it again
    rmdir /s /q out
    mkdir out out\bootfs
) else (
    echo Create out dir
    mkdir out out\bootfs
)

copy eFex\sys_config_%os%.fex out\sys_config.fex
copy eFex\sys_config1_%board%.fex out\sys_config1.fex
copy eFex\card\mbr.fex out
copy eFex\split_xxxx.fex out
copy eGon\storage_media\nand\boot0.bin out
copy eGon\storage_media\nand\boot1.bin out
copy eGon\storage_media\sdcard\boot0.bin out\card_boot0.fex
copy eGon\storage_media\sdcard\boot1.bin out\card_boot1.fex
copy wboot\bootfs.ini out
copy wboot\image_%os%.cfg out\image.cfg 
copy wboot\rootfs.fex out
copy wboot\diskfs.fex out
xcopy /q /e wboot\bootfs\* out\bootfs\


cd out
set IMG_NAME="%os%-%board%-%stroage%.img"
echo imagename = %IMG_NAME% >> image.cfg

script_old.exe  sys_config.fex
script.exe sys_config1.fex
update_23.exe sys_config1.bin boot0.bin boot1.bin
update_23.exe sys_config1.bin card_boot0.fex card_boot0.fex SDMMC_CARD
copy sys_config1.bin bootfs\script.bin
copy sys_config1.bin bootfs\script0.bin
update_mbr.exe sys_config.bin mbr.fex
fsbuild.exe "%CD%\bootfs.ini" "%CD%\split_xxxx.fex"
compile.exe -o image.bin image.cfg
dragon.exe image.cfg 


cd ..

echo.
echo Pack Done!!!
echo.

pause

