import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Shapes 

Item {
    id: root
    
    property int spacing: 20
    property int columns: Math.max(1, Math.floor(width / (100 + spacing)))
    
    Grid {
        id: gridLayout
        columns: root.columns
        spacing: root.spacing
        anchors.fill: parent
        
        Component.onCompleted: {
            const childrenArray = [...root.children];
            childrenArray.forEach(child => {
                if (child !== gridLayout) {
                    child.parent = gridLayout;
                }
            });
        }
    }
    
    // Asegurar actualización dinámica
    onWidthChanged: columns = Math.max(1, Math.floor(width / (100 + spacing)))
}
