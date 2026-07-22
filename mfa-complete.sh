#!/usr/bin/env bash

set -euo pipefail

LOG_TAG="bastion-audit"
GROUP="mfa_pending"

USER_NAME="${1:-}"

if [[ -z "$USER_NAME" ]]; then
    logger -t "$LOG_TAG" "MFA_COMPLETE_FAILED reason=no_user"
    exit 1
fi

#
# 使用者存在
#
id "$USER_NAME" >/dev/null 2>&1

#
# 必須在 mfa_pending
#
if ! id -nG "$USER_NAME" | grep -qw "$GROUP"; then
    logger -t "$LOG_TAG" \
        "MFA_COMPLETE_SKIPPED user=$USER_NAME reason=not_in_group"

    exit 1
fi

#
# 取得 home
#
HOME_DIR=$(getent passwd "$USER_NAME" | cut -d: -f6)

#
# MFA 必須存在
#
if [[ ! -f "$HOME_DIR/.google_authenticator" ]]; then

    logger -t "$LOG_TAG" \
        "MFA_COMPLETE_FAILED user=$USER_NAME reason=no_google_authenticator"

    exit 1
fi


# 加群組
TARGET_GROUP=$(
    awk -F: \
    -v u="$USER_NAME" \
    '$1==u{print $2}' \
    /etc/bastion/user-role.conf
)

if [[ -n "$TARGET_GROUP" ]]; then

    usermod -aG "$TARGET_GROUP" "$USER_NAME"

    logger -t bastion-audit \
        "ROLE_ASSIGNED user=$USER_NAME role=$TARGET_GROUP"

fi

#
# 移除 mfa_pending
#
gpasswd -d "$USER_NAME" "$GROUP" >/dev/null 2>&1

logger -t "$LOG_TAG" \
    "MFA_COMPLETE_SUCCESS user=$USER_NAME"

exit 0
