pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: vpn
    property bool mullvad: false
    property bool tailscale: false
    property bool mullvadPending: false
    property bool tailscalePending: false
    property string location: ""
    readonly property var options: [["mullvad", "Mullvad"], ["tailscale", "Tailscale"]]

    function toggle(name) {
        if (vpn[name + "Pending"])
            return;
        vpn[name + "Pending"] = true;
        release.restart();
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
                if (!mullvadRun.running && m !== "connecting" && m !== "disconnecting")
                    vpn.mullvadPending = false;
                if (!tailscaleRun.running && t !== "Starting")
                    vpn.tailscalePending = false;
            }
        }
    }

    // Mullvad can sit in connecting (no network); don't lock the row forever
    Timer {
        id: release
        interval: 20000
        onTriggered: {
            vpn.mullvadPending = false;
            vpn.tailscalePending = false;
        }
    }

    Timer {
        interval: vpn.mullvadPending || vpn.tailscalePending ? 1000 : 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poll.running = true
    }
}
