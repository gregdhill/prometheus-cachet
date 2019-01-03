#!/bin/bash

alert='
{
  "status": "firing",
  "alerts": [
    {
      "labels": {
   	    "alertname": "High Latency",
	      "service":   "my-service",
	      "severity":  "critical",
	      "instance":  "somewhere"
       },
       "annotations": {
    	    "summary": "The latency is too damn high!"
       }
    }
  ]
}'

# alert=$(echo $alert | jq -rc .)
# echo $alert

curl -XPOST -d"$alert" "http://127.0.0.1:8080/webhook"
