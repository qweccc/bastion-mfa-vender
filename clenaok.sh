#!/usr/bin/env bash
set -euo pipefail

GROUP="mfa_pending"
LOG_TAG="bastion-audit"

getent group "$GROUP" \
| awk -F: '{print $4}' \
| tr ',' '\n' \
| while read -r USER
do
    [ -z "$USER" ] && continue

    GA_FILE="/home/$USER/.google_authenticator"

    if [[ -f "$GA_FILE" ]]; then

        if gpasswd -d "$USER" "$GROUP" >/dev/null 2>&1; then
            logger -t "$LOG_TAG" \
                "AUTO_GROUP_REMOVED user=$USER"
        else
            logger -t "$LOG_TAG" \
                "AUTO_GROUP_REMOVE_FAILED user=$USER"
        fi
    fi
done
