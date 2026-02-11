# Changelog - TWRP para Motorola Edge 40 Neo

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [1.0.0] - 2024-02-09

### Adicionado
- Suporte completo a vendor_boot para boot do TWRP
- Configuração de módulos do kernel para vendor ramdisk
- Arquivos de inicialização otimizados para vendor_boot
- Suporte a partições dinâmicas (super)
- Suporte a EROFS
- Configuração de USB/ADB funcionando
- Suporte a MTP
- Scripts de post-recovery-boot

### Corrigido
- **Problema crítico**: TWRP não ficava no recovery tradicional
- Configuração correta de `BOARD_USES_VENDOR_BOOTIMAGE`
- Configuração de `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT`
- fstab com suporte a first_stage_mount
- init.rc com carregamento correto de módulos
- Configuração de dynamic partitions

### Modificado
- `BoardConfig.mk` - Configuração completa para vendor_boot
- `device.mk` - Pacotes e propriedades otimizados
- `init.recovery.mt6879.rc` - Inicialização para vendor_boot
- `init.recovery.usb.rc` - Configuração USB aprimorada
- `recovery.fstab` - Tabela de partições corrigida
- `twrp.flags` - Flags otimizadas para TWRP GUI
- `system.prop` - Propriedades do sistema atualizadas
- `vendor.prop` - Propriedades do vendor atualizadas

### Notas Técnicas
- O TWRP agora boota corretamente via vendor_boot
- Não fica mais preso no recovery tradicional
- Suporte a A/B partições funcionando
- Dynamic partitions mapeadas corretamente

## [0.9.0] - 2024-02-08

### Adicionado
- Estrutura inicial do device tree
- Arquivos de configuração básicos
- Kernel prebuilt
- Suporte inicial a MT6879

### Problemas Conhecidos
- TWRP ficava no recovery tradicional
- vendor_boot não funcionava corretamente
- Partições dinâmicas não montavam

---

## Legenda

- **Adicionado** para novas funcionalidades.
- **Modificado** para mudanças em funcionalidades existentes.
- **Corrigido** para correções de bugs.
- **Removido** para funcionalidades removidas.
- **Segurança** para vulnerabilidades de segurança.
