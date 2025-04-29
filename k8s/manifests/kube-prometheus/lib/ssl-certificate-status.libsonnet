local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local prometheusRules = {
  prometheusRules+:: {
    groups: [
      {
        name: 'sslexpiryalerts.rules',
        rules: [
          {
            alert: 'SSLExpiryWithin30Days',
            expr: |||
              probe_ssl_earliest_cert_expiry - time() < 2592000
            |||,
            'for': '5m',
            labels: {
              severity: 'warning'
            },
            annotations: {
              summary: "SSL certificate is about to expire within 30 days",
              description: "The SSL certificate for {{ $labels.instance }} will expire in less than 30 days."
            }
          },
          {
            alert: 'ProductionEnvironmentDown',
            expr: |||
              up{environment="production"} == 0
            |||,
            'for': '5m',
            labels: {
              severity: 'critical'
            },
            annotations: {
              summary: "Production environment is down",
              description: "The production environment instance {{ $labels.instance }} has been down for more than 5 minutes."
            }
          }
        ],
      },
    ],
  },
};

local grafanaDashboards = { grafanaDashboards: {
  'ssl-certificate-status.json': {
    "annotations": {
      "list": [
        {
          "builtIn": 1,
          "datasource": {
            "type": "grafana",
            "uid": "-- Grafana --"
          },
          "enable": true,
          "hide": true,
          "iconColor": "rgba(0, 211, 255, 1)",
          "name": "Annotations & Alerts",
          "type": "dashboard"
        }
      ]
    },
    "editable": true,
    "fiscalYearStartMonth": 0,
    "graphTooltip": 0,
    "id": 65,
    "links": [],
    "panels": [
      {
        "datasource": {
          "type": "prometheus",
          "uid": "P4D7C5C41A3558C30"
        },
        "description": "",
        "fieldConfig": {
          "defaults": {
            "color": {
              "fixedColor": "transparent",
              "mode": "fixed"
            },
            "custom": {
              "align": "auto",
              "cellOptions": {
                "mode": "basic",
                "type": "color-background"
              },
              "filterable": true,
              "inspect": false
            },
            "fieldMinMax": false,
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                }
              ]
            },
            "unit": "none"
          },
          "overrides": [
            {
              "matcher": {
                "id": "byName",
                "options": "Value"
              },
              "properties": [
                {
                  "id": "mappings",
                  "value": [
                    {
                      "options": {
                        "from": 0,
                        "result": {
                          "color": "dark-red",
                          "index": 0
                        },
                        "to": 30
                      },
                      "type": "range"
                    },
                    {
                      "options": {
                        "from": 30,
                        "result": {
                          "color": "orange",
                          "index": 1
                        },
                        "to": 60
                      },
                      "type": "range"
                    },
                    {
                      "options": {
                        "from": 30,
                        "result": {
                          "color": "yellow",
                          "index": 2
                        },
                        "to": 90
                      },
                      "type": "range"
                    },
                    {
                      "options": {
                        "from": 90,
                        "result": {
                          "color": "green",
                          "index": 3
                        },
                        "to": 99999999
                      },
                      "type": "range"
                    }
                  ]
                }
              ]
            },
            {
              "matcher": {
                "id": "byName",
                "options": "country"
              },
              "properties": [
                {
                  "id": "thresholds",
                  "value": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "color": "transparent",
                        "value": null
                      }
                    ]
                  }
                },
                {
                  "id": "custom.width",
                  "value": 121
                }
              ]
            },
            {
              "matcher": {
                "id": "byName",
                "options": "Time"
              },
              "properties": [
                {
                  "id": "custom.width",
                  "value": 217
                }
              ]
            },
            {
              "matcher": {
                "id": "byName",
                "options": "environment"
              },
              "properties": [
                {
                  "id": "custom.width",
                  "value": 200
                }
              ]
            },
            {
              "matcher": {
                "id": "byName",
                "options": "instance"
              },
              "properties": [
                {
                  "id": "custom.width",
                  "value": 475
                }
              ]
            }
          ]
        },
        "gridPos": {
          "h": 18,
          "w": 24,
          "x": 0,
          "y": 0
        },
        "id": 1,
        "options": {
          "cellHeight": "sm",
          "footer": {
            "countRows": false,
            "enablePagination": true,
            "fields": "",
            "reducer": [
              "sum"
            ],
            "show": false
          },
          "frameIndex": 1,
          "showHeader": true,
          "sortBy": [
            {
              "desc": false,
              "displayName": "Value"
            }
          ]
        },
        "pluginVersion": "10.4.0",
        "targets": [
          {
            "datasource": {
              "type": "prometheus",
              "uid": "P4D7C5C41A3558C30"
            },
            "editorMode": "code",
            "exemplar": false,
            "expr": "min by (country,instance, environment) ((probe_ssl_earliest_cert_expiry -time())) / 60 / 60 / 24",
            "format": "table",
            "instant": true,
            "legendFormat": "__auto",
            "range": false,
            "refId": "A"
          }
        ],
        "title": "Monitored Instances",
        "transparent": true,
        "type": "table"
      }
    ],
    "schemaVersion": 39,
    "tags": [],
    "templating": {
      "list": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PB7AD567477C83756"
          },
          "filters": [],
          "hide": 0,
          "name": "Filters",
          "skipUrlSync": false,
          "type": "adhoc"
        }
      ]
    },
    "time": {
      "from": "now-6h",
      "to": "now"
    },
    "timepicker": {},
    "timezone": "browser",
    "title": "SSL Certificates Validity",
    "uid": "aejuy0izg7nr4a",
    "version": 10,
    "weekStart": ""
   }
}};

local sslExpiryMixin = addMixin({
  name: 'ssl-certificate-status',
  dashboardFolder: 'Endpoints Monitoring',
  mixin: prometheusRules + grafanaDashboards,
});

{
  grafanaDashboards: sslExpiryMixin.grafanaDashboards,
  prometheusRules: sslExpiryMixin.prometheusRules,
}
