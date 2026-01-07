pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string filePath: Directories.shellConfigPath
    property alias options: configOptionsJsonAdapter

    function setNestedValue(nestedKey, value) {
        let keys = nestedKey.split(".");
        let obj = root.options;
        let parents = [obj];

        for (let i = 0; i < keys.length - 1; ++i) {
            if (!obj[keys[i]] || typeof obj[keys[i]] !== "object") {
                obj[keys[i]] = {};
            }
            obj = obj[keys[i]];
            parents.push(obj);
        }

        let convertedValue = value;
        if (typeof value === "string") {
            let trimmed = value.trim();
            if (trimmed === "true" || trimmed === "false" || !isNaN(Number(trimmed))) {
                try {
                    convertedValue = JSON.parse(trimmed);
                } catch (e) {
                    convertedValue = value;
                }
            }
        }

        obj[keys[keys.length - 1]] = convertedValue;
    }

    FileView {
        path: root.filePath
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                writeAdapter();
            }
        }

        JsonAdapter {
            id: configOptionsJsonAdapter
            property JsonObject policies: JsonObject {
                property int ai: 1
                property int weeb: 1
            }

            property JsonObject ai: JsonObject {
                property string systemPrompt: "Style: casual. Use Markdown. Use Bold."
            }

            property JsonObject appearance: JsonObject {
                property int fakeScreenRounding: 2
                property bool transparency: false
                property JsonObject palette: JsonObject {
                    property string type: "auto"
                }
            }

            property JsonObject audio: JsonObject {
                property JsonObject protection: JsonObject {
                    property bool enable: true
                    property real maxAllowedIncrease: 10
                    property real maxAllowed: 90
                }
            }

            property JsonObject apps: JsonObject {
                property string bluetooth: "blueberry"
                property string network: "blueberry"
                property string networkEthernet: "kcmshell6 kcm_networkmanagement"
                property string taskManager: "htop"
                property string terminal: "kitty -1"
            }

            property JsonObject background: JsonObject {
                property bool fixedClockPosition: true
                property real clockX: 500
                property real clockY: 300
            }

            property JsonObject bar: JsonObject {
                property bool bottom: false
                property int cornerStyle: 0
                property bool borderless: false
                property string topLeftIcon: "spark"
                property bool showBackground: true
                property bool verbose: true
                property JsonObject resources: JsonObject {
                    property bool alwaysShowSwap: true
                    property bool alwaysShowCpu: false
                }
                property list<string> screenList: []
                property JsonObject utilButtons: JsonObject {
                    property bool showScreenSnip: true
                    property bool showColorPicker: true
                    property bool showMicToggle: false
                    property bool showKeyboardToggle: false
                    property bool showDarkModeToggle: true
                }
                property JsonObject tray: JsonObject {
                    property bool monochromeIcons: true
                }
                property JsonObject workspaces: JsonObject {
                    property bool monochromeIcons: true
                    property int shown: 10
                    property bool showAppIcons: true
                    property bool alwaysShowNumbers: false
                    property int showNumberDelay: 300
                }
            }

            property JsonObject battery: JsonObject {
                property int low: 20
                property int critical: 5
                property bool automaticSuspend: true
                property int suspend: 3
            }

            property JsonObject dock: JsonObject {
                property bool enable: false
                property real height: 60
                property real hoverRegionHeight: 2
                property bool pinnedOnStartup: false
                property bool hoverToReveal: true
                property list<string> pinnedApps: ["org.kde.dolphin", "kitty"]
            }

            property JsonObject language: JsonObject {
                property JsonObject translator: JsonObject {
                    property string engine: "auto"
                    property string targetLanguage: "auto"
                    property string sourceLanguage: "auto"
                }
            }

            property JsonObject networking: JsonObject {
                property string userAgent: "Mozilla/5.0"
            }

            property JsonObject osd: JsonObject {
                property int timeout: 1000
            }

            property JsonObject osk: JsonObject {
                property string layout: "qwerty_full"
                property bool pinnedOnStartup: false
            }

            property JsonObject overview: JsonObject {
                property real scale: 0.18
                property real rows: 2
                property real columns: 5
            }

            property JsonObject resources: JsonObject {
                property int updateInterval: 3000
            }

            property JsonObject search: JsonObject {
                property int nonAppResultDelay: 30
                property string engineBaseUrl: "https://www.google.com/search?q="
                property list<string> excludedSites: ["quora.com"]
                property bool sloppy: false
                property JsonObject prefix: JsonObject {
                    property string action: "/"
                    property string clipboard: ";"
                    property string emojis: ":"
                }
            }

            property JsonObject sidebar: JsonObject {
                property JsonObject translator: JsonObject {
                    property int delay: 300
                }
                property JsonObject booru: JsonObject {
                    property bool allowNsfw: false
                    property string defaultProvider: "yandere"
                    property int limit: 20
                    property JsonObject zerochan: JsonObject {
                        property string username: "[unset]"
                    }
                }
            }

            property JsonObject time: JsonObject {
                property string format: "hh:mm"
                property string dateFormat: "dddd, dd/MM"
            }

            property JsonObject windows: JsonObject {
                property bool showTitlebar: true
                property bool centerTitle: true
            }

            property JsonObject hacks: JsonObject {
                property int arbitraryRaceConditionDelay: 20
            }
        }
    }
}