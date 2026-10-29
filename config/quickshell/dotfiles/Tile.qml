import QtQuick
import QtQuick.Layouts

Rectangle {
    id: tile
    property string icon
    property string label
    property string status
    property bool active
    property bool expandable: false
    property bool expanded: false
    signal toggled
    signal expand

    readonly property color fg: active ? Ui.bg : Ui.fg
    readonly property color hover: active ? Qt.lighter(Ui.accent, 1.2) : Ui.bg2

    Layout.fillWidth: true
    implicitHeight: 40
    radius: Ui.radius
    color: active ? Ui.accent : Ui.bg1

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: tile.expandable ? chevron.left : parent.right
        radius: Ui.radius
        color: body.containsMouse ? tile.hover : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 6
            spacing: 10

            Txt {
                text: tile.icon
                font.pixelSize: 15
                color: tile.fg
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Txt {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: tile.label
                    font.pixelSize: Ui.menuFontSize
                    color: tile.fg
                }
                Txt {
                    Layout.fillWidth: true
                    visible: tile.status !== ""
                    elide: Text.ElideRight
                    text: tile.status
                    font.pixelSize: Ui.fontSize
                    font.bold: false
                    color: tile.fg
                    opacity: 0.8
                }
            }
        }

        MouseArea {
            id: body
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tile.toggled()
        }
    }

    Rectangle {
        id: chevron
        visible: tile.expandable
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 30
        radius: Ui.radius
        color: arrow.containsMouse ? tile.hover : "transparent"

        Txt {
            anchors.centerIn: parent
            text: tile.expanded ? "\u{f078}" : "\u{f054}"
            color: tile.fg
        }

        MouseArea {
            id: arrow
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tile.expand()
        }
    }
}
