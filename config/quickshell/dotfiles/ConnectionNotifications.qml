import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire

Scope {
    id: watcher
    required property var notifications
    property bool ready: false
    property var previousBluetooth: []
    property var previousNetworks: []
    property var bluetoothNotices: ({})

    readonly property var bluetoothNodes: Pipewire.nodes.values.filter(n => n?.audio && !n.isStream && n.name.startsWith("bluez_"))

    readonly property var bluetoothConnections: Bluetooth.devices.values
        .filter(d => d.connected)
        .map(d => ({ id: d.dbusPath, name: d.name || d.address, icon: d.icon || "bluetooth",
            symbol: bluetoothSymbol(d.icon), codec: bluetoothCodec(d.address) }))

    PwObjectTracker {
        objects: watcher.bluetoothNodes
    }

    Component {
        id: noticeComponent
        ConnectionNotice {
            notifications: watcher.notifications
        }
    }

    function bluetoothSymbol(icon) {
        if (icon === "audio-headset" || icon === "audio-headphones") return "\u{f025}";
        if (icon?.startsWith("audio")) return "\u{f028}";
        if (icon === "input-keyboard") return "\u{f11c}";
        if (icon === "input-mouse") return "\u{f245}";
        if (icon === "phone") return "\u{f10b}";
        return "\u{f293}";
    }

    function bluetoothCodec(address) {
        const nodes = bluetoothNodes.filter(n => n.ready
            && n.properties?.["api.bluez5.address"]?.toUpperCase() === address.toUpperCase()
            && n.properties?.["api.bluez5.codec"]);
        const node = nodes.find(n => n.isSink) ?? nodes[0];
        const codec = node?.properties?.["api.bluez5.codec"] ?? "";
        return codec === "msbc" ? "mSBC" : codec.replace(/_/g, "-").toUpperCase();
    }

    function announceBluetooth(current, previous) {
        for (const connection of previous) {
            if (!current.some(c => c.id === connection.id))
                bluetoothNotice(connection).publish(connection.name, "Disconnected", connection.icon, connection.symbol, true);
        }
        for (const connection of current) {
            const old = previous.find(c => c.id === connection.id);
            const body = connection.codec ? "Connected · " + connection.codec : "Connected";
            if (!old)
                bluetoothNotice(connection).publish(connection.name, body, connection.icon, connection.symbol, true);
            else if (connection.codec && connection.codec !== old.codec)
                bluetoothNotices[connection.id]?.publish(connection.name, body, connection.icon, connection.symbol, false);
        }
    }

    function bluetoothNotice(connection) {
        if (!bluetoothNotices[connection.id])
            bluetoothNotices[connection.id] = noticeComponent.createObject(watcher);
        return bluetoothNotices[connection.id];
    }

    readonly property var networkConnections: Networking.devices.values.filter(d => d.connected).map(d => {
        if (d.type === DeviceType.Wifi) {
            const network = d.networks.values.find(n => n.connected);
            return network ? { id: JSON.stringify([d.name, network.name]), name: network.name, icon: "network-wireless" } : null;
        }
        if (d.type === DeviceType.Wired)
            return { id: d.name, name: "Ethernet (" + d.name + ")", icon: "network-wired" };
        return null;
    }).filter(c => c !== null)

    function notify(title, body, icon) {
        // Device names and SSIDs are plain text; the notification body supports markup.
        const escaped = body.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        Quickshell.execDetached(["notify-send", "--app-name", "Quickshell", "--icon", icon, "--transient", "--", title, escaped]);
    }

    function announceChanges(current, previous, title) {
        for (const connection of previous) {
            if (!current.some(c => c.id === connection.id))
                notify(title + " disconnected", "Disconnected from " + connection.name, connection.icon);
        }
        for (const connection of current) {
            if (!previous.some(c => c.id === connection.id))
                notify(title + " connected", "Connected to " + connection.name, connection.icon);
        }
    }

    onBluetoothConnectionsChanged: if (ready) settle.restart()
    onNetworkConnectionsChanged: if (ready) settle.restart()

    // Seed the current state after the services load, including on a QML reload.
    Timer {
        interval: 1500
        running: true
        onTriggered: {
            watcher.previousBluetooth = watcher.bluetoothConnections;
            watcher.previousNetworks = watcher.networkConnections;
            watcher.ready = true;
        }
    }

    // NetworkManager may update the device and active network in separate steps.
    Timer {
        id: settle
        interval: 1000
        onTriggered: {
            watcher.announceBluetooth(watcher.bluetoothConnections, watcher.previousBluetooth);
            watcher.announceChanges(watcher.networkConnections, watcher.previousNetworks, "Network");
            watcher.previousBluetooth = watcher.bluetoothConnections;
            watcher.previousNetworks = watcher.networkConnections;
        }
    }
}
