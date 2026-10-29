import QtQuick

Rectangle {
    id: button
    property alias icon: glyph.text
    property alias glyphSize: glyph.font.pixelSize
    property alias glyphColor: glyph.color
    readonly property bool hovered: mouse.containsMouse
    signal clicked

    implicitWidth: 24
    implicitHeight: 24
    radius: Ui.radius
    color: hovered ? Ui.bg2 : Ui.bg1

    Txt {
        id: glyph
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }
}
