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
      {
        name: 'simple-notifications.rules',
        rules: [
          {
            record: 'simple:notifications:errors:1h',
            expr: |||
	      irate(ruby_sms_errors[1h]) > 10
            |||,
          },
	  {
            record: 'simple:notifications:errors:1m',
            expr: |||
	      irate(ruby_sms_errors[1m]) > 1
            |||,
          },
	  {
            record: 'simple:notifications:sent_error_rate',
            expr: |||
	      rate(ruby_sms_sent[1h]) < rate(ruby_sms_errors[1h])
            |||,
          },
        ],
      }
    ],
  },
}
