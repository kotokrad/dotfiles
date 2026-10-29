import QtQuick
import QtQuick.Layouts

Rectangle {
    id: island
    default property alias content: row.data
    property alias spacing: row.spacing
    property bool hoverable: false
    readonly property bool hovered: mouse.containsMouse
    property real wheelDelta: 0
    signal clicked
    signal scrolled(int steps)

    implicitWidth: row.implicitWidth + 16
    implicitHeight: Ui.height
    radius: Ui.radius
    color: hoverable && mouse.containsMouse ? Ui.bg2 : Ui.bg0

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.topMargin: -Ui.topGap
        hoverEnabled: true
        onClicked: island.clicked()
        onWheel: w => {
            // Wheels report 120 per notch; touchpads report pixels, in many small events
            island.wheelDelta += w.pixelDelta.y !== 0 ? w.pixelDelta.y / 2 : w.angleDelta.y / 120;
            const steps = Math.trunc(island.wheelDelta);
            island.wheelDelta -= steps;
            if (steps !== 0)
                island.scrolled(steps);
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }
}
