import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

ColumnLayout {
    id: section
    required property bool sink

    readonly property var node: sink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    readonly property var devices: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.isSink === sink)
    readonly property bool muted: node?.audio?.muted ?? true

    Layout.fillWidth: true
    spacing: 4

    Txt {
        Layout.leftMargin: 2
        text: section.sink ? "Speaker" : "Microphone"
        color: Ui.gray
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        IconButton {
            implicitWidth: 28
            implicitHeight: 28
            icon: section.sink ? (section.muted ? "\u{f0581}" : "\u{f057e}") : (section.muted ? "\u{f036d}" : "\u{f036c}")
            glyphSize: 13
            glyphColor: section.muted ? Ui.gray : Ui.fg
            onClicked: section.node.audio.muted = !section.muted
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 1
            value: section.node?.audio?.volume ?? 0
            onMoved: section.node.audio.volume = value

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: Ui.bg2
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: section.muted ? Ui.gray : Ui.accent
                }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 14
                implicitHeight: 14
                radius: 7
                color: Ui.fg
            }
        }

        Txt {
            Layout.preferredWidth: 32
            horizontalAlignment: Text.AlignRight
            text: Math.round(slider.value * 100) + "%"
            font.pixelSize: Ui.menuFontSize
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: section.devices
            Entry {
                required property var modelData
                current: modelData === section.node
                iconSpace: true
                icon: current ? "\u{f00c}" : ""
                text: modelData.description || modelData.nickname || modelData.name
                onClicked: {
                    if (section.sink)
                        Pipewire.preferredDefaultAudioSink = modelData;
                    else
                        Pipewire.preferredDefaultAudioSource = modelData;
                }
            }
        }
        Entry {
            iconSpace: true
            text: "More…"
            onClicked: Quickshell.execDetached(["pavucontrol", "-t", section.sink ? "3" : "4"])
        }
    }
}
