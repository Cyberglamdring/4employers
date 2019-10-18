Part 1. Preparation
===
```bash
# CentOS
yum groupinstall -y "Development Tools"
yum install -y ncurses-devel libncurses-devel openssl-devel bc hmaccalc zlib0devel binutils-devel elfutils-libelf-devel

# Ubuntu
apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev isolinux genisoimage
```

Table 1 - Packeges
| Command | Description |
| --- | --- |
|`Development Tools (CentOS)`, `build-essential (Ubuntu)`|библиотека включающая в себя утилиты для сборки|
|`libncurses`|библиотека управления вводом-выводом на терминал|
|`flex`|[Fast Lexical Analyzer](https://habr.com/post/99162/) - генератор лексических анализаторов |
|`bison`|[GNU Bison](https://habr.com/post/99366/)  - программа, предназначенная для автоматического создания синтаксических анализаторов по данному описанию грамматики|
|`isolinux`|создание загрузочных образов|
|`genisoimage`|создание ISO образов|

Part 2. Build
===
Preparation
---
Чтобы посмотреть возможные операции с ***Makefile*** в текущей дирректории следует выполнить:

```bash
make help
```

<details>
    <summary>make help output</summary>
    
    ```bash
    Cleaning targets:
    clean           - Remove most generated files but keep the config and
                        enough build support to build external modules
    mrproper        - Remove all generated files + config + various backup files
    distclean       - mrproper + remove editor backup and patch files

    Configuration targets:
    config          - Update current config utilising a line-oriented program
    nconfig         - Update current config utilising a ncurses menu based program
    menuconfig      - Update current config utilising a menu based program
    xconfig         - Update current config utilising a Qt based front-end
    gconfig         - Update current config utilising a GTK+ based front-end
    oldconfig       - Update current config utilising a provided .config as base
    localmodconfig  - Update current config disabling modules not loaded
    localyesconfig  - Update current config converting local mods to core
    defconfig       - New config with default from ARCH supplied defconfig
    savedefconfig   - Save current config as ./defconfig (minimal config)
    allnoconfig     - New config where all options are answered with no
    allyesconfig    - New config where all options are accepted with yes
    allmodconfig    - New config selecting modules when possible
    alldefconfig    - New config with all symbols set to default
    randconfig      - New config with random answer to all options
    listnewconfig   - List new options
    olddefconfig    - Same as oldconfig but sets new symbols to their
                        default value without prompting
    kvmconfig       - Enable additional options for kvm guest kernel support
    xenconfig       - Enable additional options for xen dom0 and guest kernel support
    tinyconfig      - Configure the tiniest possible kernel
    testconfig      - Run Kconfig unit tests (requires python3 and pytest)

    Other generic targets:
    all             - Build all targets marked with [*]
    * vmlinux         - Build the bare kernel
    * modules         - Build all modules
    modules_install - Install all modules to INSTALL_MOD_PATH (default: /)
        dir/            - Build all files in dir and below
    dir/file.[ois]  - Build specified target only
    dir/file.ll     - Build the LLVM assembly file
                        (requires compiler support for LLVM assembly generation)
    dir/file.lst    - Build specified mixed source/assembly target only
                        (requires a recent binutils and recent build (System.map))
    dir/file.ko     - Build module including final link
    modules_prepare - Set up for building external modules
    tags/TAGS       - Generate tags file for editors
    cscope          - Generate cscope index
    gtags           - Generate GNU GLOBAL index
    kernelrelease   - Output the release version string (use with make -s)
    kernelversion   - Output the version stored in Makefile (use with make -s)
    image_name      - Output the image name (use with make -s)
    headers_install - Install sanitised kernel headers to INSTALL_HDR_PATH
                        (default: ./usr)

    Static analysers:
    checkstack      - Generate a list of stack hogs
    namespacecheck  - Name space analysis on compiled kernel
    versioncheck    - Sanity check on version.h usage
    includecheck    - Check for duplicate included header files
    export_report   - List the usages of all exported symbols
    headers_check   - Sanity check on exported headers
    headerdep       - Detect inclusion cycles in headers
    coccicheck      - Check with Coccinelle

    Kernel selftest:
    kselftest       - Build and run kernel selftest (run as root)
                        Build, install, and boot kernel before
                        running kselftest on it
    kselftest-clean - Remove all generated kselftest files
    kselftest-merge - Merge all the config dependencies of kselftest to existing
                        .config.

    Userspace tools targets:
    use "make tools/help"
    or  "cd tools; make help"

    Kernel packaging:
    rpm-pkg             - Build both source and binary RPM kernel packages
    binrpm-pkg          - Build only the binary kernel RPM package
    deb-pkg             - Build both source and binary deb kernel packages
    bindeb-pkg          - Build only the binary kernel deb package
    snap-pkg            - Build only the binary kernel snap package (will connect to external hosts)
    tar-pkg             - Build the kernel as an uncompressed tarball
    targz-pkg           - Build the kernel as a gzip compressed tarball
    tarbz2-pkg          - Build the kernel as a bzip2 compressed tarball
    tarxz-pkg           - Build the kernel as a xz compressed tarball
    perf-tar-src-pkg    - Build perf-5.3.7.tar source tarball
    perf-targz-src-pkg  - Build perf-5.3.7.tar.gz source tarball
    perf-tarbz2-src-pkg - Build perf-5.3.7.tar.bz2 source tarball
    perf-tarxz-src-pkg  - Build perf-5.3.7.tar.xz source tarball

    Documentation targets:
    Linux kernel internal documentation in different formats from ReST:
    htmldocs        - HTML
    latexdocs       - LaTeX
    pdfdocs         - PDF
    epubdocs        - EPUB
    xmldocs         - XML
    linkcheckdocs   - check for broken external links (will connect to external hosts)
    refcheckdocs    - check for references to non-existing files under Documentation
    cleandocs       - clean all generated files

    make SPHINXDIRS="s1 s2" [target] Generate only docs of folder s1, s2
    valid values for SPHINXDIRS are:   

    make SPHINX_CONF={conf-file} [target] use *additional* sphinx-build
    configuration. This is e.g. useful to build with nit-picking config.

    Default location for the generated documents is Documentation/output

    Architecture specific targets (x86):
    * bzImage      - Compressed kernel image (arch/x86/boot/bzImage)
    install      - Install kernel using
                    (your) ~/bin/installkernel or
                    (distribution) /sbin/installkernel or
                    install to $(INSTALL_PATH) and run lilo
    fdimage      - Create 1.4MB boot floppy image (arch/x86/boot/fdimage)
    fdimage144   - Create 1.4MB boot floppy image (arch/x86/boot/fdimage)
    fdimage288   - Create 2.8MB boot floppy image (arch/x86/boot/fdimage)
    isoimage     - Create a boot CD-ROM image (arch/x86/boot/image.iso)
                    bzdisk/fdimage*/isoimage also accept:
                    FDARGS="..."  arguments for the booted kernel
                    FDINITRD=file initrd for the booted kernel

    i386_defconfig           - Build for i386
    x86_64_defconfig         - Build for x86_64

    make V=0|1 [targets] 0 => quiet build (default), 1 => verbose build
    make V=2   [targets] 2 => give reason for rebuild of target
    make O=dir [targets] Locate all output files in "dir", including .config
    make C=1   [targets] Check re-compiled c source with $CHECK (sparse by default)
    make C=2   [targets] Force check of all c source with $CHECK
    make RECORDMCOUNT_WARN=1 [targets] Warn about ignored mcount sections
    make W=n   [targets] Enable extra gcc checks, n=1,2,3 where
                    1: warnings which may be relevant and do not occur too often
                    2: warnings which occur quite often but may still be relevant
                    3: more obscure warnings, can most likely be ignored
                    Multiple levels can be combined with W=12 or W=123               

    Execute "make" or "make all" to build all targets marked with [*]
    For further info see the ./README file
</details> 

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