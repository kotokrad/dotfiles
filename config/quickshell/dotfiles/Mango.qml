pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property var monitors: []
    property var clients: []
    property string activeTags: "" // changes only when a monitor switches tags (panels close then)
    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === monitors.find(m => m.active)?.name) ?? Quickshell.screens[0]

    function monitor(name) {
        return monitors.find(m => m.name === name) ?? null;
    }

    function dispatch(cmd) {
        Quickshell.execDetached(["mmsg", "dispatch", cmd]);
    }

    Process {
        id: watch
        command: ["mmsg", "watch", "all-monitors"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    monitors = JSON.parse(line).monitors;
                } catch (e) {
                    return;
                }
                activeTags = JSON.stringify(monitors.map(m => m.active_tags));
            }
        }
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 1000
        onTriggered: watch.running = true
    }

    Process {
        id: watchClients
        command: ["mmsg", "watch", "all-clients"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    clients = JSON.parse(line).clients;
                } catch (e) {}
            }
        }
        onExited: restartClients.start()
    }

    Timer {
        id: restartClients
        interval: 1000
        onTriggered: watchClients.running = true
    }
}
