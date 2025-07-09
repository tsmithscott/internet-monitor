# Base image
FROM alpine:latest

# Install required packages
RUN apk add --no-cache curl ca-certificates docker-cli

# Copy monitor script
COPY monitor.sh /usr/local/bin/monitor.sh

# Make script executable
RUN chmod +x /usr/local/bin/monitor.sh

# Run script
ENTRYPOINT ["sh", "-c", "/usr/local/bin/monitor.sh"]