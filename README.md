# HyperOS Notification Fix (China ROM) 🚀

## 📌 Overview
This project provides a powerful ADB-based script to fix delayed or missing notifications on China HyperOS devices.

It solves issues caused by:
- Aggressive battery optimization
- MIUI/HyperOS PowerKeeper restrictions
- Background process killing
- Cloud low-latency restrictions

---

## ⚙️ Features
- Adds apps to **Low Latency Whitelist**
- Adds apps to **DeviceIdle (Battery) Whitelist**
- Suspends **PowerKeeper (MIUI battery daemon)**
- Supports custom apps (WhatsApp, Messenger, etc.)
- Works via **Termux** and **Linux**

---

## 📋 Prerequisites

### On Phone:
- Enable **Developer Options**
- Enable **USB Debugging**
- Install:
  - Google Play Services (updated)
  - Carrier Services
- Disable battery restrictions for apps

---

## 🧰 Setup Guide

### Option A (Quick Fix)
1. Install Carrier Services
2. Login to apps (WhatsApp, Messenger, etc.)
3. Continue setup

### Option B (Recommended - Stable)
1. Factory Reset device
2. Login Mi Account
3. Update system apps (GetApps)
4. Enable Basic Google Services
5. Login Google Account
6. Install Google apps
7. Update Google Play Services
8. Install & enable Carrier Services

---

## 💻 Usage on Linux (Fedora/Ubuntu/Kali)

### Step 1: Install ADB
```bash
sudo dnf install android-tools   # Fedora
sudo apt install adb             # Ubuntu/Debian
```

### Step 2: Connect Device
```bash
adb devices
```

### Step 3: Run Script
```bash
chmod +x hyperos_notification_fix.sh
./hyperos_notification_fix.sh
```

### Step 4: Input Apps
Example:
```
com.whatsapp,com.facebook.orca,com.instagram.android
```

---

## 📱 Usage on Termux (Android)

### Step 1: Install Packages
```bash
pkg update && pkg upgrade
pkg install android-tools git
```

### Step 2: Enable Wireless Debugging
- Turn ON Wireless Debugging in Developer Options
- Pair device:
```bash
adb pair IP:PORT
adb connect IP:PORT
```

### Step 3: Run Script
```bash
chmod +x hyperos_notification_fix.sh
./hyperos_notification_fix.sh
```

---

## 🔄 What Script Does

### Phase 1:
Adds apps to:
```
cloud_lowlatency_whitelist
```

### Phase 2:
Adds apps to:
```
deviceidle whitelist
```

### Phase 3:
Suspends:
```
com.miui.powerkeeper
```

---

## ⚠️ Important Notes
- Always reboot after running script
- Grant ALL permissions to apps
- Enable Autostart for apps
- Set Battery → No Restrictions

---

## ♻️ Restore PowerKeeper
```bash
adb shell pm unsuspend com.miui.powerkeeper
```

---

## 🧑‍💻 Author
Sourav Debnath

---

## ⭐ Contribute
Feel free to fork, improve, and submit pull requests.

---

## 📜 License
Open-source for educational and personal use.
