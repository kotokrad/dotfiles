pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: vpn
    property bool mullvad: false
    property bool tailscale: false
    property string location: ""
    readonly property var options: [["mullvad", "Mullvad"], ["tailscale", "Tailscale"]]

    function toggle(name) {
        if (name === "mullvad") {
            mullvadRun.command = ["mullvad", mullvad ? "disconnect" : "connect"];
            mullvadRun.running = true;
        } else {
            tailscaleRun.command = ["tailscale", tailscale ? "down" : "up"];
            tailscaleRun.running = true;
        }
    }

    // One process each, so flipping both quickly doesn't drop the second command
    Process {
        id: mullvadRun
        onExited: poll.running = true
    }

    Process {
        id: tailscaleRun
        onExited: poll.running = true
    }

    Process {
        id: poll
        command: ["sh", "-c", "mullvad status --json | jq -r '.state, ([.details.location?.city, .details.location?.country] | map(values) | join(\", \"))'; tailscale status --json | jq -r .BackendState"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [m, l, t] = text.split("\n");
                vpn.mullvad = m === "connected";
                vpn.location = vpn.mullvad ? l : "";
                vpn.tailscale = t === "Running";
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
