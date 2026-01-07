pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    // Mock properties to satisfy interface
    property var agent: null
    property bool active: false
    property var flow: null
    property bool interactionAvailable: false
    
    property string cleanMessage: ""
    property string cleanPrompt: ""

    function cancel() {
        console.log("Mock PolkitService: cancel called")
    }

    function submit(string) {
        console.log("Mock PolkitService: submit called")
        root.interactionAvailable = false
    }
}
