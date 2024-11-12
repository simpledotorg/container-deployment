{
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
  "description": "Simple database dashboard",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": 57,
  "links": [],
  "panels": [
    {
      "datasource": {
        "type": "datasource",
        "uid": "-- Mixed --"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 25,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "normal"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "fieldMinMax": false,
          "mappings": [],
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
          },
          "unit": "s"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 14,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 8,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "hidden",
          "placement": "right",
          "showLegend": false
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "pluginVersion": "v10.4.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "editorMode": "code",
          "expr": "ruby_reporting_views_refresh_duration_seconds{view!=\"all\"}",
          "legendFormat": "__auto",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "MatView Refresh Duration",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "datasource",
        "uid": "-- Mixed --"
      },
      "description": "The size of the tables is refreshed daily from simple-server using the RecordCounterJob",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 25,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "normal"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "fieldMinMax": false,
          "mappings": [],
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
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 14,
        "w": 24,
        "x": 0,
        "y": 14
      },
      "id": 9,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "hidden",
          "placement": "right",
          "showLegend": false
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "pluginVersion": "v10.4.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "editorMode": "code",
          "expr": "ruby_appointments",
          "legendFormat": "__auto",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_patients",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "B",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_blood_pressures",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "C",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_blood_sugars",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "D",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_encounters",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "E",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_facilities",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "F",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_facility_groups",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "G",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_medical_histories",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "H",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_notifications",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "I",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_regions",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "J",
          "useBackend": false
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${datasource}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "ruby_users",
          "fullMetaSearch": false,
          "hide": false,
          "includeNullMetadata": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "K",
          "useBackend": false
        }
      ],
      "title": "Size of tables that contribute to MatView Refreshes",
      "type": "timeseries"
    }
  ],
  "schemaVersion": 39,
  "tags": [],
  "templating": {
    "list": [
      {
        "current": {
          "selected": false,
          "text": "prometheus",
          "value": "P1809F7CD0C75ACF3"
        },
        "hide": 0,
        "includeAll": false,
        "multi": false,
        "name": "datasource",
        "options": [],
        "query": "prometheus",
        "queryValue": "",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "type": "datasource"
      }
    ]
  },
  "time": {
    "from": "now-30d",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "browser",
  "title": "MatView Refresh Dashboard",
  "uid": "matview-refresh-dashboard",
  "version": 1,
  "weekStart": ""
}
