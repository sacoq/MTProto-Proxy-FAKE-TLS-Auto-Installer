#!/bin/bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

case "$1" in
    start)
        echo -e "${GREEN}Запуск прокси...${NC}"
        docker start mtproxy
        ;;
    stop)
        echo -e "${YELLOW}Остановка прокси...${NC}"
        docker stop mtproxy
        ;;
    restart)
        echo -e "${GREEN}Перезапуск прокси...${NC}"
        docker restart mtproxy
        ;;
    status)
        echo -e "${GREEN}Статус прокси:${NC}"
        docker ps --filter name=mtproxy
        ;;
    logs)
        echo -e "${GREEN}Логи прокси (Ctrl+C для выхода):${NC}"
        docker logs -f mtproxy
        ;;
    stats)
        echo -e "${GREEN}Статистика прокси:${NC}"
        docker exec mtproxy cat /data/stats 2>/dev/null || echo "Статистика недоступна"
        ;;
    info)
        if [ -f /root/mtproxy_info.txt ]; then
            cat /root/mtproxy_info.txt
        else
            echo -e "${RED}Файл с информацией не найден${NC}"
        fi
        ;;
    update)
        echo -e "${GREEN}Обновление прокси...${NC}"
        docker pull telegrammessenger/proxy:latest
        docker stop mtproxy
        docker rm mtproxy
        echo -e "${YELLOW}Запустите install_mtproxy.sh для переустановки${NC}"
        ;;
    help|--help|-h)
        echo "Использование: $0 {start|stop|restart|status|logs|stats|info|update}"
        echo ""
        echo "  start   - Запустить прокси"
        echo "  stop    - Остановить прокси"
        echo "  restart - Перезапустить прокси"
        echo "  status  - Показать статус"
        echo "  logs    - Показать логи"
        echo "  stats   - Показать статистику"
        echo "  info    - Показать информацию о прокси"
        echo "  update  - Обновить Docker образ"
        ;;
    *)
        echo -e "${RED}Ошибка: Неизвестная команда '$1'${NC}"
        echo "Используйте '$0 help' для списка команд"
        exit 1
        ;;
esac
