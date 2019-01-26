#!/bin/bash

alert='
[{
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
}]'

# alert=$(echo $alert | jq -rc .)
# echo $alert

curl -XPOST -d "$alert" "http://127.0.0.1:8000/webhook"

echo -e "\nPress enter to resolve."
read

alert='
[{
  "status": "resolved",
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
}]'

curl -XPOST -d "$alert" "http://127.0.0.1:8000/webhook"
