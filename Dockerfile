FROM alpine

ENV ANITA_VERSION=2.8 \
    ANITA_DISK_SIZE=4G \
    NETBSD_VERSION=9.1

ENV INSTALL_PATH=http://cdn.netbsd.org/pub/NetBSD/NetBSD-${NETBSD_VERSION}/amd64/

# Install anita
RUN \
  apk add --no-cache git py3-pexpect && \
  git clone --depth=1 https://github.com/vasi/anita.git /tmp/anita && \
  cd /tmp/anita && \
  python3 setup.py install && \
  rm -r /tmp/anita && \
  apk del git

# Install netbsd
RUN \
  apk add --no-cache xorriso qemu-system-x86_64 qemu-img && \
  anita --workdir /anita/install --memory-size 512M \
    --disk-size ${ANITA_DISK_SIZE} --image-format qcow2 \
    --sets kern-GENERIC,modules,base,etc,misc,text,man,comp \
    install ${INSTALL_PATH} && \
  rm -r /anita/install/download && \
  apk del xorriso

# Setup
RUN \
  # Use a snapshot to save space \
  mkdir -p /anita/snapshot && \
  qemu-img create -F qcow2 -b /anita/install/wd0.img -f qcow2 /anita/snapshot/wd0.img && \
  \
  apk add --no-cache openssh && \
  ssh-keygen -f /root/.ssh/id_rsa -N '' && \
  anita --workdir /anita/snapshot --memory-size 512M --persist --run "\
      # Setup SSH
      echo -e 'dhcpcd=YES\nsshd=YES\nhostname=netbsd\n' >> /etc/rc.conf; \
      sed -i -e 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config; \
      install -d -m 0700 /root/.ssh ; \
      echo $(cat /root/.ssh/id_rsa.pub) >> /root/.ssh/authorized_keys; \
      chmod 0600 /root/.ssh/authorized_keys; \
      \
      # Package path
      echo -e 'export PKG_PATH=http://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/${NETBSD_VERSION}/All/\n' >> /root/.profile" \
    boot ${INSTALL_PATH}

EXPOSE 22
COPY entrypoint.sh qemu-start.sh /scripts/
ENTRYPOINT [ "/scripts/entrypoint.sh" ]

HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=10 \
  CMD ssh localhost true
