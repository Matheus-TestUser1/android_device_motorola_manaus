# TWRP Device Tree for Motorola Edge 40 Neo (manaus)

Device tree para compilar TWRP (Team Win Recovery Project) para o Motorola Edge 40 Neo (codinome: manaus) com suporte a **vendor_boot**.

## Especificações do Dispositivo

| Especificação | Valor |
|--------------|-------|
| Dispositivo | Motorola Edge 40 Neo |
| Codinome | manaus |
| Chipset | MediaTek MT6879 (Dimensity 7030) |
| GPU | Mali-G57 MC2 |
| RAM | 8GB/12GB |
| Armazenamento | 128GB/256GB |
| Tela | 6.55" P-OLED, 144Hz |
| Android | 13/14 |
| Partições | A/B, Dynamic Partitions |

## Características do TWRP

- ✅ **Boot via vendor_boot** (não fica no recovery tradicional)
- ✅ Suporte a partições A/B
- ✅ Suporte a partições dinâmicas (super)
- ✅ Suporte a EROFS
- ✅ MTP/ADB funcionando
- ✅ Touch funcionando
- ✅ Brilho ajustável
- ✅ Backup/Restore de partições
- ✅ Flash de imagens
- ❌ Criptografia FBE (desativada para compatibilidade)

## Arquivos Modificados/Corrigidos

### BoardConfig.mk
- Configuração correta para `BOARD_USES_VENDOR_BOOTIMAGE := true`
- Adicionado `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true`
- Configuração de módulos do kernel para vendor_boot
- Configuração correta de A/B OTA

### init.recovery.mt6879.rc
- Configuração completa para inicialização via vendor_boot
- Suporte a dynamic partitions
- Configuração de USB/ADB
- Serviços essenciais para recovery

### recovery.fstab
- Configuração correta de partições dinâmicas
- Suporte a first_stage_mount
- Configuração de slotselect para partições A/B

### device.mk
- Pacotes necessários para boot control
- Pacotes MTK específicos
- Configuração de propriedades

## Como Compilar

### Requisitos

- Ubuntu 20.04 ou superior (recomendado)
- Pelo menos 16GB de RAM
- Pelo menos 200GB de espaço livre
- Conexão com internet

### Preparação do Ambiente

```bash
# Instalar dependências
sudo apt-get update
sudo apt-get install -y git-core gnupg flex bison build-essential zip curl \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
    xsltproc unzip fontconfig

# Configurar repo
mkdir -p ~/.bin
export PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
```

### Download do Código Fonte

```bash
# Criar diretório de trabalho
mkdir -p ~/twrp && cd ~/twrp

# Inicializar repositório TWRP
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1

# Sincronizar
repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all)
```

### Adicionar Device Tree

```bash
# Clonar este device tree
mkdir -p device/motorola
cd device/motorola
git clone https://github.com/Matheus-TestUser1/twrpdt-manaus-U1TM34.107_34_3.git manaus
cd ../..
```

### Compilar

```bash
# Configurar ambiente
source build/envsetup.sh

# Escolher dispositivo
lunch twrp_manaus-eng

# Compilar (use -jN onde N é o número de threads)
mka recoveryimage -j$(nproc --all)
```

O arquivo compilado estará em:
- `out/target/product/manaus/recovery.img`
- `out/target/product/manaus/vendor_boot.img`

## Como Instalar

### Método 1: Fastboot (Recomendado)

```bash
# Reiniciar em fastboot
adb reboot bootloader

# Flash do vendor_boot
fastboot flash vendor_boot vendor_boot.img

# Reiniciar em recovery
fastboot reboot recovery
```

### Método 2: ADB Sideload

```bash
# Reiniciar em recovery
adb reboot recovery

# No TWRP, ir em "Advanced" > "ADB Sideload"
# Depois executar:
adb sideload twrp-installer.zip
```

### Método 3: Boot Temporário

```bash
# Boot temporário para testar (não instala permanentemente)
fastboot boot vendor_boot.img
```

## Solução de Problemas

### TWRP não inicia (fica na tela de boot)
- Verifique se o kernel (Image) e DTB estão corretos
- Verifique se os módulos do kernel estão sendo carregados
- Verifique logs via `fastboot oem get_logs` ou `adb logcat`

### Touch não funciona
- Verifique se o driver de touch está incluído no kernel
- Verifique permissões em /dev/input/*

### USB/ADB não funciona
- Verifique se o init.recovery.usb.rc está correto
- Verifique se o sys.usb.controller está configurado

### Partições não montam
- Verifique se o mtk_plpath_utils está funcionando
- Verifique se as partições dinâmicas estão mapeadas

## Estrutura de Partições

```
/dev/block/by-name/
├── boot_a, boot_b          - Kernel do sistema
├── vendor_boot_a, vendor_boot_b - Kernel do recovery (TWRP)
├── dtbo_a, dtbo_b          - Device Tree Blob Overlay
├── vbmeta_a, vbmeta_b      - Verificação AVB
├── super                   - Partição dinâmica
│   ├── system
│   ├── system_ext
│   ├── product
│   ├── vendor
│   └── vendor_dlkm
└── userdata                - Dados do usuário (F2FS)
```

## Créditos

- [TeamWin Recovery Project](https://twrp.me/)
- [Motorola](https://www.motorola.com/)
- [MediaTek](https://www.mediatek.com/)
- Comunidade Android

## Licença

```
Copyright (C) 2024 The Android Open Source Project
Copyright (C) 2024 TeamWin Recovery Project

SPDX-License-Identifier: Apache-2.0
```

## Disclaimer

**USE POR SUA PRÓPRIA CONTA E RISCO!**

Este software é fornecido "como está", sem garantia de qualquer tipo. O autor não se responsabiliza por danos ao dispositivo, perda de dados ou qualquer outro problema causado pelo uso deste software.

Sempre faça backup dos seus dados antes de instalar qualquer modificação no sistema.
