Part 1. Preparation
===
```bash
# CentOS
yum groupinstall -y "Development Tools"
yum install -y ncurses-devel libncurses-devel openssl-devel bc hmaccalc zlib0devel binutils-devel elfutils-libelf-devel

# Ubuntu
apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev isolinux genisoimage
```

| Command | Description |
| --- | --- |
|`Development Tools (CentOS)`, `build-essential (Ubuntu)`|библиотека включающая в себя утилиты для сборки|
|`libncurses`|библиотека управления вводом-выводом на терминал|
|`flex`|[Fast Lexical Analyzer](https://habr.com/post/99162/) - генератор лексических анализаторов |
|`bison`|[GNU Bison](https://habr.com/post/99366/)  - программа, предназначенная для автоматического создания синтаксических анализаторов по данному описанию грамматики|
|`isolinux`|создание загрузочных образов|
|`genisoimage`|создание ISO образов|

```bash
mkdir /etc/kernal-build/ ; cd /etc/kernal-build/
wget /https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.7.tar.xz
tar -Jvxf linux-5.3.7.tar.xz ; cd linux-5.3.7
```

Part 2. Build
===
Preparation
---
Чтобы посмотреть возможные операции с ***Makefile*** в текущей дирректории следует выполнить:

```bash
make help
```

Step 1 - menuconfig
---

Чтобы выбрать необходимые модули/библиотеки/опции дял сборки ядра следует выполнить следующую команду:

```bash
make menuconfig
```

<details>
    <summary>make menuconfig output</summary>
    

    .config - Linux/x86 5.3.7 Kernel Configuration
    ────────────────────────────────────────────────────────────────────────────────────────────
    ┌──────────────────────── Linux/x86 5.3.7 Kernel Configuration ─────────────────────────┐
    │  Arrow keys navigate the menu.  <Enter> selects submenus ---> (or empty submenus      │
    │  ----).  Highlighted letters are hotkeys.  Pressing <Y> includes, <N> excludes, <M>   │
    │  modularizes features.  Press <Esc><Esc> to exit, <?> for Help, </> for Search.       │
    │  Legend: [*] built-in  [ ] excluded  <M> module  < > module capable                   │
    │ ┌───────────────────────────────────────────────────────────────────────────────────┐ │
    │ │          *** Compiler: gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-39) ***            │ │
    │ │          General setup  --->                                                      │ │
    │ │      [*] 64-bit kernel                                                            │ │
    │ │          Processor type and features  --->                                        │ │
    │ │          Power management and ACPI options  --->                                  │ │
    │ │          Bus options (PCI etc.)  --->                                             │ │
    │ │          Binary Emulations  --->                                                  │ │
    │ │          Firmware Drivers  --->                                                   │ │
    │ │      [*] Virtualization  --->                                                     │ │
    │ │          General architecture-dependent options  --->                             │ │
    │ │      [*] Enable loadable module support  --->                                     │ │
    │ │      -*- Enable the block layer  --->                                             │ │
    │ │          IO Schedulers  --->                                                      │ │
    │ │          Executable file formats  --->                                            │ │
    │ │          Memory Management options  --->                                          │ │
    │ │      [*] Networking support  --->                                                 │ │
    │ │          Device Drivers  --->                                                     │ │
    │ │          File systems  --->                                                       │ │
    │ │          Security options  --->                                                   │ │
    │ │      -*- Cryptographic API  --->                                                  │ │
    │ │          Library routines  --->                                                   │ │
    │ │          Kernel hacking  --->                                                     │ │
    │ │                                                                                   │ │
    │ └───────────────────────────────────────────────────────────────────────────────────┘ │
    ├───────────────────────────────────────────────────────────────────────────────────────┤
    │               <Select>    < Exit >    < Help >    < Save >    < Load >                │
    └───────────────────────────────────────────────────────────────────────────────────────┘
  </details> 

Все изменения вносятся в файл _.config_, который находится в распакованной директория

```bash
[devops@CentOS linux-5.3.7]$ ls -al
total 2092132
drwxrwxr-x.  24 devops devops      4096 Oct 17 21:39 .
drwxrwxr-x.   3 devops devops        51 Oct 17 19:09 ..
-rw-rw-r--.   1 devops devops     15318 Oct 17 20:47 .clang-format
-rw-rw-r--.   1 devops devops        59 Oct 17 20:47 .cocciconfig
-rw-rw-r--.   1 devops devops    197780 Oct 17 19:33 .config
<...>
```

Перед сборкой ядра следует подгрузить зависимости (если таковые имеются):
```bash
make dep
```

Step 2 - Building
---

Выполнить сборку ядра:
```bash
# CentOS
make bzImage

# Ubuntu - как итог готовый образ в формате *.iso 
make isoimage
```
<details>
    <summary>make bzImage output (CentOS)</summary>

```bash
  <...>
  CC      arch/x86/boot/video-vesa.o
  CC      arch/x86/boot/video-bios.o
  LD      arch/x86/boot/setup.elf
  OBJCOPY arch/x86/boot/setup.bin
  OBJCOPY arch/x86/boot/vmlinux.bin
  HOSTCC  arch/x86/boot/tools/build
  BUILD   arch/x86/boot/bzImage
Setup is 17388 bytes (padded to 17408 bytes).
System is 8113 kB
CRC 960f1e74
Kernel: arch/x86/boot/bzImage is ready  (#1)
```
</details>

Step 3 - Build modules (CentOS)
---

Сборка модуля для Centos
```bash
make modules
```

Установить (копирваоть) собранные модули в директорию по умолчанию:
```bash
make modules_install
```
Для сборка ядра следует быть в директории с **Makefile** и выполнить:
```bash
make install
```
Step 3 - GRUB
---
Настройка загрузки ядра с помощю GRUB. Посмотреть, какое ядро загружается на данный момент:
```bash
cat /boot/grub2/grub.cfg | grep menuentry
```

<details>
    <summary>Output</summary>

```bash
if [ x"${feature_menuentry_id}" = xy ]; then
  menuentry_id_option="--id"
  menuentry_id_option=""
export menuentry_id_option
menuentry 'CentOS Linux (3.10.0-1062.1.2.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-957.12.2.el7.x86_64-advanced-8ac075e3-1124-4bb6-bef7-a6811bf8b870' {
menuentry 'CentOS Linux (3.10.0-957.12.2.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-957.12.2.el7.x86_64-advanced-8ac075e3-1124-4bb6-bef7-a6811bf8b870' {
```
</details>

Меняем настрйоки GRUB по умолчнию

```bash
/etc/default/grub
```

<details>
    <summary>Default /etc/default/grub</summary>

```bash
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto"
GRUB_DISABLE_RECOVERY="true"
```
</details>

В поле `GRUB_DEFAULT=saved` меняем `saved` на номер необходимого ядра `[0..n]`

Пересобираем конфигурационный файл загрузчика GRUB
```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```
Done!
```bash
uname -r
reboot
```

---
**Useful links**
  1. [GNU Bison & Flex](https://habr.com/en/post/141756/)