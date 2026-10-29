import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Island {
    id: sensors
    required property QsWindow bar
    property int cpu: 0
    property int ram: 0
    property int temp: 0
    property string disk: ""
    property var lastCpu: [0, 0]
    property var procs: []
    property string sortBy: "%CPU"

    hoverable: true
    spacing: 8
    onClicked: procMenu.visible = !procMenu.visible

    Txt {
        visible: sensors.disk !== ""
        text: "\u{f0a0} " + sensors.disk
    }
    Hairline {
        visible: sensors.disk !== ""
    }
    Txt { text: "\u{efc5} " + sensors.ram + "%" }
    Hairline {}
    Txt { text: "\u{f4bc} " + sensors.cpu + "%" }
    Hairline {}
    Rectangle {
        Layout.leftMargin: -8
        Layout.rightMargin: -8
        implicitWidth: tempText.implicitWidth + 16
        implicitHeight: Ui.height
        topRightRadius: Ui.radius
        bottomRightRadius: Ui.radius
        color: sensors.temp >= 90 ? Ui.red : sensors.temp >= 80 ? Ui.yellow : "transparent"
        Txt {
            id: tempText
            anchors.centerIn: parent
            text: "\u{f2c9} " + sensors.temp + "°C"
            color: sensors.temp >= 80 ? Ui.bg : Ui.fg
        }
    }

    // top's first frame averages over each process's lifetime; the second covers the last second
    Process {
        id: top
        command: ["top", "-b", "-n", "2", "-d", "1", "-w", "512", "-o", sensors.sortBy]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const h = lines.map(l => /^\s*PID\s/.test(l)).lastIndexOf(true);
                const cols = lines[h].trim().split(/\s+/);
                const [cpu, mem, cmd] = ["%CPU", "%MEM", "COMMAND"].map(c => cols.indexOf(c));
                sensors.procs = lines.slice(h + 1).map(l => l.trim().split(/\s+/))
                    .filter(f => f[cmd] !== "top").slice(0, 8)
                    .map(f => ({ name: f.slice(cmd).join(" "), cpu: f[cpu], mem: f[mem] }));
            }
        }
    }

    Timer {
        interval: 2000
        running: procMenu.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: top.running = true
    }

    Dropdown {
        id: procMenu
        target: sensors
        screen: sensors.bar.screen

        ColumnLayout {
            Layout.preferredWidth: 240
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Txt {
                    Layout.fillWidth: true
                    text: "Process"
                    color: Ui.gray
                }
                Repeater {
                    model: [["%CPU", "CPU"], ["%MEM", "RAM"]]
                    Txt {
                        required property var modelData
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                        text: modelData[1]
                        color: sensors.sortBy === modelData[0] || sortMouse.containsMouse ? Ui.fg : Ui.gray
                        MouseArea {
                            id: sortMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                sensors.sortBy = parent.modelData[0];
                                top.running = true;
                            }
                        }
                    }
                }
            }

            Repeater {
                model: sensors.procs
                RowLayout {
                    id: proc
                    Layout.fillWidth: true
                    required property var modelData
                    spacing: 12
                    Txt {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: proc.modelData.name
                        font.pixelSize: Ui.menuFontSize
                        font.bold: false
                    }
                    Txt {
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                        text: proc.modelData.cpu
                        font.pixelSize: Ui.menuFontSize
                        font.bold: false
                    }
                    Txt {
                        Layout.preferredWidth: 36
                        horizontalAlignment: Text.AlignRight
                        text: proc.modelData.mem
                        font.pixelSize: Ui.menuFontSize
                        font.bold: false
                    }
                }
            }
        }
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + f[4];
            const total = f.reduce((a, b) => a + b, 0);
            const [lastIdle, lastTotal] = sensors.lastCpu;
            if (total > lastTotal)
                sensors.cpu = Math.round(100 * (1 - (idle - lastIdle) / (total - lastTotal)));
            sensors.lastCpu = [idle, total];
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const kb = key => Number(text().match(new RegExp(key + ":\\s+(\\d+)"))[1]);
            sensors.ram = Math.round(100 * (1 - kb("MemAvailable") / kb("MemTotal")));
        }
    }

    // k10temp's hwmon index changes between boots
    FileView {
        id: tempFile
        onLoaded: sensors.temp = Math.round(Number(text()) / 1000)
    }
    Process {
        running: true
        command: ["sh", "-c", "grep -l k10temp /sys/class/hwmon/*/name"]
        stdout: StdioCollector {
            onStreamFinished: tempFile.path = text.trim().replace(/name$/, "temp1_input")
        }
    }

    Process {
        id: df
        command: ["sh", "-c", "df -B1 --output=avail / | tail -1 | numfmt --to=iec-i --format=%.2f"]
        stdout: StdioCollector {
            onStreamFinished: sensors.disk = text.trim() + "B"
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            if (tempFile.path !== "")
                tempFile.reload();
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: df.running = true
    }
}
