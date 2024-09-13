msiexec.exe /i splunkforwarder-7.2.7-f817a93effc2-x64-release.msi DEPLOYMENT_SERVER="10.59.240.226:8089" AGREETOLICENSE=yes /quiet

start /wait NET STOP SplunkForwarder
start /wait NET START SplunkForwarder