import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

ColumnLayout {
    id: list
    readonly property var adapter: Bluetooth.defaultAdapter
    // Unpaired devices only once they report a name; discovery finds lots of anonymous ones
    readonly property var devices: adapter ? adapter.devices.values.filter(d => d.paired || d.deviceName !== "").sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name)) : []

    Layout.fillWidth: true
    spacing: 0
    onVisibleChanged: if (adapter?.enabled) adapter.discovering = visible

    Repeater {
        model: list.devices

        Entry {
            required property var modelData
            current: modelData.connected
            icon: "\u{f293}"
            text: modelData.name
            trailing: modelData.state === BluetoothDeviceState.Connecting ? "connecting…"
                : modelData.pairing ? "pairing…"
                : modelData.connected && modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%"
                : modelData.connected ? "\u{f00c}"
                : !modelData.paired ? "pair" : ""
            onClicked: {
                if (modelData.connected)
                    modelData.disconnect();
                else if (modelData.paired)
                    modelData.connect();
                else
                    modelData.pair();
            }
        }
    }

    Entry {
        iconSpace: true
        text: "More…"
        onClicked: Quickshell.execDetached(["blueman-manager"])
    }
}
