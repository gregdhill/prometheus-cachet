#!/bin/bash

alert='
[{
  "status": "firing",
	"labels": {
		"alertname": "High Latency",
		"service":   "my-service",
		"severity":  "warning",
		"instance":  "somewhere",
    "public": "true"
	},
	"annotations": {
		"summary": "The latency is too damn high!"
	},
  "generatorURL": "http://example.com"
}]'

curl -XPOST -d "$alert" "http://localhost:9093/api/v1/alerts"

echo -e "\nPress enter to resolve."
read

alert='
[{
  "status": "resolved",
	"labels": {
		"alertname": "High Latency",
		"service":   "my-service",
		"severity":  "warning",
		"instance":  "somewhere",
    "public": "true"
	},
	"annotations": {
		"summary": "The latency is too damn high!"
	},
  "generatorURL": "http://example.com"
}]'

curl -XPOST -d "$alert" "http://localhost:9093/api/v1/alerts"
