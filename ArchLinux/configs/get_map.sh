#!/bin/bash

# Объявляем ассоциативный массив
declare -A CONFIGS

# Заполняем массив построчно, используя eval для каждой строки
while IFS= read -r line; do
    eval "$line"
done < <(yq '
  to_entries | 
  map("CONFIGS[" + .key + "]=" + .value) | 
  .[]' confsPath.yaml | sed "s|~|$HOME|g")

# Проверяем результат
echo "=== Содержимое массива ==="
for key in "${!CONFIGS[@]}"; do
    echo "$key -> ${CONFIGS[$key]}"
done

# Проверяем существование файлов
echo -e "\n=== Проверка файлов ==="
for key in "${!CONFIGS[@]}"; do
    if [[ -f "${CONFIGS[$key]}" ]]; then
        echo "✅ $key: файл существует"
    else
        echo "❌ $key: файл НЕ существует"
    fi
done
