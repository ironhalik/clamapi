import re
import socket
import struct
from os import getenv

from flask import Flask, request

CLAMD_HOST = getenv("CLAMD_HOST", "clamd")
CLAMD_PORT = int(getenv("CLAMD_PORT", "3310"))
CHUNK_SIZE = 64 * 1024
SCAN_RESPONSE = re.compile(
    r"^stream: (?:(?P<signature>.+) )?(?P<status>OK|FOUND|ERROR)$"
)

app = Flask(__name__)
# Matches clamd's default StreamMaxLength: oversized uploads get a 413, not an error.
app.config["MAX_CONTENT_LENGTH"] = int(
    getenv("MAX_CONTENT_LENGTH", str(100 * 1024 * 1024))
)


def clamd(command, stream=None):
    with socket.create_connection((CLAMD_HOST, CLAMD_PORT)) as sock:
        sock.sendall(b"z" + command + b"\0")
        if stream is not None:
            while chunk := stream.read(CHUNK_SIZE):
                sock.sendall(struct.pack("!L", len(chunk)) + chunk)
            sock.sendall(struct.pack("!L", 0))
        response = b""
        while data := sock.recv(4096):
            response += data
    return response.rstrip(b"\0").decode()


def scan(stream):
    response = clamd(b"INSTREAM", stream)
    if match := SCAN_RESPONSE.match(response):
        return [match["status"], match["signature"]]
    return ["ERROR", response]


@app.route("/")
def ok():
    return "ok"


@app.route("/version")
def clamd_version():
    return clamd(b"VERSION") + "\n"


@app.route("/scan", methods=["POST"])
def clamd_scan():
    status = "ok"
    results = {}

    if files := request.files.getlist("file"):
        for file in files:
            result = scan(file.stream)
            # Keyed by filename: a later clean file must not hide a detection.
            if results.get(file.filename, ["OK"])[0] == "OK":
                results[file.filename] = result
            if result[0] != "OK":
                status = "failed"
        return {"status": status, "results": results}
    else:
        return "No file in request.", 400
