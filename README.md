# Internet Monitor

Simple shell script to automate restart of docker containers after an internet outage

## Docker run command

```bash
docker run -d \
  --name internet-monitor \
  -e CONTAINERS="tsdproxy another-container" \
  -e INTERVAL="30" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  tsmithscott/internet-monitor:latest
```

## Run using docker compose

```yaml
services:
  internet-monitor:
    image: tsmithscott/internet-monitor:latest
    container_name: internet-monitor
    environment:
      - CONTAINERS="container another-container" # List of containers to be restarted
      - INTERVAL=30 # Default is 10 seconds
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

### Docker Hub Page

https://hub.docker.com/repository/docker/tsmithscott/internet-monitor
