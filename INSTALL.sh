#!/bin/bash
#
# Script de instalação automática do TWRP para Motorola Edge 40 Neo
# Uso: ./INSTALL.sh [caminho/vendor_boot.img]
#

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
DEVICE_CODENAME="manaus"
DEVICE_NAME="Motorola Edge 40 Neo"
VENDOR_BOOT_IMG="${1:-vendor_boot.img}"

# Funções
print_header() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "  TWRP Installer for $DEVICE_NAME"
    echo "  Codename: $DEVICE_CODENAME"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_dependencies() {
    print_info "Verificando dependências..."
    
    if ! command -v adb &> /dev/null; then
        print_error "ADB não encontrado. Instale o Android SDK."
        exit 1
    fi
    
    if ! command -v fastboot &> /dev/null; then
        print_error "Fastboot não encontrado. Instale o Android SDK."
        exit 1
    fi
    
    print_success "Dependências OK"
}

check_device() {
    print_info "Verificando dispositivo..."
    
    # Verificar se o dispositivo está conectado
    DEVICE=$(adb devices | grep -v "List" | grep "device" | awk '{print $1}')
    if [ -z "$DEVICE" ]; then
        print_error "Nenhum dispositivo encontrado. Conecte o dispositivo via USB."
        exit 1
    fi
    
    print_success "Dispositivo encontrado: $DEVICE"
    
    # Verificar codinome
    CODENAME=$(adb shell getprop ro.product.device 2>/dev/null || echo "unknown")
    if [ "$CODENAME" != "$DEVICE_CODENAME" ]; then
        print_warning "Codinome do dispositivo: $CODENAME"
        print_warning "Esperado: $DEVICE_CODENAME"
        read -p "Continuar mesmo assim? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "Dispositivo verificado: $CODENAME"
}

check_image() {
    print_info "Verificando imagem..."
    
    if [ ! -f "$VENDOR_BOOT_IMG" ]; then
        print_error "Imagem não encontrada: $VENDOR_BOOT_IMG"
        print_info "Uso: $0 [caminho/vendor_boot.img]"
        exit 1
    fi
    
    print_success "Imagem encontrada: $VENDOR_BOOT_IMG"
}

backup_original() {
    print_info "Criando backup do vendor_boot original..."
    
    BACKUP_DIR="twrp_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    adb reboot bootloader
    sleep 5
    
    fastboot getvar current-slot 2>&1 | tee "$BACKUP_DIR/slot_info.txt"
    fastboot oem get_logs 2>&1 | tee "$BACKUP_DIR/logs.txt" || true
    
    print_success "Backup criado em: $BACKUP_DIR"
    print_warning "Guarde este backup para restaurar se necessário!"
}

flash_image() {
    print_info "Flashando vendor_boot..."
    
    fastboot flash vendor_boot "$VENDOR_BOOT_IMG"
    
    print_success "vendor_boot flashado com sucesso!"
}

reboot_recovery() {
    print_info "Reiniciando em recovery..."
    
    fastboot reboot recovery
    
    print_success "Reiniciando..."
}

boot_temp() {
    print_info "Boot temporário (para teste)..."
    
    adb reboot bootloader
    sleep 5
    
    fastboot boot "$VENDOR_BOOT_IMG"
    
    print_success "Boot temporário iniciado!"
}

# Menu principal
main() {
    print_header
    
    check_dependencies
    check_image
    
    echo ""
    echo "Escolha uma opção:"
    echo "1) Instalar TWRP (flash permanente)"
    echo "2) Boot temporário (apenas para teste)"
    echo "3) Sair"
    echo ""
    read -p "Opção: " -n 1 -r
    echo
    
    case $REPLY in
        1)
            check_device
            backup_original
            flash_image
            reboot_recovery
            ;;
        2)
            check_device
            boot_temp
            ;;
        3)
            print_info "Saindo..."
            exit 0
            ;;
        *)
            print_error "Opção inválida"
            exit 1
            ;;
    esac
    
    echo ""
    print_success "Instalação concluída!"
    print_info "O TWRP deve iniciar em breve."
    print_info "Se ficar preso na tela de boot, force reinicialização."
}

# Executar
main "$@"
