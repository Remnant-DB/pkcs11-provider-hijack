# pkcs11-provider-hijack Lab

Containerized educational lab for local security testing workflows.

## Scope and Safety

- Run only in an isolated local environment.
- Do not expose this lab to untrusted/public networks.
- Use this lab for defensive analysis, detection, and hardening validation.

## Project Files

- `Dockerfile`: image build definition
- `entry.sh`: container entrypoint and lab objective
- `compose.yaml`: Compose definition compatible with Docker Compose and Podman Compose

## Prerequisites

### Docker

- Docker Engine or Docker Desktop
- Docker Compose v2 (`docker compose`)

### Podman

- Podman 4+ (`podman`)
- Compose support (`podman compose` or `podman-compose`)
- macOS/Windows: running Podman machine

```bash
podman machine init
podman machine start
```

## Start the Lab (Compose)

Run from this directory:

```bash
cd pkcs11-provider-hijack
```

### Docker Compose

```bash
docker compose -f compose.yaml up --build -d
```

### Podman Compose

```bash
podman compose -f compose.yaml up --build -d
```

If your environment provides `podman-compose`:

```bash
podman-compose -f compose.yaml up --build -d
```

## Start Without Compose

### Docker

```bash
docker build -t pkcs11-provider-hijack-lab:local .
docker run -d --name pkcs11-provider-hijack-lab -p 2256:22 pkcs11-provider-hijack-lab:local
```

### Podman

```bash
podman build -t pkcs11-provider-hijack-lab:local .
podman run -d --name pkcs11-provider-hijack-lab -p 2256:22 pkcs11-provider-hijack-lab:local
```

## Verification

Check running container:

```bash
docker ps --filter name=pkcs11-provider-hijack-lab
podman ps --filter name=pkcs11-provider-hijack-lab
```

Check logs:

```bash
docker compose -f compose.yaml logs -f
podman compose -f compose.yaml logs -f
```

Validate SSH port:

```bash
nc -vz 127.0.0.1 2256
```

## Stop and Cleanup

### Compose

```bash
docker compose -f compose.yaml down
podman compose -f compose.yaml down
```

### Without Compose

```bash
docker rm -f pkcs11-provider-hijack-lab
podman rm -f pkcs11-provider-hijack-lab
```

## Troubleshooting

- Podman socket/connection errors:
  - Start the VM: `podman machine start`
- Port `2256` already in use:
  - Update host mapping in `compose.yaml` (example: `3256:22`)
- Package download failures during build:
  - Retry build and verify outbound network access
