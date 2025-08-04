@echo on
echo ===== Step 2: ACR Login =====
az acr login --name cicdpocregistry
IF %ERRORLEVEL% NEQ 0 (
    echo ACR login failed!
    exit /b 1
)
