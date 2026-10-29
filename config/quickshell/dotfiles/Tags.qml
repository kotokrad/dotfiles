import QtQuick
import QtQuick.Layouts

RowLayout {
    id: tags
    required property string monitorName
    readonly property var monitor: Mango.monitor(monitorName)

    spacing: 1.5

    // A fixed model: mango sends a fresh tag list on every event, which would rebuild the
    // items (and skip their animations) if it were the model
    Repeater {
        model: 9

        Item {
            id: tag
            required property int index
            readonly property int n: index + 1
            readonly property var info: tags.monitor?.tags[index] ?? null
            readonly property bool active: tags.monitor?.active_tags.includes(n) ?? false
            readonly property bool urgent: info?.is_urgent ?? false

            visible: active || urgent || (info?.client_count ?? 0) > 0
            implicitWidth: (n === 6 ? dot.width : label.implicitWidth) + (active ? 14 : 8)
            implicitHeight: Ui.height

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutBack
                }
            }

            Rectangle {
                y: (parent.height - height) / 2
                width: parent.width
                height: 18
                radius: height / 2
                color: tag.active ? Ui.bg : mouse.containsMouse ? Qt.rgba(0, 0, 0, 0.35) : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            // Centers the glyph's ink box: anchors.centerIn rounds to whole pixels and centers the
            // line box, which is visibly off at 1.5x. Measured at 100x size, where the box isn't rounded.
            TextMetrics {
                id: ink
                font.family: label.font.family
                font.bold: true
                font.pixelSize: label.font.pixelSize * 100
                text: label.text
            }

            // Tag 6 is a drawn dot: Qt reports a glyph above the
            // baseline as reaching down to it, which would center a dot glyph too high.
            Rectangle {
                id: dot
                visible: tag.n === 6
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 6
                height: 6
                radius: 3
                color: label.color
            }

            Txt {
                id: label
                x: (tag.width - ink.tightBoundingRect.width / 100) / 2 - ink.tightBoundingRect.x / 100
                y: tag.height / 2 - baselineOffset - (ink.tightBoundingRect.y + ink.tightBoundingRect.height / 2) / 100
                text: ["", "\u{f269}", "\u{f120}", "\u{f121}", "\u{f07b}", "\u{f2c6}", ""][tag.n] ?? tag.n
                font.pixelSize: tag.n <= 5 ? Ui.fontSize + 1 : Ui.fontSize
                color: tag.urgent ? Ui.red : Ui.fg
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                anchors.topMargin: -Ui.topGap
                hoverEnabled: true
                onClicked: {
                    Mango.dispatch("focusmon," + tags.monitorName);
                    Mango.dispatch("view," + tag.n);
                }
            }
        }
    }

    WheelHandler {
        onWheel: e => Mango.dispatch(e.angleDelta.y > 0 ? "viewtoleft_have_client" : "viewtoright_have_client")
    }
}
