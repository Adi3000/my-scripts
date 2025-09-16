import time
import sys
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler
from multiprocessing import Pool
import importlib.util
#sys.path.append("/home/pi/git/python-host")
#import switchbot_py3
SWITCHBOT_SCRIPT="/home/pi/git/python-host/switchbot_py3.py"
#spec = importlib.util.spec_from_file_location("module.name", SWITCHBOT_SCRIPT)
#switchbot_py3 = importlib.util.module_from_spec(spec)
#sys.modules["module.name"] = switchbot_py3
#spec.loader.exec_module(switchbot_py3)
#from switchbot_py3 import Driver

HOST_NAME = "0.0.0.0"
HOST_PORT = 9966
#SWITCH_BOT_DEVICE="D7:35:34:35:46:69"
SWITCH_BOT_DEVICE="F0:4A:DF:AA:72:AA"

PC_SALON_MAC="B4:2E:99:D5:D6:2A"
IP_WOL_BROADCAST="192.168.0.255"
PHONE_IPS = [ ("Phone Adi 1", "192.168.0.34"), ("Phone Zuliz 2", "192.168.0.26"), ("Phone Zuliz 1", "192.168.0.27"), ("Phone PC", "192.168.0.21")]
#PHONE_IPS = [ ("Phone Adi 1", "192.168.0.34"), ("Phone Adi 2", "192.168.0.18"), ("Phone Adi 3", "192.168.0.28"),("Phone PC", "192.168.0.21")]

configs = {}

def _pingPhone(idx):
    name, ip = PHONE_IPS[idx]
    response = os.system("ping -q -W 20 -c 1 " + ip)
    status = "false"
    if response == 0:
        status = "true"
    print("Ping for "+name+"/"+ip+" is "+status)
    return "{\"name\":\""+name+"\", \"status\":"+status+"}"

def _pingAllPhones():
    pool = Pool()
    return pool.map(_pingPhone, range(0, len(PHONE_IPS)))


class HttpServer(SimpleHTTPRequestHandler):
    def do_GET(self):
        if "/broadlink/" in self.path:
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            root, base, command = self.path.split("/")
            print(command)
            self.broadlink(str(command))
            return
        elif "/wol/pc_salon" in self.path:
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wokeonlan()
            return
        elif "/_health" in self.path:
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(str("ping").encode())
            self.send_response(200)
            return
        elif "/switchbot/" in self.path:
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            root, base, times = self.path.split("/")
            self.switchbot(str(times))
            return
        elif "/ping/phones" in self.path:
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.pingAllPhones()
            return

        else:
            SimpleHTTPRequestHandler.do_GET(self)

    def switchbot(self, command):
        if command == "":
            self.send_response(400)
            return
        times = 0
        try:
            times = int(command)
        except ValueError:
            self.send_response(404)
            return
        #driver = Driver(device=SWITCH_BOT_DEVICE, bt_interface="hci0", timeout_secs=2)
        i=0

        while i < times:
            try:
                pressCommand = os.system("python3 "+SWITCHBOT_SCRIPT+" -d "+SWITCH_BOT_DEVICE+" -c press")
                if pressCommand == 0:
                    i = i + 1
            except:
                print("Failed send press on the "+str(i)+" time, retrying...")
            time.sleep(4)

        self.wfile.write(command.encode())
        self.send_response(200)
        return

    def broadlink(self, command):
        if command == "":
            self.send_response(400)
            return
        signal = ""
        try:
            signal = configs[command]
        except KeyError:
            self.send_response(404)
            return
        self.wfile.write(signal.encode())
        self.send_response(200)
        return

    def wokeonlan(self):
        try:
            wolCommand = os.system("wakeonlan -i "+IP_WOL_BROADCAST+" "+PC_SALON_MAC)
        except:
            print("Failed send WOL magick packet for  "+PC_SALON_MAC)
            self.send_response(500)
        self.wfile.write(PC_SALON_MAC.encode())
        self.send_response(200)
        return

    def pingAllPhones(self):
        pool = Pool()
        result = _pingAllPhones()
        self.wfile.write(str("["+",".join(result)+"]").encode())
        self.send_response(200)
        return


with open('/home/pi/git/my-scripts/domoticz/codes.txt', 'rb') as config_file:
    for rawLine in config_file:
       line = rawLine.decode("utf-8")
       if len(line.strip()) > 0 and not line.strip().startswith("#"):
           (key, value) = line.split("=", 1)
           configs[key] = value

httpServer = HTTPServer((HOST_NAME, HOST_PORT), HttpServer)
try:
    httpServer.serve_forever()
except KeyboardInterrupt:
    pass

httpServer.server_close()
print(time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, HOST_PORT))
