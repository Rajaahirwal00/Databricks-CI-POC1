@echo on
echo ===== Step 4: Docker Push =====
docker push cicdpocregistry.azurecr.io/databricks-pipeline:latest
IF %ERRORLEVEL% NEQ 0 (
    echo Docker push failed!
    exit /b 1
)
