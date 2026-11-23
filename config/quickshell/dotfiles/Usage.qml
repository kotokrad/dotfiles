import QtQuick
import QtQuick.Layouts
import Quickshell

// Bar item and dropdown for a usage singleton (ClaudeUsage, CodexUsage); all provider specifics live there
Island {
    id: usage
    required property QsWindow bar
    required property QtObject source
    readonly property int session: pct(source.session)
    readonly property int week: pct(source.week)
    // With both limits hit, the later reset is when work can resume
    readonly property var blocking: [source.session, source.week].filter(w => pct(w) >= 100).sort((a, b) => b.resetsAt - a.resetsAt)[0] ?? null

    // A window whose reset time has passed is back to 0 even before the next fetch
    function pct(w) {
        return w && w.resetsAt > clock.date ? Math.round(w.percent) : 0;
    }
    function resetText(w) {
        const d = new Date(Math.round(w.resetsAt / 60000) * 60000); // 20:39:59 means 20:40
        return Qt.formatDateTime(d, d - clock.date < 86400000 ? "HH:mm" : "ddd HH:mm");
    }

    visible: source.usage !== null
    hoverable: true
    onClicked: panel.visible = !panel.visible

    Txt {
        text: usage.source.icon + " " + (usage.blocking ? usage.resetText(usage.blocking) : usage.session + "%")
        color: usage.session >= 80 || usage.week >= 80 ? Ui.yellow : usage.source.error ? Ui.gray : Ui.fg
    }

    SystemClock {
        id: clock
        precision: panel.visible ? SystemClock.Seconds : SystemClock.Minutes
    }

    Tooltip {
        target: usage
        text: usage.source.error || "Week: " + usage.week + "%"
    }

    Dropdown {
        id: panel
        objectName: usage.source.objectName
        target: usage
        screen: usage.bar.screen
        onVisibleChanged: if (visible) usage.source.refresh()

        ColumnLayout {
            spacing: 8

            Repeater {
                model: [{ name: "Session", w: usage.source.session }, { name: "Week", w: usage.source.week }]

                RowLayout {
                    id: limit
                    required property var modelData
                    readonly property int pct: usage.pct(modelData.w)
                    readonly property color tint: pct >= 100 ? Ui.red : pct >= 80 ? Ui.yellow : Ui.accent
                    spacing: 10

                    Txt {
                        Layout.preferredWidth: 52
                        text: limit.modelData.name
                        font.pixelSize: Ui.menuFontSize
                    }
                    Txt {
                        Layout.preferredWidth: 34
                        horizontalAlignment: Text.AlignRight
                        text: limit.pct + "%"
                        font.pixelSize: Ui.menuFontSize
                        color: limit.pct >= 80 ? limit.tint : Ui.fg
                    }
                    Rectangle {
                        implicitWidth: 54
                        implicitHeight: 4
                        radius: 2
                        color: Ui.bg2
                        Rectangle {
                            width: Math.min(1, limit.pct / 100) * parent.width
                            height: parent.height
                            radius: 2
                            color: limit.tint
                        }
                    }
                    Txt {
                        Layout.preferredWidth: 100
                        text: limit.modelData.w?.resetsAt > clock.date ? "resets " + usage.resetText(limit.modelData.w) : ""
                        color: Ui.gray
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Ui.bg1
            }

            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 6

                // details is [[label, value], ...]; flattened, labels land in the first column
                Repeater {
                    model: [].concat(...usage.source.details)

                    Txt {
                        required property string modelData
                        required property int index
                        text: modelData
                        color: index % 2 ? Ui.fg : Ui.gray
                    }
                }
            }

            Txt {
                readonly property int min: Math.floor((clock.date - usage.source.updated) / 60000)
                readonly property int secs: Math.max(0, Math.ceil((usage.source.tried - clock.date + usage.source.interval) / 1000))
                text: (min < 1 ? "updated just now" : "updated " + min + " min ago") + (usage.source.error ? " · " + usage.source.error + ", retry in " + Math.floor(secs / 60) + ":" + String(secs % 60).padStart(2, "0") : "")
                color: usage.source.error ? Ui.yellow : Ui.gray
            }
        }
    }
}
