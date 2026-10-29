import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: switcher
    property int index: 0

    function pick(i) {
        Vpn.set(Vpn.options[i][0]);
        Vpn.switcherOpen = false;
    }

    visible: Vpn.switcherOpen
    onVisibleChanged: if (visible) index = Math.max(0, Vpn.options.findIndex(o => o[0] === Vpn.active))
    screen: Mango.focusedScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    IpcHandler {
        target: "vpn"
        function toggle(): void {
            Vpn.switcherOpen = !Vpn.switcherOpen;
        }
    }

    Connections {
        target: Mango
        function onActiveTagsChanged() {
            Vpn.switcherOpen = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Vpn.switcherOpen = false
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
                    Vpn.switcherOpen = false;
                else if (e.key === Qt.Key_Up || e.key === Qt.Key_K)
                    switcher.index = (switcher.index + 2) % 3;
                else if (e.key === Qt.Key_Down || e.key === Qt.Key_J || e.key === Qt.Key_Tab)
                    switcher.index = (switcher.index + 1) % 3;
                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
                    switcher.pick(switcher.index);
                else if (e.key >= Qt.Key_1 && e.key <= Qt.Key_3)
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
                    current: modelData[0] !== "" && Vpn.active === modelData[0]
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
