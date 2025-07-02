import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Io
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

Item {
    id: battery
    property var desktop: false
    property var total: 0
    property var normal_interval: 40
    property var fullTotal: 0
    property ListModel datos: ListModel {}

    readonly property var tog: Process {
        running: true
        command: ["sh", "/home/plof/.config/quickshell/lockscreen/bat.sh"]
        //startDetached: false
        stdout: SplitParser {
            onRead: data => {
                var str = data.split(" ");
                var t = parseInt(str[0]);
                var name = str[1];
                var state = str[2] ? str[2] : "";
                battery.datos.append({ val: t, image: name, state: state });
                battery.total += 1;
                normal_interval = normal_interval > 100 ? 60000 / 2 : normal_interval * 2;
            }
        }
    }

    // Fondo del contenedor
    Component {
        id: background
        Rectangle {
            height: 150
            color: desktop ? "#ffffff" : "#ffffff"
            width: parent.width
            opacity: desktop ? 0.8 : 0.7
            radius: 20

            // Sombra suave
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 16
                samples: 32
                color: "#40000000"
            }
        }
    }

    // Temporizador para actualizar los datos
    Timer {
        interval: normal_interval
        repeat: true
        running: true
        onTriggered: {
            battery.datos.clear();
            tog.running = true;
            loader.item.width = battery.total > 1 ? 40 : 0;
            battery.total = 0;
        }
    }

    // Componente para cada círculo de batería
    Component {
        id: full
        Rectangle {
            id: container
            property var val: 10
            property var svg: ""
            property var sta: ""
            color: "transparent"
            height: 150
            width: 150

            // Círculo de fondo
            Shape {
                width: parent.width
                height: parent.height
                layer.enabled: true
                layer.samples: 5

                layer.effect: DropShadow {
                    radius: 2
                    color: "#35364a"
                    samples: 2
                }
                opacity: 0.6
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: "#35364a"
                    strokeWidth: 12
                    capStyle: ShapePath.FlatCap
                    PathAngleArc {
                        centerX: 75; centerY: 75
                        radiusX: 60; radiusY: 60
                        startAngle: -180
                        sweepAngle: 360
                    }
                }
            }

            // Círculo de progreso
            Shape {
                width: parent.width
                height: parent.height
                layer.enabled: true
                layer.samples: 5
                layer.effect: DropShadow {
                    radius: 6
                    color: "#000000"
                    samples: 10
                }
                ShapePath {
                    capStyle: ShapePath.RoundCap
                    fillColor: "transparent"
                    strokeColor: val > 50 ? "#2DCF59" : (val > 20 ? "#FDD509" : "#F2330D")
                    strokeWidth: 12
                    PathAngleArc {
                        centerX: 75; centerY: 75
                        radiusX: 60; radiusY: 60
                        startAngle: -80
                        sweepAngle: (360 * ((val - 3) / 100))
                    }
                }
            }

            // Icono de la batería
            Image {
                property var resize: 80
                width: parent.width - resize
                height: parent.height - resize
                source: svg + ".svg"
                anchors.centerIn: parent
            }

            // Icono de estado (cargando/descargando)
            Image {
                id: state
                property var resize: 116
                width: parent.width - resize
                height: parent.height - resize
                source: sta + ".svg"
                anchors.centerIn: parent
            }
        }
    }

    // Contenedor principal
    RowLayout {
        anchors.horizontalCenter: desktop ? null : parent.horizontalCenter
        Rectangle {
            id: main
            height: 150
            width: childrenRect.width
            color: "transparent"
            Loader {
                id: loader
                sourceComponent: background
            }
            radius: 20
            RowLayout {
                spacing: 40
                Repeater {
                    model: battery.datos
                    Loader {
                        sourceComponent: full
                        onLoaded: {
                            item.val = model.val;
                            item.svg = model.image;
                            item.sta = model.state;
                            loader.item.width += item.width + ((10 * (index - 1) * 2) * index);
                        }
                    }
                }
            }
        }
    }
}
