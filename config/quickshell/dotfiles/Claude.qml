import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// The endpoint behind Claude Code's /usage (internal, may change)
Island {
    id: claude
    required property QsWindow bar
    property var usage: null
    property date updated
    property date tried
    property string error: ""

    // A window whose reset time has passed is back to 0 even before the next fetch
    function pct(w) {
        return w?.resets_at && new Date(w.resets_at) > clock.date ? Math.round(w.utilization) : 0;
    }
    function resetText(w) {
        const d = new Date(Math.round(Date.parse(w.resets_at) / 60000) * 60000); // the API says 20:39:59.9 for 20:40
        return "resets " + Qt.formatDateTime(d, d - clock.date < 86400000 ? "HH:mm" : "ddd HH:mm");
    }

    readonly property int session: pct(usage?.five_hour)
    readonly property int week: pct(usage?.seven_day)
    // The weekly limit outlasts the 5-hour one, so it wins when both are hit
    readonly property var blocking: week >= 100 ? usage.seven_day : session >= 100 ? usage.five_hour : null

    visible: usage !== null
    hoverable: true
    onClicked: panel.visible = !panel.visible

    Txt {
        text: "\u{f06a9} " + (claude.blocking ? claude.resetText(claude.blocking) : claude.session + "%")
        color: claude.blocking || claude.session >= 80 ? Ui.yellow : claude.error ? Ui.gray : Ui.fg
    }

    SystemClock {
        id: clock
        precision: panel.visible ? SystemClock.Seconds : SystemClock.Minutes
    }

    Process {
        id: curl
        command: ["sh", "-c", "curl -s -m 10 https://api.anthropic.com/api/oauth/usage -H 'anthropic-beta: oauth-2025-04-20' -H \"Authorization: Bearer $(jq -r .claudeAiOauth.accessToken ~/.claude/.credentials.json)\""]
        stdout: StdioCollector {
            // Errors come back as {"type":"error","error":{"message":"OAuth access token is invalid."}}; offline gives no output
            onStreamFinished: {
                let r = null;
                try {
                    r = JSON.parse(text);
                } catch (e) {}
                if (r && r.type !== "error") {
                    claude.usage = r;
                    claude.updated = new Date();
                    claude.error = "";
                } else {
                    claude.error = r?.error?.message?.replace(/^OAuth |\.$/g, "") || "no response";
                }
            }
        }
    }

    Timer {
        id: poll
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            claude.tried = new Date();
            curl.running = true;
        }
    }

    Dropdown {
        id: panel
        target: claude
        screen: claude.bar.screen
        // Opening fetches now and restarts the 5-min countdown; at most once a minute, the endpoint rate-limits
        onVisibleChanged: if (visible && new Date() - claude.tried > 60000) poll.restart()

        ColumnLayout {
            spacing: 8

            Repeater {
                model: [{ name: "Session", w: claude.usage?.five_hour }, { name: "Week", w: claude.usage?.seven_day }]

                RowLayout {
                    id: limit
                    required property var modelData
                    readonly property int pct: claude.pct(modelData.w)
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
                        implicitWidth: 120
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
                        text: limit.pct > 0 ? claude.resetText(limit.modelData.w) : ""
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

                Txt {
                    text: "This week"
                    color: Ui.gray
                }
                Txt {
                    text: (claude.usage?.seven_day_breakdown?.rows ?? []).filter(r => r.percent > 0).map(r => r.display_name + " " + r.percent + "%").join(" · ") || "nothing yet"
                }
                Txt {
                    text: "Extra usage"
                    color: Ui.gray
                }
                Txt {
                    readonly property var used: claude.usage?.spend?.used
                    text: claude.usage?.spend?.enabled ? (used.amount_minor / 10 ** used.exponent).toFixed(used.exponent) + " " + used.currency + " used" : "off"
                }
            }

            Txt {
                readonly property int min: Math.floor((clock.date - claude.updated) / 60000)
                readonly property int secs: Math.max(0, Math.ceil((claude.tried - clock.date + poll.interval) / 1000))
                text: (min < 1 ? "updated just now" : "updated " + min + " min ago") + (claude.error ? " · " + claude.error + ", retry in " + Math.floor(secs / 60) + ":" + String(secs % 60).padStart(2, "0") : "")
                color: claude.error ? Ui.yellow : Ui.gray
            }
        }
    }
}
