{
  prometheusRules+:: {
    groups+: [
      {
        name: 'simple-server.rules',
        rules: [
          {
            record: 'simple:response_time:p95:total',
            expr: |||
              quantile(0.95, irate(ruby_http_request_duration_seconds_sum[1m]) / irate(ruby_http_request_duration_seconds_count[1m]) > 0) 
            |||,
          },
          {
            record: 'simple:response_time:p95:api',
            expr: |||
              quantile(0.95, irate(ruby_http_request_duration_seconds_sum{controller=~'api/.+'}[1m]) / irate(ruby_http_request_duration_seconds_count{controller=~'api/.+'}[1m]) > 0) 
            |||,
          },
          {
            record: 'simple:response_time:p95:dashboard',
            expr: |||
              quantile(0.95, irate(ruby_http_request_duration_seconds_sum{controller!~'api/.+'}[1m]) / irate(ruby_http_request_duration_seconds_count{controller!~'api/.+'}[1m]) > 0) 
            |||,
          },
        ],
      },
    ],
  },
}
