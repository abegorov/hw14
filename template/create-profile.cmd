@echo off
if "%3" == "" goto :help
goto :main

:help
echo %0 cloud-id folder-id service-account-id
goto :eof

:main
yc config profile activate default
yc iam key create --service-account-id %3 --folder-name default --output key.json
yc config profile create %3
yc config set service-account-key key.json
yc config set cloud-id %1
yc config set folder-id %2
del key.json
goto :eof

:eof
