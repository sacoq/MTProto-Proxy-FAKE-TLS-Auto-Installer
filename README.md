# 🚀 MTProto Proxy Fake TLS Auto Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Telegram](https://img.shields.io/badge/Telegram-MTProto-blue.svg)](https://core.telegram.org/mtproto)
[![Platform](https://img.shields.io/badge/platform-Linux%20|%20Ubuntu%20|%20Debian%20|%20CentOS-green.svg)](https://www.linux.org/)

Автоматический установщик MTProto прокси с **Fake TLS** для обхода блокировок и DPI систем.

## ✨ Особенности

- 🎭 **Fake TLS режим** - маскировка трафика под HTTPS
- 🤖 **Полная автоматизация** - установка Docker, зависимостей, настройка фаервола
- 🔑 **Генерация случайного секрета** (32 hex символа с префиксом `ee`)
- 🔄 **Автоматический перезапуск** при падении
- 💾 **Сохранение информации** в файл `/root/mtproxy_info.txt`
- 🛡️ **Изолированный запуск** в Docker контейнере
- 📊 **Мониторинг статистики** использования
- 🚀 **Простое управление** через скрипты

## 📋 Требования

- VPS/Выделенный сервер с Linux (Ubuntu 18.04+, Debian 10+, CentOS 8+)
- Минимум 256MB RAM
- Открытый порт 443 (можно изменить)
- Root доступ

## 🚀 Быстрая установка (Одна команда)

```bash
bash <(curl -s https://raw.githubusercontent.com/sacoq/MTProto-Proxy-FAKE-TLS-Auto-Installer/main/install_mtproxy.sh)
