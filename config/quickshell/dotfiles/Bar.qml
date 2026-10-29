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
            monitorName: bar.modelData.name
        }

        Island {
            visible: bar.title !== "" && bar.tabs.length < 2
            Txt {
                Layout.maximumWidth: 400
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
                    Layout.maximumWidth: tab.active ? 250 : 100
                    text: tab.modelData.title
                    elide: Text.ElideRight
                }
            }
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: Ui.gap
        anchors.bottom: parent.bottom
        spacing: Ui.gap

        // Media {}
        Privacy {}

        Claude {
            bar: bar
        }

        Island {
            id: vpn
            readonly property bool off: Vpn.active === ""
            hoverable: true
            color: off ? (hovered ? Qt.lighter(Ui.yellow, 1.15) : Ui.yellow) : (hovered ? Ui.bg2 : Ui.bg0)
            onClicked: Vpn.switcherOpen = true
            Txt {
                text: "\u{f0582} " + (vpn.off ? "disconnected" : Vpn.active)
                color: vpn.off ? Ui.bg : Ui.fg
            }
        }

        Island {
            id: network
            property string ip: ""

            hoverable: true
            onHoveredChanged: if (hovered) ipProc.running = true
            onClicked: netMenu.visible = !netMenu.visible

            Txt {
                text: bar.wired ? "\u{f0200} Ethernet"
                    : bar.wifiNet ? Ui.wifiIcon(bar.wifiNet.signalStrength) + " " + bar.wifiNet.name
                    : "\u{f092d}"
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
                visible: network.hovered && text !== "" && !netMenu.visible
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

        // Esim {}

        Island {
            id: sound
            readonly property var out: bar.sink?.audio ?? null
            readonly property var mic: bar.source?.audio ?? null

            hoverable: true
            spacing: 8
            onClicked: audioMenu.visible = !audioMenu.visible
            onScrolled: steps => {
                if (sound.out)
                    sound.out.volume = Math.max(0, Math.min(1, sound.out.volume + steps * 0.01));
            }

            Txt {
                text: (!sound.out || sound.out.muted ? "\u{f0581} " : "\u{f057e} ") + Math.round((sound.out?.volume ?? 0) * 100) + "%"
                color: !sound.out || sound.out.muted ? Ui.gray : Ui.fg
            }
            Hairline {
                visible: !!sound.mic
            }
            Txt {
                visible: !!sound.mic
                text: (sound.mic?.muted ? "\u{f036d} " : "\u{f036c} ") + Math.round((sound.mic?.volume ?? 0) * 100) + "%"
                color: sound.mic?.muted ? Ui.gray : Ui.fg
            }

            Tooltip {
                target: sound
                text: bar.sink?.description ?? ""
                visible: sound.hovered && text !== "" && !audioMenu.visible
            }

            Dropdown {
                id: audioMenu
                target: sound
                screen: bar.screen

                ColumnLayout {
                    Layout.preferredWidth: 316
                    spacing: 12

                    AudioSection {
                        sink: true
                    }
                    AudioSection {
                        sink: false
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
                text: Ui.batteryIcon(status.pct, status.charging) + " " + status.pct + "%"
                color: status.charging ? Ui.fg : status.pct < 15 ? Ui.red : status.pct < 30 ? Ui.yellow : Ui.fg
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

            Calendar {
                id: calendar
                target: clockIsland
                screen: bar.screen
            }
        }
    }
}
