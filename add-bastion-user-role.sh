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

Example:
  $0 tommy Vtt70 "AAAAC3NzaC1lZDI1NTE5AAAA..."
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
    qc2|Vtt70|Vtt80)
        ;;
    *)
        echo "Invalid role"
        exit 1
        ;;
esac

#
# Required Groups
#
for grp in mfa_pending "$ROLE"; do
    getent group "$grp" >/dev/null || groupadd "$grp"
done

mkdir -p /etc/bastion
touch "$ROLE_FILE"

#
# Create User
#
echo "[+] Creating user: $USERNAME"

if ! id "$USERNAME" >/dev/null 2>&1; then

    adduser \
        --disabled-password \
        --gecos "" \
        "$USERNAME"

    echo "[+] User created"

else
    echo "[*] User already exists"
fi

#
# Add MFA onboarding group
#
if ! id -nG "$USERNAME" | grep -qw mfa_pending; then
    usermod -aG mfa_pending "$USERNAME"
fi

#
# Lock password
#
passwd -l "$USERNAME" >/dev/null 2>&1 || true

echo "[+] Added to group: mfa_pending"

#
# SSH directory
#
HOME_DIR="/home/$USERNAME"
SSH_DIR="$HOME_DIR/.ssh"

install -d \
    -m 700 \
    -o "$USERNAME" \
    -g "$USERNAME" \
    "$SSH_DIR"

#
# Enrollment key
#
cat > "$SSH_DIR/authorized_keys" <<EOF
command="/usr/local/bin/mfa-enroll-wrapper.sh",no-agent-forwarding,no-port-forwarding,no-X11-forwarding ssh-ed25519 $PUBKEY
EOF

chmod 600 "$SSH_DIR/authorized_keys"

chown \
    "$USERNAME:$USERNAME" \
    "$SSH_DIR/authorized_keys"

#
# Save final role
#
grep -v "^${USERNAME}:" "$ROLE_FILE" > /tmp/user-role.$$
mv /tmp/user-role.$$ "$ROLE_FILE"

echo "${USERNAME}:${ROLE}" >> "$ROLE_FILE"

#
# Audit
#
logger -t bastion-audit \
"USER_CREATED user=$USERNAME role=$ROLE"

logger -t bastion-audit \
"USER_ADDED_TO_MFA_PENDING user=$USERNAME role=$ROLE"

#
# Summary
#
echo
echo "====================================="
echo " User : $USERNAME"
echo " Role : $ROLE"
echo " State: MFA Pending"
echo "====================================="
echo
echo "Next Steps:"
echo "1. User login with SSH key"
echo "2. Scan Google Authenticator QR Code"
echo "3. MFA completed"
echo "4. Auto add role: $ROLE"
echo "5. Auto remove: mfa_pending"
echo
