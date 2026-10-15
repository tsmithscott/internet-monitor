# Base image (pinned so Dependabot can track and bump it)
FROM alpine:3.24

# Install required packages and pull in any security fixes for the base image
RUN apk upgrade --no-cache && apk add --no-cache curl ca-certificates docker-cli

# Copy monitor script
COPY monitor.sh /usr/local/bin/monitor.sh

# Make script executable
RUN chmod +x /usr/local/bin/monitor.sh

# Run script
ENTRYPOINT ["sh", "-c", "/usr/local/bin/monitor.sh"]
