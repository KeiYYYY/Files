# Enable only for interactive shells.
case $- in *i*) ;; *) return ;; esac

# Clash ports (adjust to your setup).
HTTP_PORT=7890
SOCKS_PORT=7891

# Keep values stable if this script is sourced repeatedly.
unset HOST_IP gwhex

# 1) Parse default gateway from /proc/net/route (hex -> IPv4).
gwhex=$(awk '$2=="00000000"{print $3; exit}' /proc/net/route 2>/dev/null)
if [ -n "$gwhex" ]; then
  HOST_IP=$(printf "%d.%d.%d.%d" 0x${gwhex:6:2} 0x${gwhex:4:2} 0x${gwhex:2:2} 0x${gwhex:0:2})
fi

# 2) Fallback to resolv.conf if gateway parsing fails.
if [ -z "$HOST_IP" ]; then
  HOST_IP=$(awk '/nameserver/{print $2; exit}' /etc/resolv.conf 2>/dev/null)
fi

# Guard: if host IP cannot be resolved, do not export broken proxies.
if [ -z "$HOST_IP" ]; then
  echo "[proxy-wsl] WARN: HOST_IP unresolved, skip proxy setup" >&2
  return 0
fi

export http_proxy="http://$HOST_IP:${HTTP_PORT}"
export https_proxy="$http_proxy"
export all_proxy="socks5://$HOST_IP:${SOCKS_PORT}"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export ALL_PROXY="$all_proxy"
export no_proxy="localhost,127.0.0.1,::1,.local,*.local,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
export NO_PROXY="$no_proxy"
