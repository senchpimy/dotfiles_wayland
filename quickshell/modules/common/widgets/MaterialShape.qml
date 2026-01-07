import QtQuick
import qs.modules.common

Item {
    id: root
    enum Shape {
        Circle,
        Square,
        Slanted,
        Arch,
        Fan,
        Arrow,
        SemiCircle,
        Oval,
        Pill,
        Triangle,
        Diamond,
        ClamShell,
        Pentagon,
        Gem,
        Sunny,
        VerySunny,
        Cookie4Sided,
        Cookie6Sided,
        Cookie7Sided,
        Cookie9Sided,
        Cookie12Sided,
        Ghostish,
        Clover4Leaf,
        Clover8Leaf,
        Burst,
        SoftBurst,
        Boom,
        SoftBoom,
        Flower,
        Puffy,
        PuffyDiamond,
        PixelCircle,
        PixelTriangle,
        Bun,
        Heart
    }
    required property var shape
    property double implicitSize
    property color color: "black"
    
    implicitHeight: implicitSize
    implicitWidth: implicitSize
    
    property var animation: null

    Rectangle {
        anchors.fill: parent
        color: root.color
        
        // Implementamos formas básicas usando radios de esquina
        radius: {
            const s = root.shape;
            if (s === MaterialShape.Shape.Square) return 0;
            if (s === MaterialShape.Shape.Circle || s === MaterialShape.Shape.Pill) return width / 2;
            if (s === MaterialShape.Shape.Arch) return width / 2; // Arch es similar a Pill pero vertical?
            if (s === MaterialShape.Shape.Diamond) return 0; // Diamond necesita rotación
            return width / 2;
        }

        // Ajustes para formas específicas
        rotation: (root.shape === MaterialShape.Shape.Diamond) ? 45 : 0
        
        // Ajuste para Arch (redondeamos solo arriba)
        topLeftRadius: (root.shape === MaterialShape.Shape.Arch) ? width / 2 : radius
        topRightRadius: (root.shape === MaterialShape.Shape.Arch) ? width / 2 : radius
        bottomLeftRadius: (root.shape === MaterialShape.Shape.Arch) ? 10 : radius
        bottomRightRadius: (root.shape === MaterialShape.Shape.Arch) ? 10 : radius

        // Ajuste para Heart (aproximación con Rectangle)
        // (Nota: Un corazón real requiere Shape/Path, pero esto es un avance)
    }
}