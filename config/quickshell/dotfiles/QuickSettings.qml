import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.UPower

Dropdown {
    id: popup
    required property var bar
    property string open: "" // expanded list: wifi, bt, vpn, theme
    property string armed: "" // power action waiting for a second click
    property bool nightLight: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var btConnected: adapter ? adapter.devices.values.filter(d => d.connected) : []
    readonly property int pct: Math.round(UPower.displayDevice.percentage * 100)

    function toggle(name) {
        open = open === name ? "" : name;
    }

    screen: bar.screen
    onVisibleChanged: {
        open = "";
        armed = "";
        if (visible)
            gammastep.running = true;
    }

    Process {
        id: gammastep
        command: ["systemctl", "--user", "is-active", "gammastep"]
        stdout: StdioCollector {
            onStreamFinished: popup.nightLight = text.trim() === "active"
        }
    }

    ColumnLayout {
        Layout.preferredWidth: 316
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Txt {
                Layout.fillWidth: true
                visible: UPower.displayDevice.isLaptopBattery
                text: Ui.batteryIcon(popup.pct, UPower.displayDevice.state === UPowerDeviceState.Charging) + " " + popup.pct + "%"
                font.pixelSize: Ui.menuFontSize
            }

            Repeater {
                model: [
                    { id: "lock", icon: "\u{f033e}", cmd: ["loginctl", "lock-session"] },
                    { id: "logout", icon: "\u{f0343}", cmd: ["mmsg", "dispatch", "quit"], confirm: true },
                    { id: "suspend", icon: "\u{f04b2}", cmd: ["systemctl", "suspend"] },
                    { id: "reboot", icon: "\u{f0709}", cmd: ["systemctl", "reboot"], confirm: true },
                    { id: "poweroff", icon: "\u{f0425}", cmd: ["systemctl", "poweroff"], confirm: true }
                ]

                // Logout, reboot and poweroff take a second click (the button turns red first)
                IconButton {
                    id: button
                    required property var modelData
                    readonly property bool armed: popup.armed === modelData.id

                    implicitWidth: 28
                    implicitHeight: 28
                    icon: modelData.icon
                    glyphSize: 13
                    glyphColor: armed ? Ui.bg : Ui.fg
                    color: armed ? Ui.red : hovered ? Ui.bg2 : Ui.bg1
                    onClicked: {
                        if (button.modelData.confirm && !button.armed) {
                            popup.armed = button.modelData.id;
                            return;
                        }
                        popup.visible = false;
                        Quickshell.execDetached(button.modelData.cmd);
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 8
            uniformCellWidths: true

            Tile {
                icon: popup.bar.wifiNet ? Ui.wifiIcon(popup.bar.wifiNet.signalStrength) : "\u{f092d}"
                label: "Wi-Fi"
                status: popup.bar.wifiNet?.name ?? (Networking.wifiEnabled ? "Disconnected" : "Off")
                active: Networking.wifiEnabled
                expandable: true
                expanded: popup.open === "wifi"
                onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                onExpand: popup.toggle("wifi")
            }

            Tile {
                icon: popup.btConnected.length ? "\u{f00b1}" : popup.adapter?.enabled ? "\u{f293}" : "\u{f00b2}"
                label: "Bluetooth"
                status: popup.btConnected.length === 1 ? popup.btConnected[0].name
                    : popup.btConnected.length > 1 ? popup.btConnected.length + " devices"
                    : popup.adapter?.enabled ? "On" : "Off"
                active: popup.adapter?.enabled ?? false
                expandable: true
                expanded: popup.open === "bt"
                onToggled: if (popup.adapter) popup.adapter.enabled = !popup.adapter.enabled
                onExpand: popup.toggle("bt")
            }

            Tile {
                icon: "\u{f0582}"
                label: "VPN"
                status: ({ mullvad: "Mullvad", tailscale: "Tailscale" })[Vpn.active] ?? "Off"
                active: Vpn.active !== ""
                expandable: true
                expanded: popup.open === "vpn"
                onToggled: Vpn.active !== "" ? Vpn.set("") : popup.toggle("vpn")
                onExpand: popup.toggle("vpn")
            }

            Tile {
                readonly property var profiles: PowerProfiles.hasPerformanceProfile ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance] : [PowerProfile.PowerSaver, PowerProfile.Balanced]
                icon: ({ [PowerProfile.PowerSaver]: "\u{f032a}", [PowerProfile.Performance]: "\u{f04c5}" })[PowerProfiles.profile] ?? "\u{f05d1}"
                label: "Power"
                status: ({ [PowerProfile.PowerSaver]: "Power saver", [PowerProfile.Performance]: "Performance" })[PowerProfiles.profile] ?? "Balanced"
                active: PowerProfiles.profile !== PowerProfile.Balanced
                onToggled: PowerProfiles.profile = profiles[(profiles.indexOf(PowerProfiles.profile) + 1) % profiles.length]
            }

            Tile {
                icon: "\u{f0176}"
                label: "Caffeine"
                status: Ui.idleInhibit ? "On" : "Off"
                active: Ui.idleInhibit
                onToggled: Ui.idleInhibit = !Ui.idleInhibit
            }

            Tile {
                icon: Ui.quiet ? "\u{f009b}" : "\u{f009a}"
                label: "Do not disturb"
                status: Ui.dnd ? "On" : Ui.screencast ? "While sharing" : "Off"
                active: Ui.quiet
                onToggled: Ui.dnd = !Ui.dnd
            }

            Tile {
                icon: "\u{f0594}"
                label: "Night light"
                status: popup.nightLight ? "On" : "Off"
                active: popup.nightLight
                onToggled: {
                    popup.nightLight = !popup.nightLight;
                    Quickshell.execDetached(["systemctl", "--user", popup.nightLight ? "start" : "stop", "gammastep"]);
                }
            }

            Tile {
                icon: "\u{f03d8}"
                label: "Accent"
                status: Ui.accentName
                active: true
                expandable: true
                expanded: popup.open === "theme"
                onToggled: popup.toggle("theme")
                onExpand: popup.toggle("theme")
            }
        }

        WifiList {
            visible: popup.open === "wifi"
            device: popup.bar.wifi
        }

        BluetoothList {
            visible: popup.open === "bt"
        }

        GridLayout {
            Layout.fillWidth: true
            visible: popup.open === "theme"
            columns: 5
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: Ui.accents

                Rectangle {
                    id: swatch
                    required property var modelData
                    readonly property bool current: modelData.name === Ui.accentName

                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: Ui.radius
                    color: modelData.color
                    border.width: pick.containsMouse && !current ? 2 : 0
                    border.color: Ui.fg

                    Txt {
                        anchors.centerIn: parent
                        visible: swatch.current
                        text: "\u{f012c}"
                        font.pixelSize: 13
                        color: Ui.bg
                    }

                    MouseArea {
                        id: pick
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Ui.accentName = swatch.modelData.name
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: popup.open === "vpn"
            spacing: 0

            Repeater {
                model: Vpn.options
                Entry {
                    required property var modelData
                    current: modelData[0] !== "" && Vpn.active === modelData[0]
                    iconSpace: true
                    icon: current ? "\u{f00c}" : ""
                    text: modelData[1]
                    onClicked: Vpn.set(modelData[0])
                }
            }
        }
    }
}
