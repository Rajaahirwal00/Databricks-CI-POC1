@echo on

echo === AZURE_CLIENT_ID: %AZURE_CLIENT_ID%
echo === AZURE_CLIENT_SECRET: %AZURE_CLIENT_SECRET%
echo === AZURE_TENANT_ID: %AZURE_TENANT_ID%

call step1_azure_login.bat
call step2_acr_login.bat
call step3_docker_build.bat
call step4_docker_push.bat
call step5_k8s_deploy.bat
