#!/bin/bash

# PREFIX = первые два октета (x.x), SUBNET = третий октет, HOST = четвёртый.

readonly RE_OCTET='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' # Регулярное выражение для проверки октета 
readonly RE_PREFIX='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' # Регулярное выражение для проверки префикса

trap "echo '--- Ctrl+C pressed, exiting ---'; exit 1" 2 # При получении сигнала прерывания выходим из скрипта

usage() { # Вывод справки по использованию скрипта
	echo "Usage: $0 PREFIX INTERFACE [SUBNET [HOST]]" >&2 
	echo "  PREFIX    — два октета IPv4, например 192.168" >&2 
	echo "  INTERFACE — сетевой интерфейс, например eth0" >&2
	echo "  SUBNET    — третий октет (0–255), необязательно" >&2
	echo "  HOST      — четвёртый октет (0–255), только вместе с SUBNET" >&2
	echo "Режимы: только PREFIX+INTERFACE — вся подсеть PREFIX.[0-255].[0-255];" >&2
	echo "        +SUBNET — PREFIX.SUBNET.[0-255]; +HOST — один адрес." >&2
}

if [[ $EUID -ne 0 ]]; then # Проверяем, от рута ли запущен скрипт
	echo "Error: run as root (sudo $0 ...) !" >&2
	exit 1
fi

octet_valid() { # Проверка, является ли строка октетом
	[[ "$1" =~ $RE_OCTET ]]
}

prefix_valid() { # Проверка, является ли строка префиксом
	[[ "$1" =~ $RE_PREFIX ]] 
}

scan_ip() { # Сканирование одного IP адреса
	local ip="$1"
	echo "[*] IP : $ip"
	arping -c 3 -i "$INTERFACE" "$ip" 2>/dev/null
}

scan_range_subnet_host() { # Сканирование диапазона IP адресов
	local s_start="$1" s_end="$2" h_start="$3" h_end="$4" 
	local s h 
	for ((s = s_start; s <= s_end; s++)); do # Сканирование по подсети
		for ((h = h_start; h <= h_end; h++)); do # Сканирование по хосту
			scan_ip "${PREFIX}.${s}.${h}" 
		done
	done
}

PREFIX="$1" 
INTERFACE="$2" 
SUBNET="${3-}"
HOST="${4-}"

if [[ $# -lt 2 || $# -gt 4 ]]; then # Проверка, переданы ли все необходимые аргументы
	usage
	exit 1
fi

if ! prefix_valid "$PREFIX"; then
	echo "Error: PREFIX must be two IPv4 octets (0–255), e.g. 192.168" >&2
	exit 1
fi
if [[ -z "$INTERFACE" ]]; then 
	echo "Error: INTERFACE must be passed as second argument" >&2
	exit 1
fi

case $# in 
	2) 
		scan_range_subnet_host 0 255 0 255
		;;
	3) 
		if ! octet_valid "$SUBNET"; then
			echo "Error: SUBNET must be one IPv4 octet (0–255)" >&2
			exit 1
		fi
		scan_range_subnet_host "$SUBNET" "$SUBNET" 0 255
		;;
	4)
		if ! octet_valid "$SUBNET" || ! octet_valid "$HOST"; then
			echo "Error: SUBNET and HOST must each be one IPv4 octet (0–255)" >&2
			exit 1
		fi
		scan_ip "${PREFIX}.${SUBNET}.${HOST}"
		;;
esac
