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

    // Extension popups get their title after they map, too late for a window rule
    property var popups: []
    onClientsChanged: {
        const found = clients.filter(c => /^(Extension:|_crx_)/.test(c.title));
        for (const c of found) {
            if (!popups.includes(c.id) && !c.is_floating)
                Quickshell.execDetached(["sh", "-c", "mmsg dispatch togglefloating client,$1 && mmsg dispatch resizewin,400,600 client,$1 && mmsg dispatch centerwin client,$1", "sh", String(c.id)]);
        }
        popups = found.map(c => c.id);
    }

    // They close on losing focus, so the pointer must not take it
    readonly property bool sloppyFocus: popups.length === 0
    onSloppyFocusChanged: dispatch("setoption,sloppy_focus," + (sloppyFocus ? 1 : 0))
    Component.onCompleted: dispatch("setoption,sloppy_focus,1")
}
