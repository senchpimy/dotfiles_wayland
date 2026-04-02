import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.UPower
import qs.modules.common
import qs.modules.common.widgets
import "../../../../common/widgets" as Widgets

Item {
    id: root
    
    // Propiedades de estilo para personalización
    property color backgroundColor: Appearance.colors.colSurfaceContainerHigh
    property color ringBackgroundColor: Appearance.colors.colSurfaceContainerHighest
    property color ringColorCharging: Appearance.colors.colPrimary || "green"
    property color ringColorLow: Appearance.colors.m3error || "red"
    property color ringColorMedium: Appearance.colors.m3tertiary || "orange"
    property color ringColorNormal: Appearance.colors.colPrimary || "white"
    property color textColor: Appearance.colors.colOnSurface
    property color chargeIndicatorColor: Appearance.colors.colSurface
    property color chargeIconColor: Appearance.colors.colPrimary
    
    // Propiedad para sombra
    property bool shadowEnabled: true

    implicitWidth: mainContainer.implicitWidth
    implicitHeight: mainContainer.implicitHeight

    // Exponer el conteo para layouts externos si es necesario
    property int deviceCount: deviceModel.count

    ListModel {
        id: deviceModel
    }

    Timer {
        interval: 2000 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateDevices()
    }

    function updateDevices() {
        const devices = UPower.devices.values
        deviceModel.clear()
        
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            // Ignorar cargadores y dispositivos desconocidos/sin carga
            if (dev.type === UPowerDeviceType.LinePower || dev.type === UPowerDeviceType.Unknown || dev.percentage <= 0) continue
            
            let icon = "battery_std"
            if (dev.type === UPowerDeviceType.Battery) icon = "laptop_mac"
            else if (dev.type === UPowerDeviceType.Mouse) icon = "mouse"
            else if (dev.type === UPowerDeviceType.Keyboard) icon = "keyboard"
            else if (dev.type === UPowerDeviceType.Headset || dev.type === UPowerDeviceType.Headphones) icon = "headphones"
            else if (dev.type === UPowerDeviceType.Phone) icon = "smartphone"
            else if (dev.type === UPowerDeviceType.Tablet) icon = "tablet_mac"
            else if (dev.type === UPowerDeviceType.Monitor) icon = "monitor"
            else if (dev.type === UPowerDeviceType.GamingInput) icon = "videogame_asset"
            
            deviceModel.append({
                "percent": dev.percentage,
                "icon": icon,
                "isCharging": dev.state === UPowerDeviceState.Charging
            })
        }
    }

    Rectangle {
        id: mainContainer
        visible: deviceModel.count > 0
        implicitWidth: devicesLayout.implicitWidth + 50
        implicitHeight: devicesLayout.implicitHeight + 50
        radius: Appearance.rounding.large
        color: root.backgroundColor
        
        Loader {
            active: root.shadowEnabled
            anchors.fill: parent
            sourceComponent: StyledRectangularShadow {
                target: mainContainer
            }
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
                    
                    Shape {
                        anchors.centerIn: parent
                        width: 100
                        height: 100
                        layer.enabled: true
                        layer.samples: 4
                        
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: root.ringBackgroundColor
                            strokeWidth: 10
                            capStyle: ShapePath.RoundCap
                            PathAngleArc {
                                centerX: 50; centerY: 50
                                radiusX: 45; radiusY: 45
                                startAngle: 0
                                sweepAngle: 360
                            }
                        }
                        
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: {
                                if (isCharging) return root.ringColorCharging
                                if (percent * 100 <= 20) return root.ringColorLow
                                if (percent * 100 <= 50) return root.ringColorMedium
                                return root.ringColorNormal
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

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        
                        Widgets.MaterialSymbol {
                            text: icon
                            font.pixelSize: 32
                            Layout.alignment: Qt.AlignHCenter
                            color: root.textColor
                        }
                        Widgets.StyledText {
                            text: Math.round(percent * 100) + "%"
                            font.family: Appearance.font.family.numbers
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            color: root.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                    
                    Rectangle {
                        visible: isCharging
                        width: 24
                        height: 24
                        radius: 12
                        color: root.chargeIndicatorColor
                        opacity: 0.8
                        anchors.top: parent.top
                        anchors.right: parent.right
                        
                        Widgets.MaterialSymbol {
                            anchors.centerIn: parent
                            text: "bolt"
                            font.pixelSize: 20
                            color: root.chargeIconColor
                        }
                    }
                }
            }
        }
    }
}
