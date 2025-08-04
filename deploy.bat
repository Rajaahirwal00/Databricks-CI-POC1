@echo on
echo === AZURE_CLIENT_ID: %AZURE_CLIENT_ID%
echo === AZURE_CLIENT_SECRET: %AZURE_CLIENT_SECRET%
echo === AZURE_TENANT_ID: %AZURE_TENANT_ID%

echo ===== Step 1: Azure Login =====
az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%
IF %ERRORLEVEL% NEQ 0 (
    echo Azure login failed!
    exit /b 1
)

echo ===== Step 2: ACR Login =====
az acr login --name cicdpocregistry
IF %ERRORLEVEL% NEQ 0 (
    echo ACR login failed!
    exit /b 1
)

echo ===== Step 3: Docker Build =====
docker build -t cicdpocregistry.azurecr.io/databricks-pipeline:latest .
IF %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    exit /b 1
)

echo ===== Step 4: Docker Push =====
docker push cicdpocregistry.azurecr.io/databricks-pipeline:latest
IF %ERRORLEVEL% NEQ 0 (
    echo Docker push failed!
    exit /b 1
)

echo ===== Step 5: AKS Context Setup =====
az aks get-credentials --resource-group CICD-AKS-RG --name CICD-AKS-Cluster --overwrite-existing
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to get AKS credentials!
    exit /b 1
)

echo ===== Step 6: Deploy to AKS =====
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

echo ===== Deployment Completed Successfully! =====
exit /b 0
