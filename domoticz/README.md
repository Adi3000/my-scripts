```
sudo apt-get install python3 python3-pip libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev
python3 -m venv ~/.local/python-host
 ~/.local/python-host/bin/python install -r requirements.txt
sudo ln -s /home/adi/git/my-scripts/domoticz/remotedomopi.service /etc/systemd/system/remotedomopi.service
```
