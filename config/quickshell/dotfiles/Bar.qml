import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

PanelWindow {
    id: bar
    required property ShellScreen modelData
    readonly property var monitor: Mango.monitor(modelData.name)
    readonly property string title: monitor?.active_client?.title ?? ""
    // Monocle hides all but one window, so the title island lists the tag's windows
    readonly property var tabs: monitor?.layout_symbol === "M"
        ? Mango.clients.filter(c => c.monitor === modelData.name && !c.is_floating && !c.is_minimized
            && c.tags.some(t => monitor.active_tags.includes(t)))
        : []
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNet: wifi?.networks.values.find(n => n.connected) ?? null
    readonly property bool wired: Networking.devices.values.some(d => d.type === DeviceType.Wired && d.connected)
    readonly property var battery: UPower.displayDevice
    // Draw on battery, charge rate when plugged in
    property real watts: 0
    property real volts: 0
    readonly property real notchWidth: Ui.notch.screen === modelData.name ? Ui.notch.width : 0
    // Text room between the tags and the right islands: the row's margin, two gaps and the island's
    // padding
    readonly property real titleRoom: notchWidth > 0 ? rightRow.x - tags.width - 3 * Ui.gap - 16 : Infinity

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: Ui.barHeight
    color: "transparent"

    IdleInhibitor {
        window: bar
        enabled: Ui.idleInhibit
    }

    PwObjectTracker {
        objects: [bar.sink, bar.source]
    }

    // Read from sysfs: UPower's changeRate only refreshes every 30-60 s. Batteries that count
    // charge instead of energy have current and voltage but no power
    FileView {
        id: batteryInfo
        readonly property var device: UPower.devices.values.find(d => d.isLaptopBattery)
        path: device ? `/sys/class/power_supply/${device.nativePath}/uevent` : ""
        onLoaded: {
            const field = name => text().match(new RegExp(`^POWER_SUPPLY_${name}=(.*)$`, "m"))?.[1];
            const microwatts = field("POWER_NOW") ?? field("CURRENT_NOW") * field("VOLTAGE_NOW") / 1e6;
            bar.watts = Math.abs(microwatts) / 1e6;
            bar.volts = field("VOLTAGE_NOW") / 1e6;
        }
    }
    Timer {
        interval: 3000
        running: bar.battery.isLaptopBattery
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryInfo.reload()
    }

    QuickSettings {
        id: settings
        bar: bar
        target: status
    }

    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Ui.gap
        anchors.bottom: parent.bottom
        spacing: Ui.gap

        Tags {
            id: tags
            monitorName: bar.modelData.name
        }

        Island {
            visible: bar.title !== "" && bar.tabs.length < 2
            Txt {
                Layout.maximumWidth: Math.min(400, bar.titleRoom)
                text: bar.title
                elide: Text.ElideRight
            }
        }

        Repeater {
            model: bar.tabs.length > 1 ? bar.tabs : []
            Island {
                id: tab
                required property var modelData
                readonly property bool active: modelData.id === bar.monitor?.active_client?.id
                hoverable: !active
                opacity: active || hovered ? 1 : 0.55
                onClicked: if (!active) Quickshell.execDetached(["mmsg", "dispatch", "focusid", "client," + modelData.id])
                Txt {
                    Layout.maximumWidth: Math.min(tab.active ? 250 : 100, (bar.titleRoom - (bar.tabs.length - 1) * (16 + Ui.gap)) / bar.tabs.length)
                    text: tab.modelData.title
                    elide: Text.ElideRight
                }
            }
        }
    }

    RowLayout {
        id: rightRow
        anchors.right: parent.right
        anchors.rightMargin: Ui.gap
        // With a notch: up to VPN end a gap before it, the rest spans from a gap after it to the edge
        anchors.left: bar.notchWidth > 0 ? parent.left : undefined
        anchors.leftMargin: (bar.width - bar.notchWidth) / 2 - Ui.gap - vpn.x - vpn.width
        anchors.bottom: parent.bottom
        spacing: Ui.gap

        // Media {}
        Privacy {}

        // Usage {
        //     bar: bar
        //     source: CodexUsage
        // }

        Usage {
            bar: bar
            source: ClaudeUsage
        }

        Island {
            id: vpn
            readonly property string names: [Vpn.mullvad ? "mullvad" : "", Vpn.tailscale ? "ts" : ""].filter(s => s).join(" + ")
            hoverable: true
            color: names === "" ? (hovered ? Qt.lighter(Ui.yellow, 1.15) : Ui.yellow) : hovered ? Ui.bg2 : panelOpen ? Ui.bg1 : Ui.bg0
            onClicked: vpnMenu.visible = !vpnMenu.visible
            Txt {
                text: "\u{f0582} " + (vpn.names || "disconnected")
                color: vpn.names === "" ? Ui.bg : Ui.fg
            }

            Tooltip {
                target: vpn
                text: Vpn.location
            }

            Dropdown {
                id: vpnMenu
                target: vpn
                screen: bar.screen

                ColumnLayout {
                    Layout.preferredWidth: 192
                    spacing: 12

                    Repeater {
                        model: Vpn.options
                        Header {
                            required property var modelData
                            title: modelData[1]
                            on: Vpn[modelData[0]]
                            onToggled: Vpn.toggle(modelData[0])
                        }
                    }
                }
            }
        }

        Item {
            visible: bar.notchWidth > 0
            implicitWidth: bar.notchWidth
            Layout.minimumWidth: bar.notchWidth
        }

        Island {
            id: network
            property string ip: ""

            // The only island that shrinks: the network name gets cut short when the row doesn't fit
            Layout.fillWidth: true
            Layout.preferredWidth: netLabel.implicitWidth + 16
            Layout.maximumWidth: netLabel.implicitWidth + 16
            hoverable: true
            onHoveredChanged: if (hovered) ipProc.running = true
            onClicked: netMenu.visible = !netMenu.visible

            Txt {
                id: netLabel
                Layout.maximumWidth: network.width - 16
                text: bar.wired ? "\u{f0200} Ethernet"
                    : bar.wifiNet ? Ui.wifiIcon(bar.wifiNet.signalStrength) + " " + bar.wifiNet.name
                    : "\u{f092d}"
                elide: Text.ElideRight
            }

            Process {
                id: ipProc
                command: ["ip", "-4", "-br", "addr", "show", "scope", "global"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        const devices = Networking.devices.values.filter(d => d.connected).map(d => d.name);
                        network.ip = text.trim().split("\n").map(l => l.split(/\s+/)).filter(f => devices.includes(f[0])).map(f => f[2].split("/")[0]).join("\n");
                    }
                }
            }

            Tooltip {
                target: network
                text: network.ip
            }

            Dropdown {
                id: netMenu
                target: network
                screen: bar.screen
                onVisibleChanged: if (visible) netContent.refresh()

                NetworkMenu {
                    id: netContent
                    onDone: netMenu.visible = false
                }
            }
        }

        Item {
            visible: bar.notchWidth > 0
            Layout.fillWidth: true
        }

        Island {
            id: sound
            Layout.leftMargin: bar.notchWidth > 0 ? -Ui.gap : 0 // one gap around the spacer, not two
            readonly property var out: bar.sink?.audio ?? null
            readonly property bool bluetooth: bar.sink?.properties?.["device.api"] === "bluez5" || (bar.sink?.name?.startsWith("bluez_output.") ?? false)

            hoverable: true
            onClicked: audioMenu.visible = !audioMenu.visible
            onScrolled: steps => {
                if (sound.out)
                    sound.out.volume = Math.max(0, Math.min(1, sound.out.volume + steps * 0.01));
            }

            Txt {
                text: (sound.bluetooth ? "\u{f025} " : !sound.out || sound.out.muted ? "\u{f0581} " : "\u{f057e} ") + Math.round((sound.out?.volume ?? 0) * 100) + "%"
                color: !sound.out || sound.out.muted ? Ui.gray : Ui.fg
            }

            Tooltip {
                target: sound
                text: bar.sink?.description ?? ""
            }

            Dropdown {
                id: audioMenu
                target: sound
                screen: bar.screen

                AudioProfiles {
                    id: audioProfiles
                    active: audioMenu.visible
                }

                ColumnLayout {
                    Layout.preferredWidth: 252
                    spacing: 12

                    AudioSection {
                        sink: true
                        profiles: audioProfiles
                    }
                    AudioSection {
                        sink: false
                        profiles: audioProfiles
                    }

                    Txt {
                        Layout.fillWidth: true
                        visible: audioProfiles.error !== ""
                        text: audioProfiles.error
                        color: Ui.yellow
                        font.bold: false
                        wrapMode: Text.Wrap
                    }

                    Entry {
                        icon: "\u{f1de}"
                        text: "Sound settings"
                        onClicked: {
                            audioMenu.visible = false;
                            Quickshell.execDetached(["pavucontrol"]);
                        }
                    }
                }
            }
        }

        Sensors {
            bar: bar
        }

        Tray {
            bar: bar
        }

        Island {
            hoverable: true
            onClicked: Mango.dispatch("switch_keyboard_layout,0")
            Txt {
                text: Ui.kbLayouts[bar.monitor?.keyboardlayout] ?? bar.monitor?.keyboardlayout ?? ""
            }
        }

        Island {
            id: status
            readonly property int pct: Math.round(bar.battery.percentage * 100)
            readonly property bool charging: bar.battery.state === UPowerDeviceState.Charging
            // The gauge's last ~10% is a guess; the cutoff goes by voltage
            readonly property bool showVolts: Ui.lowVoltage > 0 && !charging && pct < 15

            hoverable: true
            spacing: 10
            onClicked: settings.visible = !settings.visible

            Txt {
                visible: Ui.idleInhibit
                text: "\u{f0176}"
            }
            Txt {
                visible: Ui.quiet
                text: "\u{f009b}"
            }
            Txt {
                visible: bar.battery.isLaptopBattery
                text: Ui.batteryIcon(status.pct, status.charging) + " "
                    + (status.showVolts ? bar.volts.toFixed(1) + "V" : status.pct + "%")
                color: status.charging ? Ui.fg : status.pct < 15 ? Ui.red : status.pct < 30 ? Ui.yellow : Ui.fg
            }
            Txt {
                visible: bar.battery.isLaptopBattery && bar.watts > 0
                text: bar.watts.toFixed(1) + "W"
                color: Ui.gray
            }
        }

        Island {
            id: clockIsland
            hoverable: true
            onClicked: calendar.visible = !calendar.visible

            Txt {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }
            }

            Tooltip {
                target: clockIsland
                text: Qt.formatDateTime(clock.date, "dddd, d MMM yyyy")
            }

            Calendar {
                id: calendar
                target: clockIsland
                screen: bar.screen
            }
        }
    }
}
