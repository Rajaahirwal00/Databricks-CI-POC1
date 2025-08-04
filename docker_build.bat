@echo on
echo ===== Step 3: Docker Build =====
docker build -t cicdpocregistry.azurecr.io/databricks-pipeline:latest .
IF %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    exit /b 1
)
