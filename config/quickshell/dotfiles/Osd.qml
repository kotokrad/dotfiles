import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PanelWindow {
    id: osd
    property string icon
    property real value
    property bool muted
    property string kb: ""
    property bool kbToast: false

    function show(i, v, m) {
        icon = i;
        value = v;
        muted = m;
        kbToast = false;
        visible = true;
        hide.restart();
    }

    function changeVolume(delta) {
        const a = Pipewire.defaultAudioSink?.audio;
        if (!a)
            return;
        // Pipewire applies changes asynchronously, so show the target values
        const v = Math.max(0, Math.min(1, a.volume + delta));
        const m = delta === 0 ? !a.muted : a.muted;
        a.volume = v;
        a.muted = m;
        show(m ? "\u{f0581}" : "\u{f057e}", v, m);
    }

    function changeBrightness(step) {
        brightness.command = ["brightnessctl", "-m", "set", step];
        brightness.running = true;
    }

    visible: false
    screen: Mango.focusedScreen
    anchors.bottom: true
    margins.bottom: 80
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: 220
    implicitHeight: 34
    color: "transparent"
    mask: Region {}

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    IpcHandler {
        target: "volume"
        function up(): void {
            osd.changeVolume(0.05);
        }
        function down(): void {
            osd.changeVolume(-0.05);
        }
        function mute(): void {
            osd.changeVolume(0);
        }
    }

    IpcHandler {
        target: "brightness"
        function up(): void {
            osd.changeBrightness("5%+");
        }
        function down(): void {
            osd.changeBrightness("5%-");
        }
    }

    Connections {
        target: Mango
        function onMonitorsChanged() {
            const k = Mango.monitors[0]?.keyboardlayout ?? "";
            if (k === osd.kb)
                return;
            const first = osd.kb === ""; // the first snapshot isn't a switch
            osd.kb = k;
            if (first)
                return;
            osd.icon = "\u{f030c}";
            osd.muted = false;
            osd.kbToast = true;
            osd.visible = true;
            hide.restart();
        }
    }

    // brightnessctl -m prints "device,class,current,percent%,max"
    Process {
        id: brightness
        stdout: StdioCollector {
            onStreamFinished: osd.show("\u{f00e0}", parseInt(text.split(",")[3]) / 100, false)
        }
    }

    Timer {
        id: hide
        interval: osd.kbToast ? 800 : 1500
        onTriggered: osd.visible = false
    }

    Rectangle {
        anchors.fill: parent
        radius: Ui.radius
        color: Ui.bg0
        border.width: 1
        border.color: Ui.bg1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Txt {
                text: osd.icon
                font.pixelSize: 14
                color: osd.muted ? Ui.gray : Ui.fg
            }
            Repeater {
                model: osd.kbToast ? Object.keys(Ui.kbLayouts) : []
                Rectangle {
                    required property string modelData
                    readonly property bool current: modelData === osd.kb
                    Layout.fillWidth: true
                    implicitHeight: 22
                    radius: Ui.radius
                    color: current ? Ui.accent : "transparent"
                    Txt {
                        anchors.centerIn: parent
                        text: Ui.kbLayouts[parent.modelData]
                        font.pixelSize: Ui.menuFontSize
                        color: parent.current ? Ui.bg : Ui.gray
                    }
                }
            }
            Rectangle {
                visible: !osd.kbToast
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 2
                color: Ui.bg2
                Rectangle {
                    width: osd.value * parent.width
                    height: parent.height
                    radius: 2
                    color: osd.muted ? Ui.gray : Ui.accent
                }
            }
            Txt {
                visible: !osd.kbToast
                Layout.preferredWidth: 30
                horizontalAlignment: Text.AlignRight
                text: Math.round(osd.value * 100) + "%"
                font.pixelSize: Ui.menuFontSize
            }
        }
    }
}
