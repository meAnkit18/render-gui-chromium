#!/bin/bash
set -e

export DISPLAY=:99
W=1280
H=800

# Virtual X display (software framebuffer)
Xvfb :99 -screen 0 ${W}x${H}x24 -ac -nolisten tcp &

# Wait for Xvfb socket to appear
for i in $(seq 1 50); do
  [ -e /tmp/.X11-unix/X99 ] && break
  sleep 0.2
done

# VNC server exposing the virtual display on 5900
x11vnc -display :99 -forever -shared -nopw -rfbport 5900 \
       -o /tmp/x11vnc.log -noxdamage &

# Graphical Chromium on the virtual display
chromium \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --no-first-run \
  --no-default-browser-check \
  --window-size=${W},${H} \
  --window-position=0,0 \
  https://example.com &

# noVNC: serve the web client + tunnel VNC over WebSocket on Render's PORT
exec websockify --web=/usr/share/novnc --heartbeat=30 "${PORT:-8080}" localhost:5900