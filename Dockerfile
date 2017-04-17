FROM alpine

RUN \
  apk --no-cache add byacc curl flex gcc groff linux-headers make musl-dev ncurses-dev util-linux openssh tini && \
  curl -sL https://sourceforge.net/projects/nethack/files/nethack/3.6.0/nethack-360-src.tgz | tar zxf - && \
  ( \
    cd nethack-3.6.0 && \
    sed -i -e 's/cp -n/cp/g' -e '/^PREFIX/s:=.*:=/usr:' sys/unix/hints/linux && \
    sh sys/unix/setup.sh sys/unix/hints/linux && \
    make all && \
    make install \
  ) && \
  rm -rf nethack-3.6.0

# for backup
VOLUME /usr/games/lib/nethackdir

RUN adduser -s /usr/games/nethack -S nethack && \
    passwd -u nethack && \
    echo ForceCommand /usr/games/nethack >> /etc/ssh/sshd_config && \
    echo PermitEmptyPasswords yes >> /etc/ssh/sshd_config && \
    echo X11Forwarding no >> /etc/ssh/sshd_config && \
    echo AllowTcpForwarding no >> /etc/ssh/sshd_config && \
    echo AllowAgentForwarding no >> /etc/ssh/sshd_config && \
    ssh-keygen -A

COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
EXPOSE 22
