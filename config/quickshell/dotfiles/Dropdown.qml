import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// A full-screen layer, not a PopupWindow: under mango, popups stop redrawing after their first frame
PanelWindow {
    id: dropdown
    required property Item target
    default property alias content: column.data
    property int padding: 12

    visible: false
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    onVisibleChanged: if (visible) card.x = Math.max(Ui.gap, Math.min(target.mapToItem(null, 0, 0).x, screen.width - card.width - Ui.gap))

    Connections {
        target: Mango
        function onActiveTagsChanged() {
            dropdown.visible = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: dropdown.visible = false
    }

    Rectangle {
        id: card
        y: Ui.barHeight + Ui.gap
        width: column.implicitWidth + 2 * dropdown.padding
        height: column.implicitHeight + 2 * dropdown.padding
        radius: Ui.radius
        color: Ui.bg0
        border.width: 1
        border.color: Ui.bg1

        // Keeps clicks on the panel away from the closing area
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: dropdown.padding
            spacing: 0
            focus: true
            Keys.onEscapePressed: dropdown.visible = false
        }
    }
}
