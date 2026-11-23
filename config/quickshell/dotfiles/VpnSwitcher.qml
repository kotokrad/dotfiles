import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: switcher
    property int index: 0

    function pick(i) {
        Vpn.toggle(Vpn.options[i][0]);
        visible = false;
    }

    visible: false
    onVisibleChanged: {
        if (visible) {
            Ui.closeDropdowns();
            index = 0;
        }
    }
    screen: Mango.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    IpcHandler {
        target: "vpn"
        function toggle(): void {
            switcher.visible = !switcher.visible;
        }
    }

    Connections {
        target: Mango
        function onActiveTagsChanged() {
            switcher.visible = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: switcher.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: 240
        height: column.implicitHeight + 20
        radius: Ui.radius
        color: Ui.bg0
        border.width: 1
        border.color: Ui.bg1

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2
            focus: true
            Keys.onPressed: e => {
                if (e.key === Qt.Key_Escape)
                    switcher.visible = false;
                else if (e.key === Qt.Key_Up || e.key === Qt.Key_K)
                    switcher.index = (switcher.index + Vpn.options.length - 1) % Vpn.options.length;
                else if (e.key === Qt.Key_Down || e.key === Qt.Key_J || e.key === Qt.Key_Tab)
                    switcher.index = (switcher.index + 1) % Vpn.options.length;
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
                    switcher.pick(switcher.index);
                else if (e.key >= Qt.Key_1 && e.key < Qt.Key_1 + Vpn.options.length)
                    switcher.pick(e.key - Qt.Key_1);
            }

            Txt {
                Layout.leftMargin: 8
                Layout.bottomMargin: 4
                text: "\u{f0582}  VPN"
                font.pixelSize: Ui.menuFontSize
                color: Ui.gray
            }

            Repeater {
                model: Vpn.options
                Entry {
                    required property var modelData
                    required property int index
                    current: Vpn[modelData[0]]
                    iconSpace: true
                    icon: current ? "\u{f00c}" : ""
                    text: modelData[1]
                    trailing: index + 1
                    color: switcher.index === index ? Ui.bg2 : "transparent"
                    onHoveredChanged: if (hovered) switcher.index = index
                    onClicked: switcher.pick(index)
                }
            }
        }
    }
}
