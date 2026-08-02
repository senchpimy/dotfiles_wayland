# Funcionalidades Pendientes de Migración (de `test/`)

Esta lista contiene las características avanzadas encontradas en los archivos de prueba que aún no se han implementado en la configuración `hypr_lua`.

## 1. Animaciones Físicas (Springs)
- [ ] Implementar curvas de tipo `spring` (resorte) para un movimiento más natural.
- [ ] Configurar parámetros físicos: `mass`, `stiffness`, `dampening`.
- [ ] Aplicar estilos `popin` y `slide` optimizados con estas curvas.

## 2. Lógica de Atajos Inteligente (Smart Binds)
- [ ] **`layout_bind`**: Función que detecta el layout activo y cambia la acción de una tecla (ej: `SUPER+A` hace algo distinto en `dwindle` vs `master`).
- [ ] **Sistema de Minimizado**: Lógica en Lua para mover ventanas al espacio `special:minimize` y recuperarlas.
- [ ] **`toggle_rofi`**: Helper para manejar la apertura/cierre de menús de Rofi de forma más limpia.
- [ ] **Binds de Laptop Extendidos**: Añadir `XF86PowerOff`, `XF86Calculator`, `XF86Launch1`, etc., con flags de `locked` y `repeating`.

## 3. Sistema de Reglas por Etiquetas (Tags)
- [ ] Migrar reglas individuales a un sistema de etiquetas (`tag = "float"`, `tag = "opaque"`, etc.).
- [ ] Simplificar `rules.lua` aplicando reglas globales a etiquetas en lugar de a clases individuales.

## 4. Configuración de Versión 0.55+
- [ ] **Sección `render`**: Control de color (`cm_enabled`) y gestión de perfiles de monitor (`send_content_type`).
- [ ] **Sección `ecosystem`**: Desactivar noticias y avisos de donación.
- [ ] **Sección `cursor`**: Ajustes de `inactive_timeout` y `enable_hyprcursor`.

## 5. Soporte para Layout "Scrolling"
- [ ] Configurar la sección `scrolling` para uso de paneles infinitos.
- [ ] Definir anchos de columna dinámicos (`explicit_column_widths`).
- [ ] Reglas de ventana específicas para ancho de scroll (`scrolling_width`).

## 6. Reglas de Ventana Detalladas
- [ ] Reglas específicas para diálogos de Thunar (posicionamiento en esquina, focus forzado).
- [ ] Reglas de tamaño predefinidas para herramientas como `nwg-look` o `seahorse`.
- [ ] Reglas de `stay_focused` para diálogos de autenticación y renombrado.

## 7. Gestión Avanzada de Monitores (Hotplugging)
- [ ] **Monitor Comodín**: Configurar la regla `output = ""` para manejar automáticamente cualquier pantalla nueva no reconocida.
- [ ] **Espejado Dinámico**: Lógica para activar/desactivar el modo espejo (`mirror`) programáticamente.
- [ ] **Notificaciones de Conexión**: Usar Lua para lanzar una notificación (`hl.notify`) cuando se detecta un cambio en los monitores.
- [ ] **Reasignación de Workspaces**: Optimizar la integración con `monitor_workspaces.sh` para que se ejecute automáticamente tras un hotplug.

## 8. Notificaciones e Inteligencia Nativas
- [ ] **Notificaciones Integradas**: Sustituir llamadas externas a `notify-send` por `hl.notify` para mayor velocidad e integración visual.
- [ ] **Lectura de Estado (Getters)**: Usar `hl.get_config` para crear binds que cambien su comportamiento según el layout o estado actual.
- [ ] **Comandos Estructurados (`hl.dsp`)**: Refactorizar todos los strings de comandos manuales al formato de funciones estructuradas de Lua para evitar errores.
- [ ] **Hooks de Ciclo de Vida**: Implementar `hyprland.reload` para refrescar scripts automáticamente al guardar y `hyprland.shutdown` para un cierre limpio de servicios.
- [ ] **Propiedades de Ventana Avanzadas**: Aplicar `stay_focused`, `persistent_size` y `no_initial_focus` en reglas críticas.


dwindle
pseudotile=true
