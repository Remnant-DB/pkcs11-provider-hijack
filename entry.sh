#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
[LAB OBJECTIVE]
Assess SSH PKCS#11 provider trust boundaries and validate hardening controls
that protect authorized-key integrity in a controlled environment.
EOF

mkdir -p /var/run/sshd
ssh-keygen -A >/dev/null 2>&1

exec /usr/sbin/sshd -D -e
