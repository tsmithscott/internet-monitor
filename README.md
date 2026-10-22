# Internet Monitor

Shell script to automate restart of docker containers after an internet outage

## Docker run command

```bash
docker run -d \
  --name internet-monitor \
  -e CONTAINERS="container another-container" \
  -e INTERVAL="30" \
  -e FAIL_THRESHOLD="3" \
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
      - CONTAINERS=container another-container # Space-separated, no quotes in list syntax
      - INTERVAL=30
      - FAIL_THRESHOLD=3
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `CONTAINERS` | *(required)* | Space-separated list of container names to restart, as shown by `docker ps` (with compose, set `container_name:` or use the generated name) |
| `INTERVAL` | `30` | Seconds between connectivity checks |
| `CHECK_URL` | `https://www.google.com` | URL used to test connectivity |
| `CHECK_TIMEOUT` | `5` | Seconds before a single check times out |
| `FAIL_THRESHOLD` | `3` | Consecutive failed checks before the internet is declared down; avoids restarts after a single dropped request |
| `RESTART_DELAY` | `0` | Seconds to wait after the internet returns before restarting containers |
| `RESTART_RETRIES` | `3` | Attempts per container if `docker restart` fails |
| `RESTART_RETRY_DELAY` | `10` | Seconds between restart attempts |

With the defaults, an outage is detected after roughly `FAIL_THRESHOLD × INTERVAL` seconds (about 90s).

## Notes

- Mounting `/var/run/docker.sock` is required; it is how the container talks to the host's Docker daemon. It also gives the container root-equivalent control of the host, so only run images you trust.
- In docker compose list syntax (`- KEY=value`), quotes are kept as part of the value. The script strips them from `CONTAINERS`, but it is clearer to leave them out, or use map syntax (`CONTAINERS: "a b"`).

### Links

#### GitHub

[https://github.com/tsmithscott/internet-monitor](https://github.com/tsmithscott/internet-monitor)

#### Docker Hub

[https://hub.docker.com/repository/docker/tsmithscott/internet-monitor](https://hub.docker.com/repository/docker/tsmithscott/internet-monitor)
