# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_step() { echo -e "\n${GREEN}========================================${NC}\n${GREEN}➜ $1${NC}\n${GREEN}========================================${NC}\n"; }

# Очистка экрана
clear

# Приветствие
echo -e "${GREEN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     MTProto Proxy Auto Installer with Fake TLS v2.0         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
    print_error "Этот скрипт должен запускаться с правами root (sudo)"
    exit 1
fi

# Получение внешнего IP
print_step "Определение IP адреса сервера"
echo "Выберите способ определения IP:"
echo "1) Автоматически IPv4 (рекомендуется)"
echo "2) Ввести вручную"
echo "3) Использовать IPv6"
read -p "Ваш выбор [1-3]: " ip_choice

case $ip_choice in
    1)
        SERVER_IP=$(curl -s -4 ifconfig.me 2>/dev/null || curl -s -4 icanhazip.com 2>/dev/null)
        if [[ -z "$SERVER_IP" ]]; then
            print_error "Не удалось определить IP автоматически"
            read -p "Введите IP вручную: " SERVER_IP
        fi
        ;;
    2)
        read -p "Введите IP адрес сервера: " SERVER_IP
        ;;
    3)
        SERVER_IP=$(curl -s -6 ifconfig.me 2>/dev/null)
        if [[ -z "$SERVER_IP" ]]; then
            print_error "IPv6 не обнаружен"
            exit 1
        fi
        ;;
esac

print_success "IP адрес: $SERVER_IP"

# Проверка порта
print_step "Проверка порта 443"
if lsof -i :443 &>/dev/null; then
    print_warning "Порт 443 уже используется!"
    lsof -i :443
    read -p "Использовать другой порт? (y/n): " change_port
    if [[ "$change_port" == "y" ]]; then
        read -p "Введите порт: " PROXY_PORT
    else
        PROXY_PORT=443
    fi
else
    PROXY_PORT=443
fi

# Установка Docker
print_step "Установка Docker"
if ! command -v docker &> /dev/null; then
    print_info "Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    print_success "Docker установлен"
else
    print_success "Docker уже установлен"
fi

systemctl start docker
systemctl enable docker

# Настройка фаервола
print_step "Настройка фаервола"
if command -v ufw &> /dev/null; then
    ufw allow $PROXY_PORT/tcp
    ufw allow 22/tcp
    echo "y" | ufw enable &>/dev/null
    print_success "UFW настроен"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=$PROXY_PORT/tcp
    firewall-cmd --reload
    print_success "Firewalld настроен"
fi

# Генерация секрета
print_step "Генерация Fake TLS секрета"
SECRET="ee$(openssl rand -hex 15)"
print_success "Секрет сгенерирован: $SECRET"

# Регистрация в боте
print_step "Регистрация в @MTProxybot"
echo -e "${YELLOW}Для регистрации прокси:${NC}"
echo ""
echo "1. Откройте Telegram → @MTProxybot"
echo "2. Отправьте команду /newproxy"
echo "3. Введите IP: $SERVER_IP"
echo "4. Введите порт: $PROXY_PORT"
echo "5. Введите секрет: $SECRET"
echo ""
read -p "Введите TAG от @MTProxybot после регистрации: " TAG

if [[ -z "$TAG" ]]; then
    print_error "TAG не может быть пустым!"
    exit 1
fi

# Остановка старого контейнера
if docker ps -a --format '{{.Names}}' | grep -q "^mtproxy$"; then
    print_info "Удаление старого контейнера..."
    docker stop mtproxy &>/dev/null
    docker rm mtproxy &>/dev/null
fi

# Создание volume
docker volume create mtproxy-data &>/dev/null

# Запуск контейнера
print_step "Запуск MTProto прокси"
docker run -d \
  --name=mtproxy \
  --restart=unless-stopped \
  -p $PROXY_PORT:443 \
  -v mtproxy-data:/data \
  -e SECRET="$SECRET" \
  -e TAG="$TAG" \
  telegrammessenger/proxy:latest

if [ $? -eq 0 ]; then
    print_success "Контейнер успешно запущен!"
else
    print_error "Ошибка при запуске контейнера"
    exit 1
fi

sleep 3

# Проверка статуса
if docker ps --format '{{.Names}}' | grep -q "^mtproxy$"; then
    print_success "Прокси работает"
    docker logs --tail 10 mtproxy
else
    print_error "Прокси не запустился!"
    docker logs mtproxy
    exit 1
fi

# Создание ссылок
TG_LINK="tg://proxy?server=$SERVER_IP&port=$PROXY_PORT&secret=$SECRET"
WEB_LINK="https://t.me/proxy?server=$SERVER_IP&port=$PROXY_PORT&secret=$SECRET"

# Сохранение информации
cat > /root/mtproxy_info.txt << EOF
========================================
MTProxy Fake TLS информация
========================================
Дата установки: $(date)
IP сервера: $SERVER_IP
Порт: $PROXY_PORT
Секрет: $SECRET
TAG: $TAG

Ссылки:
$TG_LINK
$WEB_LINK

Команды управления:
- Просмотр логов: docker logs -f mtproxy
- Статус: docker ps | grep mtproxy
- Статистика: docker exec mtproxy cat /data/stats
- Перезапуск: docker restart mtproxy
- Остановка: docker stop mtproxy
========================================
EOF

# Вывод результата
print_step "УСТАНОВКА ЗАВЕРШЕНА! 🎉"
echo -e "${GREEN}✅ Прокси успешно настроен!${NC}"
echo ""
echo -e "${YELLOW}📱 Ссылка для Telegram:${NC}"
echo -e "${BLUE}$TG_LINK${NC}"
echo ""
echo -e "${YELLOW}🌐 Web ссылка:${NC}"
echo -e "${BLUE}$WEB_LINK${NC}"
echo ""
echo -e "${YELLOW}🔑 Секретный ключ:${NC}"
echo -e "${BLUE}$SECRET${NC}"
echo ""
echo -e "${YELLOW}🏷️  Рекламный TAG:${NC}"
echo -e "${BLUE}$TAG${NC}"
echo ""
echo -e "${YELLOW}📁 Информация сохранена:${NC}"
echo -e "/root/mtproxy_info.txt"
echo ""
echo -e "${YELLOW}📊 Команды управления:${NC}"
echo -e "docker logs -f mtproxy    # Просмотр логов"
echo -e "docker exec mtproxy cat /data/stats  # Статистика"
echo ""

# Вопрос о проверке порта
read -p "Проверить доступность порта? (y/n): " check_port
if [[ "$check_port" == "y" ]]; then
    if command -v nc &> /dev/null; then
        nc -zv $SERVER_IP $PROXY_PORT 2>&1
    fi
fi
