#!/usr/bin/env bash

set -euo pipefail

ROLE_FILE="/etc/bastion/user-role.conf"

usage() {
    cat <<EOF
Usage:
  $0 <username> <role> <publickey>

Roles:
  qc2
  Vtt70
  Vtt80
EOF
    exit 1
}

[[ $# -eq 3 ]] || usage

USERNAME="$1"
ROLE="$2"
PUBKEY="$3"

#
# Username Policy
#
if ! [[ "$USERNAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    echo "Invalid username"
    exit 1
fi

#
# Role Check
#
case "$ROLE" in
    qc2|Vtt80|Vtt70)
        ;;
    *)
        echo "Invalid role"
        exit 1
        ;;
esac

#
# Required Group
#
getent group mfa_pending >/dev/null || groupadd mfa_pending

#
# Create User
#
echo "[+] Creating user: $USER"

if ! id "$USER" >/dev/null 2>&1; then
    adduser \
        --disabled-password \
        --gecos "" \
        "$USER"
fi

# 防呆，確保帳號沒有可用密碼
passwd -l "$USER" >/dev/null 2>&1 || true

#
# SSH
#
install -d -m 700 \
    -o "$USERNAME" \
    -g "$USERNAME" \
    "/home/$USERNAME/.ssh"

cat > "/home/$USERNAME/.ssh/authorized_keys" <<EOF
command="/usr/local/bin/mfa-enroll-wrapper.sh",no-agent-forwarding,no-port-forwarding,no-X11-forwarding $PUBKEY
EOF

chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh/authorized_keys"

#
# Save Final Role
#
grep -v "^${USERNAME}:" "$ROLE_FILE" 2>/dev/null > /tmp/user-role.$$
mv /tmp/user-role.$$ "$ROLE_FILE"

echo "${USERNAME}:${ROLE}" >> "$ROLE_FILE"

logger -t bastion-audit \
    "USER_CREATED user=$USERNAME role=$ROLE"

echo
echo "====================================="
echo " User : $USERNAME"
echo " Role : $ROLE"
echo " State: MFA Pending"
echo "====================================="
