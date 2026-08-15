# render-gui-chromium

A real, graphical Chromium browser running inside a Docker container, viewable and
controllable from any web browser via noVNC.

## Architecture

```
Your browser
    |
    |  (noVNC web client + WebSocket tunnel)
    v
websockify  (serves noVNC UI, bridges WebSocket <-> VNC)
    |
    |  (VNC protocol, no password)
    v
x11vnc      (exposes the virtual X display as a VNC server)
    |
    v
Xvfb        (virtual framebuffer Linux display :99)
    |
    v
Chromium    (runs fully graphical, window size 1280x800)
```

* `Dockerfile` — Debian bookworm-slim with `chromium`, `xvfb`, `x11vnc`,
  `novnc`, `websockify` and `tini`.
* `start.sh` — starts Xvfb, x11vnc, Chromium, then websockify (which listens on
  the `PORT` env var, so it works on Render's free tier out of the box).

## Usage on Render (free tier)

1. New Web Service -> connect this repository (or the image).
2. Environment: Docker, Region: any, Instance Type: Free.
3. Open the service URL; the noVNC page loads. Click **Connect** (leave the
   password blank) and you will see the live Chromium desktop.

## Local test

```bash
docker build -t gui-chromium .
docker run -p 8080:10000 -e PORT=10000 gui-chromium
# open http://localhost:8080/vnc.html and connect
```