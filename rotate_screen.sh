#!/bin/bash

ARMBIAN_TXT="/boot/armbianEnv.txt"
TARGET_LINE="extraargs=fbcon=rotate:2"
XORG_CONF_DIR="/etc/X11/xorg.conf.d"
DEFAULTS_CONF="$XORG_CONF_DIR/01-armbian-defaults.conf"
SMARTPAD_CONF="$XORG_CONF_DIR/02-smartpad-rotate-screen.conf"

# Chercher et gérer la ligne extraargs=fbcon=rotate:2
if grep -q "extraargs=fbcon=rotate:2" "$ARMBIAN_TXT"; then
    sed -i '/extraargs=fbcon=rotate:2/d' "$ARMBIAN_TXT"

    if [ -f "$DEFAULTS_CONF" ]; then
        cat <<EOL > "$DEFAULTS_CONF"
# Default Armbian config
Section "InputClass"
    Identifier "evdev touchscreen catchall"
    MatchIsTouchscreen "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    Option "InvertY" "false"
    Option "InvertX" "false"
EndSection
EOL
    fi

    if [ -f "$SMARTPAD_CONF" ]; then
        echo "" > "$SMARTPAD_CONF"
    fi
else
    echo "$TARGET_LINE" >> "$ARMBIAN_TXT"

    cat <<EOL > "$DEFAULTS_CONF"
# Default Armbian config
EOL

    cat <<EOL > "$SMARTPAD_CONF"
Section "Device"
    Identifier  "default"
    Driver      "fbdev"
    Option      "Rotate" "UD"
EndSection
EOL
fi

echo "Screen rotation : ok"

# Reboot
reboot
