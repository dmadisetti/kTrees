import pandas
import os
from flask import Flask, jsonify, render_template

app = Flask(__name__)

# Load into memory, opposed to db
data = {}
for f in os.listdir('raw'):
    data[f.split('.')[0]] = pandas.read_csv('raw/'+f)


@app.route('/')
def main():
    return app.send_static_file('index.html')


@app.route('/sunburst/<raw>/<name>/<csv>')
def sunburst(raw, name, csv):
    return render_template('index.html', raw=raw, file=csv, name=name)


@app.route('/api/<raw>/<id>')
def api(raw, id):
    response = {"message": "Broken", "success": False}
    try:
        response["message"] = data[raw].ix[int(id)-1]["memo"]
        response["success"] = True
    except:
        pass
    return jsonify(**response)


port = int(os.environ.get('PORT', 5000))
app.run(host='0.0.0.0', port=port)
