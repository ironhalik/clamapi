# clamapi
A simple ClamAV service that exposes basic `clamd` functionality via a http api.  
Once the service is deployed using the provided Helm chart, you can POST any files to be scanned to `http://<host>/scan`. A typical request will look like this:
```
$ curl -s -F "file=@files/eicar.zip" -F "file=@files/clean.zip" http://localhost:8000/scan | jq .
{
  "results": {
    "clean.zip": [
      "OK",
      null
    ],
    "eicar.zip": [
      "FOUND",
      "Eicar-Signature"
    ]
  },
  "status": "failed"
}
```
By default, the container will use feshclam to download latest malware definitions at startup. The image can be run with `command: freshclam`, which will start a freshclam deamon, keeping the definitions up to date.


#### Environment variables:
```
CLAMD_HOST=clamd                  # The location of clamd daemon
CLAMD_PORT=3310                   # The TCP port clamd listens on
WAIT_FOR_CLAMD=true               # Whether to wait for clamd to respond
FRESHCLAM_CHECKS=12               # Number of times per day freshclam should check for new database
```

#### Acknowledgments:
[ClamAV](https://www.clamav.net/) ([CC BY-ND 2.5 License](https://creativecommons.org/licenses/by-nd/2.5/))
