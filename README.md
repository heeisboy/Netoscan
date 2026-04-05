# Netoscan

Скрипт для поиска активных хостов в локальной сети через **arping** (L2, ARP). Запуск только от **root** (`sudo`).

## Модель адреса

Адрес задаётся как `PREFIX.SUBNET.HOST`:

| Часть   | Значение                          |
|---------|-----------------------------------|
| **PREFIX**  | первые два октета, например `192.168` |
| **SUBNET**  | третий октет (0–255)                  |
| **HOST**    | четвёртый октет (0–255)               |

## Зависимости

- `bash`
- `arping` (пакет обычно называется `iputils-arping` или `arping`)

## Использование

```text
./netoscan.sh PREFIX INTERFACE [SUBNET [HOST]]
```

| Аргументы | Что сканируется |
|-----------|-------------------|
| только `PREFIX` и `INTERFACE` | `PREFIX.[0–255].[0–255]` |
| + `SUBNET` | `PREFIX.SUBNET.[0–255]` |
| + `HOST` | один адрес `PREFIX.SUBNET.HOST` |

Примеры:

```bash
sudo ./netoscan.sh 192.168 eth0
sudo ./netoscan.sh 192.168 eth0 1
sudo ./netoscan.sh 192.168 eth0 1 10
```
