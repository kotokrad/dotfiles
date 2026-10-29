import QtQuick
import Quickshell

PopupWindow {
    required property Item target
    property alias text: label.text

    anchor.item: target
    anchor.rect.y: target.height + Ui.gap
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 10
    color: "transparent"
    visible: target.hovered && text !== ""

    Rectangle {
        anchors.fill: parent
        radius: Ui.radius
        color: Ui.bg0
        border.width: 1
        border.color: Ui.bg1

        Txt {
            id: label
            anchors.centerIn: parent
        }
    }
}
