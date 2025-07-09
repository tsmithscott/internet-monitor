## Docker run command:
```
docker run -d \
  --name internet-monitor \
  -e CONTAINERS="tsdproxy another-container" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  tsmithscott/internet-monitor:latest
```

## Run using docker compose:
```
services:
  internet-monitor:
    image: tsmithscott/internet-monitor:latest
    container_name: internet-monitor
    environment:
      - CONTAINERS="container another-container"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```
