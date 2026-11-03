#!/usr/bin/env bash
set -euo pipefail

# Configura la Brother DCP-T220 mediante IPP-over-USB (servicio ipp-usb).
PRINTER='Brother_DCP_T220'
URI='ipp://Brother%20DCP-T220%20(USB)._ipp._tcp.local/'

if ! command -v lpadmin >/dev/null || ! command -v lpstat >/dev/null; then
  echo 'No encuentro lpadmin/lpstat. Instala CUPS antes de continuar.' >&2
  exit 1
fi

if ! systemctl is-active --quiet ipp-usb; then
  echo 'El servicio ipp-usb no está activo. Inícialo y vuelve a ejecutar este script:' >&2
  echo '  sudo systemctl enable --now ipp-usb' >&2
  exit 1
fi

echo "Configurando $PRINTER con $URI"
# -E habilita la impresora y acepta trabajos; -m everywhere usa IPP Everywhere.
lpadmin -p "$PRINTER" -E -v "$URI" -m everywhere
cupsenable "$PRINTER"
cupsaccept "$PRINTER"

echo
lpstat -p "$PRINTER" -l
echo "Cola lista: $PRINTER. No se ha cambiado la impresora predeterminada."
