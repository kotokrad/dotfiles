pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: vpn
    property string active: ""
    property bool switcherOpen: false
    readonly property var options: [["tailscale", "Tailscale"], ["mullvad", "Mullvad"], ["", "Disconnect"]]

    function set(which) {
        run.command = ["sh", "-c", {
            tailscale: "mullvad disconnect; tailscale up",
            mullvad: "tailscale down; mullvad connect",
            "": "tailscale down; mullvad disconnect"
        }[which]];
        run.running = true;
    }

    Process {
        id: run
        onExited: poll.running = true
    }

    Process {
        id: poll
        command: ["sh", "-c", "mullvad status | head -1; tailscale status --json | jq -r .BackendState"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [m, t] = text.split("\n");
                vpn.active = m.startsWith("Connected") ? "mullvad" : t === "Running" ? "tailscale" : "";
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poll.running = true
    }
}
