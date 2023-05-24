from flask import Flask, request
from clamd import ClamdNetworkSocket
from os import getenv

app = Flask(__name__)
clamd = ClamdNetworkSocket(
    host=getenv("CLAMD_HOST", "clamd"), port=int(getenv("CLAMD_PORT", 3310))
)
clamd.ping()


@app.route("/")
def ok():
    return "ok"


@app.route("/version")
def clamd_version():
    return clamd.version() + "\n"


@app.route("/reload")
def clamd_reload():
    return clamd.reload() + "\n"


@app.route("/scan", methods=["POST"])
def clamd_scan():
    status = "ok"
    results = {}

    if files := request.files.getlist("file"):
        for file in files:
            result = clamd.instream(file)["stream"]
            results[file.filename] = result
            if result[0] != "OK":
                status = "failed"
        return {"status": status, "results": results}
    else:
        return "No file in request.", 400
