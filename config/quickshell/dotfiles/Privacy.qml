import QtQuick
import Quickshell.Services.Pipewire

Island {
    id: privacy
    readonly property var allStreams: Pipewire.nodes.values.filter(n => n.isStream)
    // Filter-chain halves (asahi-audio's mic DSP) are permanent capture streams, not apps
    readonly property var streams: allStreams.filter(n => !n.properties["node.link-group"])
    readonly property bool mic: streams.some(n => n.type === PwNodeType.AudioInStream)
    readonly property bool video: streams.some(n => n.type & PwNodeType.Video)

    visible: mic || video
    color: Ui.red

    // properties are only populated on bound nodes
    PwObjectTracker {
        objects: privacy.allStreams
    }

    Txt {
        visible: privacy.mic
        text: "\u{f130}"
        color: Ui.bg
    }
    Txt {
        visible: privacy.video
        text: "\u{f108}"
        color: Ui.bg
    }
}
