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

gpasswd -d "$USER_NAME" mfa_pending

logger -t bastion-audit \
    "MFA_COMPLETE_SUCCESS user=$USER_NAME"
