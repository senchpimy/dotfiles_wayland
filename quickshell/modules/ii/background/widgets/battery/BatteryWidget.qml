import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "battery"
    
    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight

    // Modelo para dispositivos conectados
    ListModel {
        id: deviceModel
    }

    // Actualización de dispositivos
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateDevices()
    }

    function updateDevices() {
        deviceModel.clear()
        const devices = UPower.devices.values
        
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            
            // Ignorar alimentación de línea
            if (dev.type === UPowerDeviceType.LinePower) continue
            
            // Determinar icono según tipo
            let icon = "battery_std"
            if (dev.type === UPowerDeviceType.Battery) icon = "laptop_mac"
            else if (dev.type === UPowerDeviceType.Mouse) icon = "mouse"
            else if (dev.type === UPowerDeviceType.Keyboard) icon = "keyboard"
            else if (dev.type === UPowerDeviceType.Headphones) icon = "headphones"
            else if (dev.type === UPowerDeviceType.Phone) icon = "smartphone"
            else if (dev.type === UPowerDeviceType.Tablet) icon = "tablet_mac"
            else if (dev.type === UPowerDeviceType.Monitor) icon = "monitor"
            else if (dev.type === UPowerDeviceType.GamingInput) icon = "videogame_asset"
            
            // Estado de carga
            const isCharging = dev.state === UPowerDeviceState.Charging
            
            deviceModel.append({
                "percent": dev.percentage,
                "icon": icon,
                "isCharging": isCharging
            })
        }
    }

    Rectangle {
        id: mainContainer
        // Tamaño dinámico según cantidad de dispositivos
        implicitWidth: devicesLayout.implicitWidth + 50
        implicitHeight: devicesLayout.implicitHeight + 50
        radius: Appearance.rounding.large
        // Color diferente al calendario (colLayer1) y clima (colPrimaryContainer)
        color: Appearance.colors.colSurfaceContainerHigh
        
        StyledRectangularShadow {
            target: mainContainer
            visible: true
        }

        RowLayout {
            id: devicesLayout
            anchors.centerIn: parent
            spacing: 25

            Repeater {
                model: deviceModel
                delegate: Item {
                    width: 110
                    height: 110
                    
                    // Anillo de Progreso
                    Shape {
                        anchors.centerIn: parent
                        width: 100
                        height: 100
                        layer.enabled: true
                        layer.samples: 4
                        
                        // Fondo del anillo
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: Appearance.colors.colSurfaceContainerHighest
                            strokeWidth: 10
                            capStyle: ShapePath.RoundCap
                            PathAngleArc {
                                centerX: 50; centerY: 50
                                radiusX: 45; radiusY: 45
                                startAngle: 0
                                sweepAngle: 360
                            }
                        }
                        
                        // Barra de progreso
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: {
                                if (isCharging) return Appearance.colors.colPrimary || "green"
                                if (percent * 100 <= 20) return Appearance.colors.m3error || "red"
                                if (percent * 100 <= 50) return Appearance.colors.m3tertiary || "orange"
                                return Appearance.colors.colPrimary || "white"
                            }
                            strokeWidth: 10
                            capStyle: ShapePath.RoundCap
                            PathAngleArc {
                                centerX: 50; centerY: 50
                                radiusX: 45; radiusY: 45
                                startAngle: -90
                                sweepAngle: 360 * percent
                            }
                        }
                    }

                    // Icono y Texto central
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        
                        MaterialSymbol {
                            text: icon
                            font.pixelSize: 32
                            Layout.alignment: Qt.AlignHCenter
                            color: Appearance.colors.colOnSurface
                        }
                        StyledText {
                            text: Math.round(percent * 100) + "%"
                            font.family: Appearance.font.family.numbers
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnSurface
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    
                    // Indicador de carga (Rayo pequeño)
                    Rectangle {
                        visible: isCharging
                        width: 24
                        height: 24
                        radius: 12
                        color: Appearance.colors.colSurface
                        opacity: 0.8
                        anchors.top: parent.top
                        anchors.right: parent.right
                        
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "bolt"
                            font.pixelSize: 20
                            color: Appearance.colors.colPrimary
                        }
                    }
                }
            }
        }
    }
}