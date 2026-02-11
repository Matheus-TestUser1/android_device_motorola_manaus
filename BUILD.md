# Instruções de Build - TWRP para Motorola Edge 40 Neo

## Resumo Rápido

```bash
# 1. Preparar ambiente
sudo apt-get update
sudo apt-get install -y git-core gnupg flex bison build-essential zip curl \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
    xsltproc unzip fontconfig

# 2. Configurar repo
mkdir -p ~/.bin
export PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo

# 3. Download do código fonte TWRP
mkdir -p ~/twrp && cd ~/twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all)

# 4. Adicionar device tree
mkdir -p device/motorola
cp -r /caminho/para/este/device/tree device/motorola/manaus

# 5. Compilar
source build/envsetup.sh
lunch twrp_manaus-eng
mka vendorbootimage -j$(nproc --all)

# 6. Arquivos de saída
# out/target/product/manaus/vendor_boot.img
# out/target/product/manaus/recovery.img
```

## Preparação do Kernel (Importante!)

Antes de compilar, você precisa dos arquivos de kernel:

### 1. Extrair do firmware original

```bash
# Extrair kernel do boot.img original
magiskboot unpack boot.img
# Copiar: kernel -> device/motorola/manaus/prebuilt/Image
# Copiar: dtb -> device/motorola/manaus/prebuilt/dtb.img

# Extrair dtbo do dtbo.img original
# Copiar: dtbo -> device/motorola/manaus/prebuilt/dtbo.img
```

### 2. Ou usar kernel pré-compilado

Baixe o kernel compatível com o Edge 40 Neo e coloque em:
- `prebuilt/Image` - Kernel Image
- `prebuilt/dtb.img` - Device Tree Blob
- `prebuilt/dtbo.img` - Device Tree Blob Overlay

## Comandos de Build

### Build completo
```bash
source build/envsetup.sh
lunch twrp_manaus-eng
mka vendorbootimage -j8
```

### Build apenas do recovery
```bash
mka recoveryimage -j8
```

### Build limpo (clean build)
```bash
make clean
mka vendorbootimage -j8
```

### Build com logs detalhados
```bash
mka vendorbootimage -j8 2>&1 | tee build.log
```

## Solução de Erros de Build

### Erro: "No rule to make target 'vendorbootimage'"
```bash
# Use recoveryimage em vez de vendorbootimage
mka recoveryimage -j8
```

### Erro: "Cannot find kernel config"
```bash
# Verifique se TARGET_PREBUILT_KERNEL está apontando para um arquivo existente
ls -la device/motorola/manaus/prebuilt/Image
```

### Erro: "DTB not found"
```bash
# Verifique se o DTB existe
ls -la device/motorola/manaus/prebuilt/dtb.img
```

### Erro: "Out of memory"
```bash
# Reduza o número de threads
mka vendorbootimage -j4

# Ou aumente o swap
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Verificação do Build

Após compilar, verifique os arquivos:

```bash
# Verificar vendor_boot.img
ls -lh out/target/product/manaus/vendor_boot.img
file out/target/product/manaus/vendor_boot.img

# Extrair e verificar conteúdo
cd out/target/product/manaus
magiskboot unpack vendor_boot.img
ls -la

# Verificar ramdisk
cd ramdisk.cpio
cpio -ivt < ../ramdisk.cpio 2>/dev/null | head -20
```

## Instalação do Build

### Via Fastboot
```bash
# Reiniciar em fastboot
adb reboot bootloader

# Flash do vendor_boot
fastboot flash vendor_boot out/target/product/manaus/vendor_boot.img

# Reiniciar em recovery
fastboot reboot recovery
```

### Boot temporário (para teste)
```bash
fastboot boot out/target/product/manaus/vendor_boot.img
```

## Dicas

1. **Sempre faça backup** do vendor_boot original antes de flashar
2. **Teste com boot temporário** primeiro antes de flashar permanentemente
3. **Mantenha o kernel atualizado** com patches de segurança
4. **Verifique os logs** se algo der errado: `adb logcat` ou `fastboot oem get_logs`

## Arquivos Importantes

- `BoardConfig.mk` - Configuração principal do dispositivo
- `device.mk` - Configuração de produto
- `init.recovery.mt6879.rc` - Script de inicialização do recovery
- `recovery.fstab` - Tabela de partições
- `prebuilt/` - Kernel, DTB e DTBO
