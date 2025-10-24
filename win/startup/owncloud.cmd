@echo off
for /f "usebackq tokens=1,2 delims==" %%A in ("G:\Utils\Init\owncloud_adi.txt") do (
    set %%A=%%B
)
echo "Connecting Nextcloud %OWNCLOUD_USERNAME%"
net use Z: /delete
net use Z: %OWNCLOUD_URL% /persistent:yes /user:%OWNCLOUD_USERNAME% %OWNCLOUD_PASSWORD%


for /f "usebackq tokens=1,2 delims==" %%A in ("G:\Utils\Init\owncloud_zuliz.txt") do (
    set %%A=%%B
)
echo "Connecting Nextcloud %OWNCLOUD_USERNAME%"
net use X: /delete
net use X: %OWNCLOUD_URL% /persistent:yes /user:%OWNCLOUD_USERNAME% %OWNCLOUD_PASSWORD%
