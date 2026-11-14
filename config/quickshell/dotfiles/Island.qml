import QtQuick
import QtQuick.Layouts

Rectangle {
    id: island
    default property alias content: row.data
    property alias spacing: row.spacing
    property bool hoverable: false
    readonly property bool hovered: mouse.containsMouse
    readonly property bool panelOpen: Ui.dropdowns.some(panel => panel.visible && panel.target === island)
    property real wheelDelta: 0
    signal clicked
    signal scrolled(int steps)

    implicitWidth: row.implicitWidth + 16
    implicitHeight: Ui.height
    radius: Ui.radius
    color: hoverable && hovered ? Qt.tint(Ui.bg0, Qt.alpha(Ui.bg2, 0.8))
        : panelOpen ? Ui.bg1 : Ui.bg0

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
