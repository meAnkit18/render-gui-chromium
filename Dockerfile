FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      chromium \
      xvfb \
      x11vnc \
      novnc \
      websockify \
      tini \
      xauth \
      fonts-liberation \
 && rm -rf /var/lib/apt/lists/*

COPY index.html /usr/share/novnc/index.html
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 10000
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
