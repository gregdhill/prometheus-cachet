# Bridge - Cachet & Prometheus

Small go based microservice to receive Prometheus Alertmanager triggers and update corresponding incidents in Cachet.

## Dependencies

* https://github.com/andygrunwald/cachet
* https://github.com/prometheus/alertmanager

## Alertmanager Hook

```
route:
  receiver: cachet
  group_by: [alertname]
  group_wait: 30s
  group_interval: 1m
  repeat_interval: 1h
  routes:
    - receiver: cachet
      match_re:
        severity: .*
  receivers:
    - name: cachet
      webhook_configs:
        - url: "http://status-cachet/webhook"
```
