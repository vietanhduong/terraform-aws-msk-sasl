#!/usr/bin/env bash
#
# Author: @vietanhduong
#

function cleanup() {
  rm -f /tmp/get-docker.sh
}

trap cleanup EXIT

if ! command -v docker &> /dev/null; then
  if ! curl -fsSL https://get.docker.com -o get-docker.sh; then
    echo "Download setup docker script failed" >&2
    exit 1
  fi
  chmod +x get-docker.sh
  sudo sh get-docker.sh
fi

TEMPLATE_SERVICE=/tmp/msk-proxy.service.tpl
if [[ ! -f "$TEMPLATE_SERVICE" ]]; then
  echo "No such file $TEMPLATE_SERVICE" >&2
  exit 1
fi

START_PORT=9090
BOOTSTRAP_BROKERS="$1"
PROXY_IP="$2"

# BOOTSTRAP_BROKERS must have format <broker>:<port>,<broker>:<port> 
IFS=',' read -ra brokers <<< "$BOOTSTRAP_BROKERS"

# Format broker urls
BROKER_URL=""
for broker in "${brokers[@]}"; do 
  BROKER_URL+="\t\t--bootstrap-server-mapping \"$broker,0.0.0.0:$START_PORT,$PROXY_IP:$START_PORT\" \\\\\n"
  START_PORT=$((START_PORT + 1))
done 


SERVICE_OUTPUT=/tmp/msk-proxy.service
BROKER_URL=${BROKER_URL%$'\\n'}
sed -e "s|<broker_url>|$BROKER_URL|g" -- "$TEMPLATE_SERVICE"  > "$SERVICE_OUTPUT"

sudo mv "$SERVICE_OUTPUT" /etc/systemd/system
sudo systemctl daemon-reload 
sudo systemctl enable msk-proxy
sudo service msk-proxy restart

echo "Done!"
