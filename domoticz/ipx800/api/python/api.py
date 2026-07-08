import flask, ipx800
from flask import json, Response, request

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=['GET'])
def home():
    return "<h1>IPX800 API</h1><p>This API provide and forward information between IPX800 V3 and Domoticz server</p>"

@app.route('/ipx800', methods=['GET'])
def ipx800Statuses():
    status = ipx800.status()
    return Response(response=json.dumps(status), status=200, mimetype="application/json")

@app.route('/ipx800/events', methods=['GET', 'POST', 'PUT'])
def ipx800EventsReceiver():
    print("Args : ", json.dumps(request.values))
    print("Args : ", request.get_data(as_text=True))
    return Response(response="{\"success\": true}", status=200, mimetype="application/json")


app.run(host="0.0.0.0")
