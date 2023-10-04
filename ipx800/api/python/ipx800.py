import requests, xmltodict
from requests.auth import HTTPBasicAuth

IPX800_ENDPOINT = "http://192.168.0.10:2623"

def status():
    status = requests.get(IPX800_ENDPOINT+"/status.xml", auth=HTTPBasicAuth("admin", "263adidoo066"))
    return xmltodict.parse(status.text)
