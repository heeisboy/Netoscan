#!/bin/bash

PREFIX="${1:-NOT_SET}"
INTERFACE="$2"

trap "echo '--- Ctrl+C pressed, exiting ---'; exit 1" 2 # При получении сигнала прерывания выходим из скрипта

if [[ $EUID -ne 0 ]]; then  # Проверяем, запущен ли скрипт от имени root, если не запущен, выводим предупреждение и выходим из скрипта
	echo "Error: run as root (sudo $0 ...) !" >&2
    exit 1
fi

[[ "$PREFIX" = "NOT_SET" ]] && { echo "\$PREFIX must be passed as first positional argument"; exit 1; }
if [[ -z "$INTERFACE" ]]; then
    echo "\$INTERFACE must be passed as second positional argument"
    exit 1
fi

for SUBNET in {1..255}
do
	for HOST in {1..255}
	do
		echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
		arping -c 3 -i "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
	done
done