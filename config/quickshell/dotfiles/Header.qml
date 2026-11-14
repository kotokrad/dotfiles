import QtQuick
import QtQuick.Layouts

// Dropdown section title with an on/off switch (network and VPN menus)
RowLayout {
    id: header
    property string title
    property bool on
    signal toggled

    Layout.fillWidth: true

    Txt {
        Layout.fillWidth: true
        text: header.title
        font.pixelSize: Ui.menuFontSize
    }

    Rectangle {
        implicitWidth: 30
        implicitHeight: 16
        radius: height / 2
        color: header.on ? Ui.accent : Ui.bg2

        Rectangle {
            x: header.on ? parent.width - width - 2 : 2
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

        MouseArea {
            anchors.fill: parent
            onClicked: header.toggled()
        }
    }
}
