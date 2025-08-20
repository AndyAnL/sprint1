#!/bin/bash

# Проверка активных туннелей
TUNNEL_PIDS=$(pgrep -f "ssh -i $HOME/.ssh/id_rsa -N -f -L")

if [ -z "$TUNNEL_PIDS" ]; then
  echo "ℹ️ Нет активных SSH-туннелей для отключения"
  exit 0
fi

# Вывод информации перед отключением
echo "Активные туннели (PID):"
ps -fp $TUNNEL_PIDS | awk 'NR>1 {print $2, $9}'

# Безопасное отключение
echo -e "\n➜ Остановка туннелей..."
for pid in $TUNNEL_PIDS; do
  if kill -TERM $pid; then
    echo "✅ Успешно остановлен процесс $pid"
  else
    echo "❌ Не удалось остановить процесс $pid"
  fi
done

# Финальная проверка
REMAINING=$(pgrep -f "ssh -i $HOME/.ssh/id_rsa -N -f -L" || true)
[ -z "$REMAINING" ] && echo "✔ Все туннели отключены" || echo "⚠ Остались процессы: $REMAINING"