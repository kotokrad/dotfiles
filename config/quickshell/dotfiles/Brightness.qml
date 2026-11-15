pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: brightness
    property real value: 0
    property bool available: false
    property double lastSet: 0

    function set(v) {
        // 0 turns the panel off entirely
        value = Math.max(0.01, Math.min(1, v));
        lastSet = Date.now();
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", Math.round(value * 100) + "%"]);
    }

    function refresh() {
        info.running = true;
    }

    // brightnessctl -m prints "device,class,current,percent%,max"
    Process {
        id: info
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                brightness.available = f.length === 5;
                // A read started mid-drag would snap the slider back
                if (brightness.available && Date.now() - brightness.lastSet > 1000)
                    brightness.value = parseInt(f[2]) / parseInt(f[4]);
            }
        }
    }

    // Also changed by hypridle and the brightness keys
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightness.refresh()
    }
}
