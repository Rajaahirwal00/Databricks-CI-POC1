@echo off

echo ===== Step 1: Azure Login =====
az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%
IF %ERRORLEVEL% NEQ 0 (
    echo Azure login failed!
    exit /b 1
)
echo Azure login successful.

echo ===== Step 2: ACR Login =====
az acr login --name cicdpocregistry
IF %ERRORLEVEL% NEQ 0 (
    echo ACR login failed!
    exit /b 1
)
echo ACR login successful.

echo ===== Step 3: Docker Build =====
docker build -t cicdpocregistry.azurecr.io/databricks-pipeline:latest .
IF %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    exit /b 1
)
echo Docker build successful.

echo ===== Step 4: Docker Push =====
docker push cicdpocregistry.azurecr.io/databricks-pipeline:latest
IF %ERRORLEVEL% NEQ 0 (
    echo Docker push failed!
    exit /b 1
)
echo Docker push successful.

echo ===== Step 5: Deploy to AKS =====
kubectl apply -f deployment.yaml
IF %ERRORLEVEL% NEQ 0 (
    echo Deployment.yaml apply failed!
    exit /b 1
)

kubectl apply -f job.yaml
IF %ERRORLEVEL% NEQ 0 (
    echo Job.yaml apply failed!
    exit /b 1
)

echo ===== ✅ Deployment Completed Successfully! =====


