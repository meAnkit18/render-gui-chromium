#!/bin/bash
set -e

export DISPLAY=:99
W=1280
H=800

(
  while true; do
    WININFO=$(xwininfo -root -tree 2>/dev/null | grep -iE 'chromium|children' | head -3 | tr -s ' ')
    PIX=$(import -window root png:- 2>/dev/null | convert - -resize 48x30! -colorspace Gray -format 'mean=%[fx:mean] std=%[fx:standard_deviation]' info: 2>/dev/null)
    echo "[probe] win=[${WININFO}] pix=[${PIX:-none}]"
    sleep 20
  done
) &

(
  while true; do
    MEM_NOW=$(cat /sys/fs/cgroup/memory.current 2>/dev/null | awk '{printf "%.0fMB", $1/1048576}')
    MEM_MAX=$(cat /sys/fs/cgroup/memory.max 2>/dev/null | awk '{printf "%.0fMB", $1/1048576}')
    CHROMS=$(pgrep -c chromium 2>/dev/null || echo 0)
    echo "[diag] $(date -u +%H:%M:%S) cgroup ${MEM_NOW}/${MEM_MAX} chrom_procs ${CHROMS}"
    sleep 15
  done
) &

Xvfb :99 -screen 0 ${W}x${H}x24 -ac -nolisten tcp &

for i in $(seq 1 50); do
  [ -e /tmp/.X11-unix/X99 ] && break
  sleep 0.2
done

x11vnc -display :99 -forever -shared -nopw -rfbport 5900 \
       -o /tmp/x11vnc.log -noxdamage &

chromium \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --no-first-run \
  --no-default-browser-check \
  --disable-extensions \
  --disable-component-update \
  --disable-sync \
  --disable-translate \
  --no-pings \
  --disable-background-networking \
  --metrics-recording-only \
  --enable-low-end-device-mode \
  --renderer-process-limit=2 \
  --window-size=${W},${H} \
  --window-position=0,0 \
  https://example.com &

exec websockify --web=/usr/share/novnc --heartbeat=30 "${PORT:-8080}" localhost:5900
