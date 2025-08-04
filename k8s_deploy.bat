@echo on
echo ===== Step 5: Deploy to AKS =====
kubectl apply -f job.yaml
IF %ERRORLEVEL% NEQ 0 (
    echo Kubernetes apply failed!
    exit /b 1
)

echo ===== Deployment Completed Successfully! =====
