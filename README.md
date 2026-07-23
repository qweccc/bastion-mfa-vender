# bastion-mfa-vender
跳板機流程

建立帳號
↓
加入 mfa_pending
↓
第一次登入
↓
QR Code Enrollment
↓
mfa-complete.sh
    ├─ 加入目標群組(Vtt70/internal/vendor_a/vendor_b)
    └─ 移除 mfa_pending
↓
重新登入
↓
Key + OTP
↓
套用最終權限


add-bastion-user.sh
clenaok.sh
mfaok.sh
/usr/local/bin/mfa-enroll-wrapper.sh
/etc/bastion/user-role.conf
/usr/local/sbin/
mfa-cleanup.sh
mfa-complete.sh
tunnel-only


---常用指令
sudo sshd -t
sudo systemctl reload ssh
addgroup
deluser
getent group
sudo userdel -r vtest
sudo kill -9 1579916
sudo usermod -rG Vtt70 vtest 移除群組
sudo usermod -aG Vtt70 vtest 加入群組
sudo journalctl -f
sudo journalctl -t bastion-audit
sudo journalctl -t ssh
sudo journalctl -t sudo
