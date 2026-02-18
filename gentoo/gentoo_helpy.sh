# Обновления
emerge --ask --update --deep --newuse @world

# Обновление с build-time зависимостями
emerge --ask --update --deep --newuse --with-bdeps=y @world

# Очистка старых ненужны пакетов
emerge --ask --depclean

# Проверяет бинарные зависимости и пересобирает пакеты, если что-то сломалось после обновлений
revdep-rebuild

# Если собрал своё ядро вручную
genkernel all
