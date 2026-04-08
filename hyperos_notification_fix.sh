#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${BLUE}======================================================"
echo -e "       HYPEROS NOTIFICATION & POWER OPTIMIZER       "
echo -e "======================================================${NC}"

echo -e "${YELLOW}[!] PREREQUISITES & IMPORTANT INSTRUCTIONS:${NC}"
echo -e "${BLUE}1. SETUP GUIDE:${NC}"
echo -e "   - ${WHITE}Option A (Try First):${NC} Install 'Carrier Services', log in to your social apps,"
echo -e "     and follow steps 2-4. If it works, no reset needed."
echo -e "   - ${WHITE}Option B (Recommended for Stability):${NC} Perform a ${RED}FACTORY RESET${NC}."
echo -e "     After reset: Login to Mi Account, update system apps via GetApps,"
echo -e "     turn on 'Basic Google Services', login Google account, Install Google apps,"
echo -e "     ensure Google Play Services is up-to-date, install 'Carrier Services' & enable it."
echo -e ""
echo -e "${BLUE}2. PERMISSIONS:${NC} Grant ${GREEN}ALL${NC} permissions to messaging apps & Carrier Services."
echo -e "${BLUE}3. AUTOSTART:${NC} Turn ${GREEN}ON${NC} 'Autostart' for Google Apps, Social Apps, & Carrier Services."
echo -e "${BLUE}4. BATTERY:${NC} Set Battery Saver to ${GREEN}'No Restrictions'${NC} for all these apps."
echo -e "------------------------------------------------------"

APPS=(
    "com.google.android.gms"
    "com.google.android.gsf"
    "com.google.android.ims"
    "com.google.android.gm"
)

echo -e "${GREEN}Enter additional package names (e.g., com.whatsapp,com.facebook.orca).${NC}"
echo -e "${YELLOW}Separate multiple apps with a comma:${NC}"
read -p ">> " USER_INPUT

if [[ -n "$USER_INPUT" ]]; then
    IFS=',' read -ra ADDS <<< "$USER_INPUT"
    for i in "${ADDS[@]}"; do
        CLEAN_APP=$(echo "$i" | tr -d ' ')
        [[ -n "$CLEAN_APP" ]] && APPS+=("$CLEAN_APP")
    done
fi

UNIQUE_APPS=($(printf "%s\n" "${APPS[@]}" | sort -u))

adb get-state 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Device not found. Please connect via ADB and enable Debugging.${NC}"
    exit 1
fi

echo -e "\n${BLUE}[PHASE 1] Syncing Cloud Low Latency Whitelist...${NC}"
CURRENT_LL_LIST=$(adb shell settings get system cloud_lowlatency_whitelist)
[[ "$CURRENT_LL_LIST" == "null" || -z "$CURRENT_LL_LIST" ]] && CURRENT_LL_LIST=""

UPDATED_LL_LIST=$CURRENT_LL_LIST
ADDED_LL_COUNT=0

for APP in "${UNIQUE_APPS[@]}"; do
    if echo "$CURRENT_LL_LIST" | grep -qE "(^|,)$APP($|,)"; then
        echo -e "${NC}[-] EXISTS: $APP"
    else
        echo -e "${GREEN}[+] ADDING: $APP${NC}"
        if [[ -z "$UPDATED_LL_LIST" ]]; then
            UPDATED_LL_LIST="$APP"
        else
            UPDATED_LL_LIST="$UPDATED_LL_LIST,$APP"
        fi
        ((ADDED_LL_COUNT++))
    fi
done

if [ $ADDED_LL_COUNT -gt 0 ]; then
    CLEAN_LL_LIST=$(echo "$UPDATED_LL_LIST" | sed -E 's/^,+|,+$//g; s/,+/,/g')
    adb shell settings put system cloud_lowlatency_whitelist "$CLEAN_LL_LIST"
    echo -e "${GREEN}>>> SUCCESS: Low Latency list updated.${NC}"
else
    echo -e "${YELLOW}>>> INFO: No new apps needed for Low Latency list.${NC}"
fi

echo -e "\n${BLUE}[PHASE 2] Updating Battery Whitelist (DeviceIdle)...${NC}"
CURRENT_IDLE_LIST=$(adb shell dumpsys deviceidle whitelist)
for APP in "${UNIQUE_APPS[@]}"; do
    if echo "$CURRENT_IDLE_LIST" | grep -qw "$APP"; then
        echo -e "${NC}[-] EXISTS: $APP"
    else
        echo -e "${GREEN}[+] WHITELISTING: $APP${NC}"
        adb shell cmd deviceidle whitelist +"$APP" > /dev/null
    fi
done

echo -e "\n${BLUE}[PHASE 3] Suspending Powerkeeper (Xiaomi Battery Daemon)...${NC}"
PK_CHECK=$(adb shell pm list packages -s | grep "com.miui.powerkeeper")

if [[ -z "$PK_CHECK" ]]; then
    echo -e "${GREEN}[+] SUSPENDING: com.miui.powerkeeper${NC}"
    adb shell pm suspend com.miui.powerkeeper
    echo -e "${GREEN}>>> SUCCESS: Powerkeeper suspended successfully.${NC}"
else
    echo -e "${YELLOW}[-] Powerkeeper is already SUSPENDED. Skipping...${NC}"
fi

echo -e "\n${BLUE}======================================================"
echo -e "${GREEN}PROCESS COMPLETE! PLEASE REBOOT YOUR DEVICE NOW.${NC}"
echo -e "------------------------------------------------------"
echo -e "${YELLOW}HOW TO RESTORE POWERKEEPER:${NC}"
echo -e "Run this command to undo suspension:"
echo -e "${WHITE}adb shell pm unsuspend com.miui.powerkeeper${NC}"
echo -e "======================================================${NC}"
