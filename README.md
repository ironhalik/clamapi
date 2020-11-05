# clamav-api
A simple ClamAV service that exposes basic `clamd` functionality via a http api.  
Once the service is deployed using the provided Helm chart, you can POST any files to be scanned to `http://api-service.<namespace>.svc.cluster.local/scan` (or your respective namespace URL). A typical request will look like this:
```
$ curl -s -F "file=@clean.zip" -F "file=@infected.zip" http://api-service.clamav-api.svc.cluster.local/scan | jq .
{
  "results": {
    "clean.zip": [
      "OK",
      null
    ],
    "infected.zip": [
      "FOUND",
      "Win.Test.EICAR_HDB-1"
    ]
  },
  "status": "failed"
}
$ curl -s -F "file=@clean.zip" http://api-service.clamav-api.svc.cluster.local/scan | jq .
{
  "results": {
    "clean.zip": [
      "OK",
      null
    ]
  },
  "status": "ok"
}
```
The docker image contains malware definitions database available at docker build time, but the service is deployed with freshclam daemon, which will keep the malware definitions up to date.


#### Environment variables:
```
CLAMD_HOST=clamd                  # The location of clamd daemon
CLAMD_PORT=3310                   # The TCP port clamd listens on
WAIT_FOR_CLAMD=true               # Whether to wait for clamd to respond
FRESHCLAM_CHECKS=12               # Number of times per day freshclam should check for new database
```

#### Acknowledgments:
[ClamAV](https://www.clamav.net/) ([CC BY-ND 2.5 License](https://creativecommons.org/licenses/by-nd/2.5/))
[waitforit](https://github.com/maxcnunes/waitforit/blob/master/LICENSE.txt) ([MIT license](https://github.com/maxcnunes/waitforit/blob/master/LICENSE.txt))
