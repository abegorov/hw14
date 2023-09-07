@echo off
FOR /F "tokens=*" %%c IN ('yc iam create-token') do (SET YC_TOKEN=%%c)
FOR /F "tokens=*" %%c IN ('yc config get cloud-id') do (SET YC_CLOUD_ID=%%c)
FOR /F "tokens=*" %%c IN ('yc config get folder-id') do (SET YC_FOLDER_ID=%%c)
SET TF_VAR_yc_token=%YC_TOKEN%
