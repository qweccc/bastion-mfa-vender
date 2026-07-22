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

