import QtQuick
import QtQuick.Layouts

Rectangle {
    id: entry
    property string icon: ""
    property string text: ""
    property string trailing: ""
    property bool current: false
    property bool iconSpace: false // keep the icon slot when there's no icon, so rows line up
    readonly property bool hovered: mouse.containsMouse
    signal clicked

    Layout.fillWidth: true
    implicitHeight: 26
    radius: Ui.radius
    color: mouse.containsMouse ? Ui.bg2 : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Txt {
            Layout.preferredWidth: 14
            visible: entry.icon !== "" || entry.iconSpace
            horizontalAlignment: Text.AlignHCenter
            text: entry.icon
            font.pixelSize: Ui.menuFontSize
            color: entry.current ? Ui.accent : Ui.fg
        }
        Txt {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: entry.text
            font.pixelSize: Ui.menuFontSize
            font.bold: entry.current
        }
        Txt {
            visible: entry.trailing !== ""
            text: entry.trailing
            font.pixelSize: Ui.menuFontSize
            font.bold: false
            color: Ui.gray
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: entry.clicked()
    }
}
