import QtQuick
import QtQuick.Layouts

// Dropdown section title with an on/off switch (network and VPN menus); the whole row toggles
Item {
    id: header
    property string title
    property bool on
    property bool pending
    signal toggled

    Layout.fillWidth: true
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // Entry's size and hover, reaching into the dropdown's padding
    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.leftMargin: -8
        anchors.rightMargin: -8
        anchors.topMargin: -5
        anchors.bottomMargin: -5
        radius: Ui.radius
        color: mouse.containsMouse ? Ui.bg2 : "transparent"
    }

    MouseArea {
        id: mouse
        anchors.fill: hoverBg
        enabled: !header.pending
        hoverEnabled: true
        onClicked: header.toggled()
    }

    RowLayout {
        id: row
        anchors.fill: parent

        Txt {
            Layout.fillWidth: true
            text: header.title
            font.pixelSize: Ui.menuFontSize
        }

        Rectangle {
            implicitWidth: 30
            implicitHeight: 16
            radius: height / 2
            color: header.on ? Ui.accent : mouse.containsMouse ? Ui.bg3 : Ui.bg2

            Rectangle {
                x: header.pending ? (parent.width - width) / 2 : header.on ? parent.width - width - 2 : 2
                y: 2
                width: 12
                height: 12
                radius: 6
                color: Ui.fg
                Behavior on x {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }
        }
    }
}
