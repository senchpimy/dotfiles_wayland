pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Service to manage audio profiles for Bluetooth devices using pactl.
 */
Singleton {
    id: root

    // Map: MAC address -> { index: int, profiles: [ { name: string, description: string, available: bool } ], activeProfile: string }
    property var deviceProfiles: ({})

    function refresh() {
        if (!getProfiles.running) {
            getProfiles.running = true;
        }
    }

    function setProfile(cardIndex, profileName) {
        Quickshell.execDetached(["pactl", "set-card-profile", cardIndex.toString(), profileName]);
        // Refresh after a short delay to allow the change to take effect
        refreshTimer.restart();
    }

    Process {
        id: getProfiles
        command: ["pactl", "-f", "json", "list", "cards"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const rawText = text.trim();
                    if (rawText === "" || rawText === "[]") return;
                    
                    const cards = JSON.parse(rawText);
                    const newProfiles = {};
                    cards.forEach(card => {
                        // Better bluetooth detection
                        const isBluetooth = card.name.includes("bluez_card") || 
                                           card.properties["device.api"] === "bluez5" ||
                                           card.properties["device.bus"] === "bluetooth";
                        
                        if (isBluetooth) {
                            // Try multiple ways to get the MAC address
                            let mac = card.properties["api.bluez5.address"] || 
                                      card.properties["device.string"] ||
                                      card.properties["device.name"];
                            
                            if (mac && mac.includes("bluez_card")) {
                                const match = mac.match(/bluez_card\.([0-9A-F_]{17})/i);
                                if (match) mac = match[1].replace(/_/g, ":");
                            }

                            if (mac) {
                                const normalizedMac = mac.toUpperCase().replace(/-/g, ":").replace(/_/g, ":");
                                const profilesList = [];
                                for (const [name, data] of Object.entries(card.profiles)) {
                                    if (name !== "off") {
                                        profilesList.push({
                                            name: name,
                                            description: data.description,
                                            available: data.available
                                        });
                                    }
                                }

                                newProfiles[normalizedMac] = {
                                    index: card.index,
                                    name: card.name,
                                    profiles: profilesList,
                                    activeProfile: card.active_profile
                                };
                                // console.log("[AudioProfiles] Registered MAC: " + normalizedMac);
                            }
                        }
                    });
                    root.deviceProfiles = newProfiles;
                } catch (e) {
                    console.log("[AudioProfiles] Error parsing pactl output: " + e);
                }
            }
        }
    }

    function getMacFromDevice(device) {
        if (!device) return "";
        let mac = (device.address || "").toUpperCase().replace(/-/g, ":");
        // console.log("[AudioProfiles] Component searching MAC: " + mac);
        return mac;
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: refresh()
    }
}
