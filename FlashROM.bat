@ECHO OFF
setlocal enabledelayedexpansion



REM ���û���
set "right_device=��Ļ���"



set "fastboot=%cd%\bin\fastboot"
set e="%cd%\bin\cho"
set "zstd=%cd%\bin\zstd"
set sg=1^>nul 2^>nul

for /f "tokens=2 delims=:" %%a in ('chcp') do set "locale=%%a"

:HOME
cls

if "!locale!"==" 936" (
    set "title=Fastboot ˢ�빤��"
    set "one_title={F9}            Powered By {F0}Garden Of Joy            {#}{#}{\n}"
    set "keep_data_flash={04}[1] {01}����ȫ�����ݲ�ˢ��{#}{#}{\n}"
    set "format_data_flash={04}[2] {01}��ʽ���û����ݲ�ˢ��{#}{#}{\n}"
    set "select_project=��ѡ����Ҫ��������Ŀ��"
    set "waiting_device={0D}��������  ���ڵȴ��豸  ��������{#}{\n}{\n}"
    set "loaded_device=�Ѽ����豸��"
    set "detected_compressed_file=��⵽ѹ���ļ������ڽ�ѹ��"
    set "disabled_avb_verification=�ѽ��� Avb2.0 У��"
    set "kept_data_reboot=�ѱ���ȫ�����ݣ�׼��������"
    set "formatting_data=���ڸ�ʽ�� DATA"
    set "execution_completed=ִ����ɣ��ȴ��Զ�����"
    set "retry_message=����..."
    set "success_status=ˢ��ɹ�"
    set "failure_status=ˢ��ʧ��"
    set "device_mismatch_msg=�� ROM ������ !right_device! ��������豸�� !DeviceCode!"
) else (
    set "title=Fastboot Flash Tool"
    set "one_title={F9}            Powered By {F0}Garden Of Joy            {#}{#}{\n}"
    set "keep_data_flash={04}[1]  {01}Keep all data and flash{#}{#}{\n}"
    set "format_data_flash={04}[2]  {01}Format user data and flash{#}{#}{\n}"
    set "select_project=Please select the project you want to operate:"
    set "waiting_device={0D}��������  Waiting for device  ��������{#}{\n}{\n}"
    set "loaded_device=Loaded device: "
    set "detected_compressed_file=Detected compressed file, decompressing: "
    set "disabled_avb_verification=Disabled Avb2.0 verification"
    set "kept_data_reboot=Kept all data, preparing to reboot��"
    set "formatting_data=Formatting DATA"
    set "execution_completed=Execution completed, waiting for automatic reboot"
    set "retry_message=Retrying..."
    set "success_status=Flash successful"
    set "failure_status=Flash failed"
    set "device_mismatch_msg=This ROM is only compatible with !right_device!, but your device is !DeviceCode!"
)

title !title!
:HOME
cls

REM ����Ƿ���� .zst �ļ�
set "zst_exist="
for %%a in (images\*.zst) do set "zst_exist=1"
if defined zst_exist (
    for /f "delims=" %%a in ('dir /b "images\*.zst"') do (
        if exist "images\%%~nxa" (
            echo !detected_compressed_file!%%~na
            "!zstd!" --rm -d images\%%~nxa -o images\%%~na
        )
    )
	echo.
)

%e% {F9}                                                {\n}
%e% !one_title!
%e% {F9}                                                {\n}{\n}
%e% !keep_data_flash!
%e% !format_data_flash!
ECHO.

set /p zyxz=!select_project!
if "!zyxz!" == "1" (
    set xz=1
    goto FLASH
) else if "!zyxz!" == "2" (
    set xz=2
    goto FLASH
)
goto HOME&pause

:FLASH
cls 

REM ��ʾ�ȴ��豸����Ϣ
%e% !waiting_device!

REM ��ȡ�豸�ͺ�
for /f "tokens=2" %%a in ('!fastboot! getvar product 2^>^&1^|find "product"') do (
    set DeviceCode=%%a
)
REM ��ȡ�豸�ķ�������
for /f "tokens=2" %%a in ('!fastboot! getvar slot-count 2^>^&1^|find "slot-count" ') do (
    set fqlx=%%a
)

REM �����豸�ķ����������ñ��� fqlx ��ֵ
if "!fqlx!" == "2" (
    set fqlx=AB
) else (
    set fqlx=A
)

ECHO.!loaded_device!!DeviceCode!
ECHO.
if not "!DeviceCode!"=="!right_device!" (
    %e% !device_mismatch_msg!
    PAUSE
    GOTO :EOF
)

REM ���������ļ���ˢ��
for /f "delims=" %%b in ('dir /b images ^| findstr /v /i "super.img" ^| findstr /v /i "preloader_raw.img" ^| findstr /v /i "cust.img" ^| findstr /v /i "recovery.img" ^| findstr /v /i /b "vbmeta"') do (
    set "filename=%%~nb"
    if "!fqlx!"=="A" (
        set "retry=0"
        :retryA
        "!fastboot!" flash %%~nb images\%%~nxb
        if "!errorlevel!"=="0" (
            echo !filename!: !success_status!
            echo.
        ) else (
            echo !filename!: !failure_status!
            if "!retry!"=="0" (
                set "retry=1"
                echo !retry_message!
                goto retryA
            )
        )
    ) else (
        set "retry=0"
        :retryA
        "!fastboot!" flash %%~nb_a images\%%~nxb
        if "!errorlevel!"=="0" (
            echo !filename!_a: !success_status!
        ) else (
            echo !filename!_a: !failure_status!
            if "!retry!"=="0" (
                set "retry=1"
                echo !retry_message!
                goto retryA
            )
        )
        set "retry=0"
        :retryB
        "!fastboot!" flash %%~nb_b images\%%~nxb
        if "!errorlevel!"=="0" (
            echo !filename!_b: !success_status!
            echo.
        ) else (
            echo !filename!_b: !failure_status!
            if "!retry!"=="0" (
                set "retry=1"
                echo !retry_message!
                goto retryB
            )
        )
    )
)

REM MTK ����ר��
if exist images\preloader_raw.img (
    	!fastboot! flash preloader_a images\preloader_raw.img !sg!
    	!fastboot! flash preloader_b images\preloader_raw.img !sg!
    	!fastboot! flash preloader1 images\preloader_raw.img !sg!
    	!fastboot! flash preloader2 images\preloader_raw.img !sg!
	echo.
)
REM ���ض������ļ�ר��ˢ��
set "count=0"
for /R images\ %%i in (*.img) do (
	echo %%~ni | findstr /B "vbmeta" >nul && (
		!fastboot! --disable-verity --disable-verification flash %%~ni_a %%i
		!fastboot! --disable-verity --disable-verification flash %%~ni_b %%i
		set /a "count+=1"
	)
)
if !count! gtr 0 (
	echo !disabled_avb_verification!
	echo.
)

if exist images\cust.img (
	!fastboot! flash cust images\cust.img
	echo.
)
if exist images\super.img (
    	!fastboot! flash super images\super.img
	echo.
)

if "!xz!" == "1" (
    echo !kept_data_reboot!
) else if "!xz!" == "2" (
    echo !formatting_data!
    !fastboot! erase userdata
    !fastboot! erase metadata
)

if "!fqlx!" == "AB" (
    !fastboot! set_active a %sg%
)

!fastboot! reboot
echo.
echo !execution_completed!
pause
exit
