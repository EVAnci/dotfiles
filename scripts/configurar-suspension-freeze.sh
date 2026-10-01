#!/usr/bin/env bash
# Configura la suspensión de systemd para usar el estado Linux "freeze"
# (suspend-to-idle), y permite despertar con el teclado y el touchpad internos.
#
# Uso:
#   sudo ./configurar-suspension-freeze.sh

set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
    printf 'Este script debe ejecutarse como root: sudo %s\n' "$0" >&2
    exit 1
fi

sleep_dropin='/etc/systemd/sleep.conf.d/g10.conf'
udev_rule='/etc/udev/rules.d/99-g10-wakeup.rules'

backup_if_needed() {
    local file=$1
    if [[ -e $file ]] && ! cmp -s "$2" "$file"; then
        local backup="${file}.bak.$(date +%Y%m%d-%H%M%S)"
        cp -a -- "$file" "$backup"
        printf 'Copia de seguridad: %s\n' "$backup"
    fi
}

tmp_sleep=$(mktemp)
tmp_udev=$(mktemp)
trap 'rm -f "$tmp_sleep" "$tmp_udev"' EXIT

cat >"$tmp_sleep" <<'EOF'
[Sleep]
# suspend-to-idle; no usa el estado ACPI S3/deep
SuspendState=freeze
EOF

cat >"$tmp_udev" <<'EOF'
# Teclado interno (serio0) y touchpad interno (serio1):
# permitir que ambos despierten el equipo desde freeze.
ACTION=="add", SUBSYSTEM=="serio", KERNEL=="serio0", ATTR{power/wakeup}="enabled"
ACTION=="add", SUBSYSTEM=="serio", KERNEL=="serio1", ATTR{power/wakeup}="enabled"
EOF

mkdir -p "$(dirname "$sleep_dropin")" "$(dirname "$udev_rule")"
backup_if_needed "$sleep_dropin" "$tmp_sleep"
backup_if_needed "$udev_rule" "$tmp_udev"
install -o root -g root -m 0644 "$tmp_sleep" "$sleep_dropin"
install -o root -g root -m 0644 "$tmp_udev" "$udev_rule"

# Aplicar inmediatamente, además de dejarlo persistente para futuros arranques.
udevadm control --reload-rules
udevadm trigger --subsystem-match=serio --action=add

printf '\nConfiguración instalada. Estado actual:\n'
printf '%s\n' "  SuspendState: $(awk -F= '/^[[:space:]]*SuspendState=/{print $2; exit}' "$sleep_dropin")"
for device in /sys/devices/platform/i8042/serio{0,1}/power/wakeup; do
    if [[ -e $device ]]; then
        printf '  %s: %s\n' "$device" "$(cat "$device")"
    else
        printf '  %s: no disponible en este equipo\n' "$device"
    fi
done

printf '\nPrueba manual sugerida: sudo rtcwake -m freeze -s 60\n'
