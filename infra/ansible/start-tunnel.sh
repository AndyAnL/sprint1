#!/bin/bash

# Проверка SSH ключа
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "❌ SSH ключ не найден: ~/.ssh/id_rsa"
  exit 1
fi

# Параметры
SSH_KEY="$HOME/.ssh/id_rsa"
SRV_IP="158.160.172.107"
SSH_USER="ubuntu"

# Проверка доступности сервера
if ! ping -c 1 $SRV_IP &> /dev/null; then
  echo "❌ Сервер $SRV_IP недоступен"
  exit 1
fi

# Проброс портов
PORTS=(
  "2222:192.168.10.10:22"   # k8s-master
  "2223:192.168.10.11:22"   # k8s-app
  "6443:192.168.10.10:6443" # Kubernetes API
)

# Формирование команды
SSH_CMD="ssh -i $SSH_KEY -N -f"
for port_map in "${PORTS[@]}"; do
  SSH_CMD+=" -L $port_map"
done
SSH_CMD+=" $SSH_USER@$SRV_IP"

# Запуск туннеля
echo "➜ Запуск SSH-туннеля..."
if eval $SSH_CMD; then
  echo "✅ Успешно! Туннель работает с PID: $(pgrep -f "$SSH_CMD")"
else
  echo "❌ Ошибка при запуске туннеля"
  exit 1
fi