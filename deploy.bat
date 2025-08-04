@echo on

echo === AZURE_CLIENT_ID: %AZURE_CLIENT_ID%
echo === AZURE_CLIENT_SECRET: %AZURE_CLIENT_SECRET%
echo === AZURE_TENANT_ID: %AZURE_TENANT_ID%

call azure_login.bat
call acr_login.bat
call docker_build.bat
call docker_push.bat
call k8s_deploy.bat
