# 🚀 MTProto Proxy Auto Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Telegram](https://img.shields.io/badge/Telegram-MTProto-blue.svg)](https://core.telegram.org/mtproto)

Автоматическая установка MTProto прокси с поддержкой **Fake TLS** для обхода блокировок. Прокси маскирует трафик под обычный HTTPS, что делает его трудным для обнаружения DPI системами.

## 📋 Особенности

- ✅ **Fake TLS режим** - маскировка трафика под HTTPS
- ✅ **Автоматическая установка** Docker и зависимостей
- ✅ **Генерация случайного секрета** (32 hex символа)
- ✅ **Настройка фаервола** (UFW/firewalld)
- ✅ **Автоматический перезапуск** при падении
- ✅ **Сохранение информации** в файл
- ✅ **Простое управление** через скрипты

## 📦 Требования

- VPS/Выделенный сервер с Linux (Ubuntu/Debian/CentOS)
- Минимум 256MB RAM
- Открытый порт 443 (или любой другой)
- Root доступ

## 🚀 Быстрая установка

```bash
# Скачать и запустить установщик
wget -O install.sh https://raw.githubusercontent.com/ваш-username/mtproxy-installer/main/install_mtproxy.sh
chmod +x install.sh
sudo ./install.sh
