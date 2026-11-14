import QtQuick
import QtQuick.Layouts

RowLayout {
    id: label
    required property var profile
    property bool current: false
    property string placeholder: ""

    spacing: 8

    Txt {
        Layout.fillWidth: true
        text: label.profile?.label ?? label.placeholder
        color: label.profile ? Ui.fg : Ui.gray
        font.pixelSize: Ui.menuFontSize
        font.bold: label.current
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    Txt {
        visible: !!label.profile?.recommended || !!label.profile?.headset
        text: label.profile?.recommended ? "\u{f005}" : "\u{ee59}"
        color: label.profile?.recommended ? Ui.accent : Ui.gray
        font.pixelSize: Ui.menuFontSize
        font.bold: false
    }
}
