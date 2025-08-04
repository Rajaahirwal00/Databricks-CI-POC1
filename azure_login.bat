@echo on
echo ===== Step 1: Azure Login =====
az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%
IF %ERRORLEVEL% NEQ 0 (
    echo Azure login failed!
    exit /b 1
)
