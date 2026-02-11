#!/bin/bash
#
# Script de verificação do device tree TWRP
# Verifica se todos os arquivos necessários estão presentes
#

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contadores
ERRORS=0
WARNINGS=0

print_header() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "  TWRP Device Tree Verifier"
    echo "  Motorola Edge 40 Neo (manaus)"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_file() {
    if [ -f "$1" ]; then
        print_success "$1"
        return 0
    else
        print_error "$1 (não encontrado)"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        print_success "$1/"
        return 0
    else
        print_error "$1/ (não encontrado)"
        return 1
    fi
}

check_prebuilts() {
    print_info "Verificando prebuilts..."
    
    if [ -f "prebuilt/Image" ]; then
        print_success "prebuilt/Image"
    else
        print_warning "prebuilt/Image (será necessário adicionar o kernel)"
    fi
    
    if [ -f "prebuilt/dtb.img" ]; then
        print_success "prebuilt/dtb.img"
    else
        print_warning "prebuilt/dtb.img (será necessário adicionar o DTB)"
    fi
    
    if [ -f "prebuilt/dtbo.img" ]; then
        print_success "prebuilt/dtbo.img"
    else
        print_warning "prebuilt/dtbo.img (será necessário adicionar o DTBO)"
    fi
}

verify_boardconfig() {
    print_info "Verificando BoardConfig.mk..."
    
    if [ ! -f "BoardConfig.mk" ]; then
        print_error "BoardConfig.mk não encontrado"
        return
    fi
    
    # Verificar configurações críticas
    if grep -q "BOARD_USES_VENDOR_BOOTIMAGE := true" BoardConfig.mk; then
        print_success "BOARD_USES_VENDOR_BOOTIMAGE configurado"
    else
        print_error "BOARD_USES_VENDOR_BOOTIMAGE não configurado"
    fi
    
    if grep -q "BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true" BoardConfig.mk; then
        print_success "BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT configurado"
    else
        print_error "BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT não configurado"
    fi
    
    if grep -q "BOARD_BOOT_HEADER_VERSION := 4" BoardConfig.mk; then
        print_success "BOARD_BOOT_HEADER_VERSION = 4"
    else
        print_error "BOARD_BOOT_HEADER_VERSION não é 4"
    fi
}

verify_init() {
    print_info "Verificando arquivos init..."
    
    if [ -f "recovery/root/init.recovery.mt6879.rc" ]; then
        print_success "init.recovery.mt6879.rc"
        
        if grep -q "import /init.recovery.usb.rc" recovery/root/init.recovery.mt6879.rc; then
            print_success "Import de init.recovery.usb.rc"
        else
            print_error "Falta import de init.recovery.usb.rc"
        fi
    else
        print_error "init.recovery.mt6879.rc não encontrado"
    fi
    
    if [ -f "recovery/root/init.recovery.usb.rc" ]; then
        print_success "init.recovery.usb.rc"
    else
        print_error "init.recovery.usb.rc não encontrado"
    fi
}

verify_fstab() {
    print_info "Verificando fstab..."
    
    if [ -f "recovery/root/system/etc/recovery.fstab" ]; then
        print_success "recovery.fstab"
        
        if grep -q "first_stage_mount" recovery/root/system/etc/recovery.fstab; then
            print_success "first_stage_mount configurado"
        else
            print_warning "first_stage_mount não encontrado"
        fi
    else
        print_error "recovery.fstab não encontrado"
    fi
}

# Verificação principal
main() {
    print_header
    
    print_info "Verificando estrutura do device tree..."
    echo ""
    
    # Arquivos principais
    print_info "Arquivos principais:"
    check_file "Android.bp"
    check_file "Android.mk"
    check_file "AndroidProducts.mk"
    check_file "BoardConfig.mk"
    check_file "device.mk"
    check_file "twrp_manaus.mk"
    check_file "system.prop"
    check_file "vendor.prop"
    check_file "twrp.dependencies"
    check_file "README.md"
    
    echo ""
    
    # Prebuilts
    check_prebuilts
    
    echo ""
    
    # Arquivos de recovery
    print_info "Arquivos de recovery:"
    check_dir "recovery/root"
    check_file "recovery/root/init.recovery.mt6879.rc"
    check_file "recovery/root/init.recovery.usb.rc"
    check_file "recovery/root/mtk-plpath-utils.rc"
    check_file "recovery/root/ueventd.rc"
    check_file "recovery/root/snapuserd.rc"
    check_file "recovery/root/sbin/postrecoveryboot.sh"
    check_file "recovery/root/system/etc/recovery.fstab"
    check_file "recovery/root/system/etc/twrp.flags"
    
    echo ""
    
    # Verificações detalhadas
    verify_boardconfig
    echo ""
    verify_init
    echo ""
    verify_fstab
    
    echo ""
    echo "=========================================="
    
    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        print_success "TODAS AS VERIFICAÇÕES PASSARAM!"
        print_info "O device tree está pronto para compilar."
        exit 0
    elif [ $ERRORS -eq 0 ]; then
        print_warning "VERIFICAÇÃO CONCLUÍDA COM AVISOS"
        print_info "Warnings: $WARNINGS"
        print_info "O device tree pode compilar, mas verifique os avisos."
        exit 0
    else
        print_error "VERIFICAÇÃO FALHOU"
        print_error "Erros: $ERRORS"
        print_warning "Warnings: $WARNINGS"
        print_info "Corrija os erros antes de compilar."
        exit 1
    fi
}

main "$@"
