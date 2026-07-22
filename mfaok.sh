for u in $(getent group mfa_pending | awk -F: '{print $4}' | tr ',' ' '); do
    if [ -f "/home/$u/.google_authenticator" ]; then
        echo "✅ $u"
    else
        echo "❌ $u"
    fi
done
