local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local grafanaDashboards = {
  grafanaDashboards: {
    '2xx-monitoring.json': {
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
      "id": null,
      "links": [],
      "panels": [
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 1,
          "panels": [],
          "title": "Monitoring API Response",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "drawStyle": "line",
                "fillOpacity": 0,
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "mode": "none"
                }
              },
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 1
          },
          "id": 2,
          "options": {
            "legend": {
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "${datasource}"
              },
              "expr": "sum by (country, environment, instance) (probe_http_status_code == 200)",
              "refId": "A"
            }
          ],
          "title": "HTTP 2xx Monitoring",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "drawStyle": "line",
                "fillOpacity": 0,
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "mode": "none"
                }
              },
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 1
          },
          "id": 3,
          "options": {
            "legend": {
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "${datasource}"
              },
              "expr": "avg by (country, environment, instance) (probe_duration_seconds)",
              "refId": "B"
            }
          ],
          "title": "HTTP Response Time (seconds)",
          "type": "timeseries"
        }
      ],
      "schemaVersion": 39,
      "tags": [],
      "templating": {
        "list": [
          {
            "current": {
              "selected": true,
              "text": "systems-production",
              "value": "P4D7C5C41A3558C30"
            },
            "hide": 0,
            "name": "datasource",
            "query": "prometheus",
            "refresh": 1,
            "type": "datasource"
          }
        ]
      },
      "time": {
        "from": "now-6h",
        "to": "now"
      },
      "timezone": "browser",
      "title": "2xx Monitoring (Sandbox + Production)",
      "uid": "monitoring-2xx",
      "version": 1,
      "weekStart": ""
    }
  }
};

local mixin = addMixin({
  name: '2xx-monitoring',
  dashboardFolder: 'Endpoints Monitoring',
  mixin: grafanaDashboards,
});

{
  grafanaDashboards: mixin.grafanaDashboards,
}
