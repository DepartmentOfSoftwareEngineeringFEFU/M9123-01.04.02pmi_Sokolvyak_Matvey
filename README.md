# Применение технологии SDN для организациикомпьютерных сетей с общедоступной базой данных 
#Научный руководитель: Цуканво Д.А. Профессор Департамента ДИКС, доктор физико-математических наук
##Автор работы-Сокольвяк Матвей Григорьевич
##🚀 Технологический стек
- Ubuntu 20.04/22.04 (рекомендуется)
- Python 3.8+
- Mininet 2.3+
- PostgreSQL 12+
- Suricata IDS
- sFlow-RT (опционально)

## 🛠️ Настройка и запуск 
1.Установка Mininet
```bash
git clone git://github.com/mininet/mininet
cd mininet
git tag  # Выберите последнюю стабильную версию (например 2.3.0)
git checkout -b 2.3.0 2.3.0
util/install.sh -nfv
```
2.Настройка PostgreSQL
```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
sudo -u postgres createdb cars_data
```
3. Установка Suricata
   ```bash
   sudo apt install -y suricata
    sudo suricata-update
    sudo systemctl enable suricata
   ```
4.Клонирование репозитория
```bash
git clone <ваш-репозиторий>
cd <ваш-репозиторий>
```
5. Импорт данных в PostgreSQL
   ```bash
   sudo -u postgres psql -f cars_data.sql
   ```
6.Запуск топлогии Mininet
```bash
sudo python3 Topo.py
```
#Основные в Mininet
*pingall - проверить связность

*nodes - список узлов

*net - отобразить сетевые соединения

*xterm <имя_узла> - открыть терминал на узле

#Остановка окружения#
1.В CLI Mininet: exit
2.Остановить sFlow-RT (если запущен): ./stop.sh
3.Остановить Suricata: sudo systemctl stop suricata
