# [Prometheus Alerts](https://prometheus.io/docs/alerting/alertmanager/) to [Cachet](http://cachethq.io/)

Small go based microservice to receive Prometheus Alertmanager triggers and update corresponding incidents in Cachet.

## Dependencies

* https://github.com/andygrunwald/cachet
* https://github.com/prometheus/alertmanager

## Alertmanager Hook

The following alert matches on label `public` set to `true` then forwards to the configured webhook:

```
route:
  receiver: cachet
  group_by: [alertname]
  group_wait: 30s
  group_interval: 1m
  repeat_interval: 1h
  routes:
    - receiver: cachet
      match:
        public: "true"
  receivers:
    - name: cachet
      webhook_configs:
        - url: "http://status-cachet:80/webhook"
```
