Table 1 — Troublshooting script

| Command | Description |
| --- | --- |
|`ip addr` |	проверка на совпадения ip адреса сервера и доступности интерфейса |
|`ps -aux \| grep <...>` | запущено ли приложение |
|`netstat -plunt \| grep <...>` | проверить доступность порта |
|`htop` | проверить загрузку памяти Load Average (1, 5, 15), процессы |
|`free -m` | доступная память в g, m, b|
|`var/logs` | общая папка хранения логов|
|`path/to/app` | логи самого приложения|
|`dmesg \| tail` | утилита выводит сообщения ядра|
|`journald` | Systemd централизует управление логированием с помощью демона journald|
|`journald -b -1` | Вывести после последней перезагрузки|
|`journalctl -b`|  |	
|`df -h` | данные о дисках в human readable|
|`iostat -xz 1` | сведения об объёме прочитанных и записанных данных для устройства, покажет среднее время операций ввода-вывода в миллисекундах|
