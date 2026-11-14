import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

ColumnLayout {
    id: section
    required property bool sink
    required property AudioProfiles profiles

    readonly property var node: sink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    readonly property var devices: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.isSink === sink)
    readonly property var deviceCandidate: profiles.deviceFor(node)
    property bool muted: true
    property real volume: 0
    property var device: null
    property var codecs: []
    property bool initialized: false
    property bool bluetooth: false
    property string selectedNodeName: ""
    readonly property int profileIndex: device?.current ?? -1

    Layout.fillWidth: true
    spacing: 6

    function refresh() {
        if (!initialized || profiles.changing)
            return;
        device = deviceCandidate;
        muted = node?.audio?.muted ?? true;
        volume = node?.audio?.volume ?? 0;
        bluetooth = node?.properties?.["device.api"] === "bluez5" || (node?.name?.startsWith("bluez_") ?? false);
        selectedNodeName = node?.name ?? "";

        // Keep delegates for surviving node names, even when their PipeWire objects change.
        for (let i = deviceModel.count - 1; i >= 0; --i) {
            if (!devices.some(n => n.name === deviceModel.get(i).nodeName))
                deviceModel.remove(i);
        }
        for (const n of devices) {
            let row = -1;
            for (let i = 0; i < deviceModel.count; ++i) {
                if (deviceModel.get(i).nodeName === n.name) {
                    row = i;
                    break;
                }
            }
            const label = n.description || n.nickname || n.name;
            if (row === -1)
                deviceModel.append({ nodeName: n.name, label, audioNode: n });
            else {
                if (deviceModel.get(row).audioNode !== n)
                    deviceModel.setProperty(row, "audioNode", n);
                if (deviceModel.get(row).label !== label)
                    deviceModel.setProperty(row, "label", label);
            }
        }

        const next = profiles.choices(device, sink);
        if (JSON.stringify(next) !== JSON.stringify(codecs))
            codecs = next;
    }

    Component.onCompleted: {
        initialized = true;
        refresh();
    }
    onNodeChanged: refresh()
    onDevicesChanged: refresh()
    onDeviceCandidateChanged: refresh()

    ListModel {
        id: deviceModel
        dynamicRoles: true
    }

    Connections {
        target: section.profiles
        function onChangingChanged() { section.refresh(); }
    }

    Connections {
        target: section.node?.audio ?? null
        function onMutedChanged() { section.refresh(); }
        function onVolumesChanged() { section.refresh(); }
    }

    Txt {
        Layout.leftMargin: 2
        text: section.sink ? "Output" : "Input"
        color: Ui.gray
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        IconButton {
            implicitWidth: 28
            implicitHeight: 28
            enabled: !section.profiles.changing && !!section.node?.audio
            icon: section.sink ? (section.bluetooth ? "\u{f025}" : section.muted ? "\u{f0581}" : "\u{f057e}") : (section.muted ? "\u{f036d}" : "\u{f036c}")
            glyphSize: 13
            glyphColor: section.muted ? Ui.gray : Ui.fg
            onClicked: section.node.audio.muted = !section.muted
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 1
            enabled: !section.profiles.changing && !!section.node?.audio
            value: section.volume
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

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: deviceList.implicitHeight + 12
        radius: Ui.radius
        color: Ui.bg
        border.width: 1
        border.color: Ui.bg1

        ColumnLayout {
            id: deviceList
            anchors.fill: parent
            anchors.margins: 6
            spacing: 0

            Repeater {
                model: deviceModel
                Entry {
                    required property var audioNode
                    required property string label
                    required property string nodeName
                    enabled: !section.profiles.changing && !!audioNode
                    current: nodeName === section.selectedNodeName
                    iconSpace: true
                    icon: current ? "\u{f00c}" : ""
                    text: label
                    onClicked: {
                        if (section.sink)
                            Pipewire.preferredDefaultAudioSink = audioNode;
                        else
                            Pipewire.preferredDefaultAudioSource = audioNode;
                    }
                }
            }

            Txt {
                Layout.margins: 8
                visible: deviceModel.count === 0
                text: section.sink ? "No output devices" : "No input devices"
                color: Ui.gray
                font.bold: false
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 6
                Layout.topMargin: 8
                visible: section.codecs.length > 0
                spacing: 8

                Txt {
                    text: "Profile"
                    color: Ui.gray
                    font.bold: false
                }

                ComboBox {
                    id: codec
                    Layout.fillWidth: true
                    implicitHeight: 28
                    leftPadding: 8
                    rightPadding: 26
                    model: section.codecs
                    textRole: "label"
                    valueRole: "index"
                    currentValue: section.profileIndex
                    displayText: currentIndex >= 0 ? currentText
                        : !section.sink && section.profileIndex >= 0 ? "Microphone unavailable" : "Select a profile"
                    enabled: !section.profiles.changing
                    onActivated: section.profiles.select(section.device, currentValue, section.sink)

                    contentItem: AudioCodecLabel {
                        profile: section.codecs[codec.currentIndex] ?? null
                        placeholder: codec.displayText
                        opacity: codec.enabled ? 1 : 0.5
                    }

                    indicator: Txt {
                        x: codec.width - width - 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u{f078}"
                        color: Ui.gray
                    }

                    background: Rectangle {
                        radius: Ui.radius
                        color: codec.hovered ? Ui.bg2 : Ui.bg1
                        border.width: codec.activeFocus ? 1 : 0
                        border.color: Ui.accent
                    }

                    delegate: ItemDelegate {
                        id: choice
                        required property var modelData
                        required property int index
                        width: codec.width - 8
                        implicitHeight: 28
                        highlighted: codec.highlightedIndex === index

                        contentItem: AudioCodecLabel {
                            profile: choice.modelData
                            current: choice.modelData.index === section.profileIndex
                        }

                        background: Rectangle {
                            radius: Ui.radius
                            color: parent.highlighted ? Ui.bg2 : "transparent"
                        }
                    }

                    popup: Popup {
                        y: codec.height + 4
                        width: codec.width
                        padding: 4
                        popupType: Popup.Item
                        implicitHeight: Math.min(contentItem.implicitHeight + 8, 200)

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: codec.popup.visible ? codec.delegateModel : null
                            currentIndex: codec.highlightedIndex
                            boundsBehavior: Flickable.StopAtBounds
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            radius: Ui.radius
                            color: Ui.bg0
                            border.width: 1
                            border.color: Ui.bg2
                        }
                    }
                }
            }
        }
    }
}
