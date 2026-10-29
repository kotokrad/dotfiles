import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

ColumnLayout {
    id: list
    required property var device
    property string askFor: "" // network waiting for a password

    readonly property var networks: device ? device.networks.values.slice().sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength)) : []

    Layout.fillWidth: true
    spacing: 0
    onVisibleChanged: {
        if (device)
            device.scannerEnabled = visible;
        askFor = "";
    }

    Repeater {
        model: list.networks

        ColumnLayout {
            id: row
            required property var modelData
            Layout.fillWidth: true
            spacing: 2

            Entry {
                current: row.modelData.connected
                icon: Ui.wifiIcon(row.modelData.signalStrength)
                text: row.modelData.name
                trailing: row.modelData.state === ConnectionState.Connecting ? "connecting…"
                    : row.modelData.connected ? "\u{f00c}"
                    : !row.modelData.known && row.modelData.security !== WifiSecurityType.Open ? "\u{f023}" : ""
                onClicked: {
                    const n = row.modelData;
                    if (n.connected)
                        return;
                    if (n.known || n.security === WifiSecurityType.Open)
                        n.connect();
                    else
                        list.askFor = n.name;
                }
            }

            TextField {
                id: psk
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                visible: list.askFor === row.modelData.name
                onVisibleChanged: if (visible) forceActiveFocus()
                echoMode: TextInput.Password
                placeholderText: "Password"
                placeholderTextColor: Ui.gray
                color: Ui.fg
                font.family: Ui.font
                font.pixelSize: Ui.menuFontSize
                background: Rectangle {
                    radius: Ui.radius
                    color: Ui.bg1
                    border.width: 1
                    border.color: psk.activeFocus ? Ui.accent : Ui.bg2
                }
                onAccepted: {
                    row.modelData.connectWithPsk(text);
                    text = "";
                    list.askFor = "";
                }
            }
        }
    }

    Entry {
        iconSpace: true
        text: "More…"
        onClicked: Quickshell.execDetached(["nm-connection-editor"])
    }
}
