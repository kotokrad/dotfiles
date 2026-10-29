import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dropdown {
    id: popup
    property date shown: new Date()

    function step(n) {
        shown = new Date(shown.getFullYear(), shown.getMonth() + n, 1);
    }

    onVisibleChanged: if (visible) shown = new Date()

    ColumnLayout {
        spacing: 6

        WheelHandler {
            onWheel: e => popup.step(e.angleDelta.y > 0 ? -1 : 1)
        }

        RowLayout {
            Layout.fillWidth: true

            IconButton {
                icon: "\u{f053}"
                color: hovered ? Ui.bg2 : "transparent"
                onClicked: popup.step(-1)
            }

            Txt {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: popup.shown.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                font.pixelSize: Ui.menuFontSize
            }

            IconButton {
                icon: "\u{f054}"
                color: hovered ? Ui.bg2 : "transparent"
                onClicked: popup.step(1)
            }
        }

        DayOfWeekRow {
            locale: grid.locale
            padding: 0
            spacing: grid.spacing
            delegate: Txt {
                required property string shortName
                width: 28
                horizontalAlignment: Text.AlignHCenter
                text: shortName
                color: Ui.gray
            }
        }

        MonthGrid {
            id: grid
            month: popup.shown.getMonth()
            year: popup.shown.getFullYear()
            padding: 0
            spacing: 2

            delegate: Rectangle {
                id: day
                required property var model
                implicitWidth: 28
                implicitHeight: 24
                radius: Ui.radius
                color: model.today ? Ui.accent : "transparent"

                Txt {
                    anchors.centerIn: parent
                    text: day.model.day
                    font.pixelSize: Ui.menuFontSize
                    font.bold: day.model.today
                    color: day.model.today ? Ui.bg : day.model.month === grid.month ? Ui.fg : Ui.bg3
                }
            }
        }
    }
}
