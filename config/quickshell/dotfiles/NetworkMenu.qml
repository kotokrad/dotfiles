import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking

ColumnLayout {
    id: menu
    property string psk: ""
    property bool reveal: false
    property bool showQr: false

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNet: wifi?.networks.values.find(n => n.connected) ?? null
    readonly property string ssid: wifiNet?.name ?? ""
    readonly property var wired: Networking.devices.values.filter(d => d.type === DeviceType.Wired)
    readonly property string qrPath: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-wifi-qr.png"

    signal done

    // Prefetched: nmcli takes a moment
    onSsidChanged: {
        psk = "";
        if (ssid !== "")
            pskProc.running = true;
    }

    function refresh() {
        reveal = false;
        showQr = false;
        if (ssid !== "")
            pskProc.running = true;
    }

    // WIFI: QR strings need \ ; , : " escaped
    function qrEscape(s) {
        return s.replace(/([\\;,:"])/g, "\\$1");
    }

    Layout.preferredWidth: 300
    spacing: 12

    component Header: RowLayout {
        id: header
        property string title
        property bool on
        signal toggled

        Layout.fillWidth: true

        Txt {
            Layout.fillWidth: true
            text: header.title
            font.pixelSize: Ui.menuFontSize
        }

        Rectangle {
            implicitWidth: 30
            implicitHeight: 16
            radius: height / 2
            color: header.on ? Ui.accent : Ui.bg2

            Rectangle {
                x: header.on ? parent.width - width - 2 : 2
                y: 2
                width: 12
                height: 12
                radius: 6
                color: Ui.fg
                Behavior on x {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: header.toggled()
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: !!menu.wifi
        spacing: 6

        Header {
            title: "Wi-Fi"
            on: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        Txt {
            visible: !!menu.wifiNet
            text: (menu.wifiNet ? Ui.wifiIcon(menu.wifiNet.signalStrength) : "") + "  " + (menu.wifiNet?.name ?? "")
            font.pixelSize: Ui.menuFontSize
        }

        RowLayout {
            Layout.fillWidth: true
            visible: menu.psk !== ""
            spacing: 6

            Txt {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: menu.reveal ? menu.psk : "•".repeat(menu.psk.length)
                font.pixelSize: Ui.menuFontSize
                font.bold: false
            }
            IconButton {
                icon: menu.reveal ? "\u{f070}" : "\u{f06e}"
                onClicked: menu.reveal = !menu.reveal
            }
            IconButton {
                icon: "\u{f018f}"
                onClicked: Quickshell.clipboardText = menu.psk
            }
            IconButton {
                icon: "\u{f0432}"
                color: menu.showQr || hovered ? Ui.bg2 : Ui.bg1
                onClicked: {
                    menu.showQr = !menu.showQr;
                    if (menu.showQr)
                        qrProc.running = true;
                }
            }
        }

        Image {
            id: qr
            Layout.alignment: Qt.AlignHCenter
            visible: menu.showQr && status === Image.Ready
            cache: false
            smooth: false
            sourceSize.width: 160
            sourceSize.height: 160
        }
    }

    Repeater {
        model: menu.wired

        ColumnLayout {
            id: nic
            required property var modelData
            Layout.fillWidth: true
            spacing: 6

            Header {
                title: "Ethernet" + (menu.wired.length > 1 ? " (" + nic.modelData.name + ")" : "")
                on: nic.modelData.connected
                onToggled: Quickshell.execDetached(["nmcli", "device", nic.modelData.connected ? "disconnect" : "connect", nic.modelData.name])
            }
            Txt {
                visible: !nic.modelData.hasLink
                text: "Cable unplugged"
                font.pixelSize: Ui.menuFontSize
                font.bold: false
                color: Ui.gray
            }
        }
    }

    Entry {
        // Line the text up with the headers; the hover background reaches into the padding
        Layout.leftMargin: -8
        Layout.rightMargin: -8
        text: "Network settings…"
        onClicked: {
            menu.done();
            Quickshell.execDetached(["nm-connection-editor"]);
        }
    }

    // The connection name can differ from the SSID
    Process {
        id: pskProc
        command: ["sh", "-c", "nmcli -s -g 802-11-wireless-security.psk connection show id \"$(nmcli -g GENERAL.CONNECTION device show \"$1\")\"", "sh", menu.wifi?.name ?? ""]
        stdout: StdioCollector {
            onStreamFinished: menu.psk = text.trim()
        }
    }

    Process {
        id: qrProc
        command: ["qrencode", "-t", "PNG", "-s", "6", "-m", "2", "-o", menu.qrPath, "WIFI:T:WPA;S:" + menu.qrEscape(menu.wifiNet?.name ?? "") + ";P:" + menu.qrEscape(menu.psk) + ";;"]
        onExited: code => {
            qr.source = "";
            if (code === 0)
                qr.source = "file://" + menu.qrPath;
        }
    }
}
