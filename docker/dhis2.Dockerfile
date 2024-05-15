FROM dhis2/core:2.40.3.1

# Install prometheus jmx agent
RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar -O /opt/dhis2/jmx_prometheus_javaagent.jar

