#!/usr/bin/env bash
set -euo pipefail

USER="$1"
PUBKEY="$2"
GROUP="mfa_pending"

if [[ -z "$USER" || -z "$PUBKEY" ]]; then
    echo "Usage: add-bastion-user.sh <username> <pubkey>"
    exit 1
fi

echo "[+] Creating user: $USER"

# ✅ 建立 user（無密碼）
if ! id "$USER" &>/dev/null; then
    adduser --disabled-password --gecos "" "$USER"
fi

# ✅ 建立 ssh dir
HOME_DIR="/home/$USER"
SSH_DIR="$HOME_DIR/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown -R "$USER:$USER" "$SSH_DIR"

# ✅ 寫入 enrollment key（限制 command）
cat > "$SSH_DIR/authorized_keys" <<EOF
command="/usr/local/bin/mfa-enroll-wrapper.sh",no-agent-forwarding,no-port->
EOF

chmod 600 "$SSH_DIR/authorized_keys"
chown "$USER:$USER" "$SSH_DIR/authorized_keys"
#!/usr/bin/env bash
set -euo pipefail

USER="$1"
PUBKEY="$2"
GROUP="mfa_pending"

if [[ -z "$USER" || -z "$PUBKEY" ]]; then
    echo "Usage: add-bastion-user.sh <username> <pubkey>"
    exit 1
fi

echo "[+] Creating user: $USER"

# ✅ 建立 user（無密碼）
if ! id "$USER" &>/dev/null; then
    adduser --disabled-password --gecos "" "$USER"
fi

# ✅ 建立 ssh dir
HOME_DIR="/home/$USER"
SSH_DIR="$HOME_DIR/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown -R "$USER:$USER" "$SSH_DIR"

# ✅ 寫入 enrollment key（限制 command）
cat > "$SSH_DIR/authorized_keys" <<EOF
command="/usr/local/bin/mfa-enroll-wrapper.sh",no-agent-forwarding,no-port->
EOF

chmod 600 "$SSH_DIR/authorized_keys"
chown "$USER:$USER" "$SSH_DIR/authorized_keys"

# ✅ 加入 mfa_pending
usermod -aG "$GROUP" "$USER"

# ✅ audit
logger -t bastion-audit "USER_CREATED user=$USER by=$(whoami)"
logger -t bastion-audit "USER_ADDED_TO_GROUP user=$USER group=$GROUP"

echo "[+] User $USER created and added to $GROUP"
