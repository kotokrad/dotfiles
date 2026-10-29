import QtQuick
import Quickshell.Services.Pipewire

Island {
    id: privacy
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream)
    readonly property bool mic: streams.some(n => n.type === PwNodeType.AudioInStream)
    readonly property bool video: streams.some(n => n.type & PwNodeType.Video)

    visible: mic || video
    color: Ui.red

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
