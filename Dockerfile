FROM docker.elastic.co/logstash/logstash:8.11.0

# Copy the Logstash configuration
COPY logstash.conf /usr/share/logstash/pipeline/

# Expose the webhook port
EXPOSE 8080

# Add labels for better maintainability
LABEL maintainer="GitHub Enterprise Cloud Team"
LABEL description="Logstash configuration for GitHub webhooks"
LABEL version="1.0.0"

# Set environment variables for Logstash
ENV XPACK_MONITORING_ENABLED=false
ENV XPACK_SECURITY_ENABLED=false

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080 || exit 1