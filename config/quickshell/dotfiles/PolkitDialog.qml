import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland

PanelWindow {
    id: dialog
    readonly property var flow: agent.flow
    property string password: ""
    property int tried: 0
    property bool wrong: false

    function edit(text) {
        password = text;
        tried = 0;
        wrong = false;
    }

    function submit() {
        if (!flow.isResponseRequired || password === "")
            return;
        tried = password.length;
        flow.submit(password);
        password = "";
    }

    visible: agent.isActive
    screen: Mango.focusedScreen
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    implicitWidth: 270
    implicitHeight: column.implicitHeight + 24
    color: "transparent"

    PolkitAgent {
        id: agent
        onFlowChanged: dialog.edit("")
    }

    Connections {
        target: dialog.flow
        function onAuthenticationFailed() {
            dialog.wrong = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Ui.radius
        color: Ui.bg0
        border.width: 1
        border.color: Ui.bg1
        focus: true
        Keys.onPressed: event => {
            event.accepted = true;
            const ctrl = event.modifiers & Qt.ControlModifier;
            if (event.key === Qt.Key_Escape)
                dialog.flow.cancelAuthenticationRequest();
            else if (dialog.tried > 0 && !dialog.wrong)
                return;
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                dialog.submit();
            else if (ctrl && (event.key === Qt.Key_U || event.key === Qt.Key_Backspace))
                dialog.edit("");
            else if (event.key === Qt.Key_Backspace)
                dialog.edit(dialog.password.slice(0, -1));
            else if (!ctrl && event.text !== "" && event.text.charCodeAt(0) >= 0x20 && event.text !== "\x7f")
                dialog.edit(dialog.password + event.text);
        }

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            RowLayout {
                spacing: 10

                Txt {
                    text: "\u{f033e}"
                    font.pixelSize: 22
                    font.bold: false
                    color: Ui.accent
                }
                Txt {
                    Layout.fillWidth: true
                    text: dialog.flow?.message ?? ""
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    font.pixelSize: Ui.menuFontSize
                    font.bold: false
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 26
                radius: Ui.radius
                color: Ui.bg1
                border.width: 1
                border.color: dialog.wrong ? Ui.red : Ui.accent

                Txt {
                    readonly property int dots: dialog.tried || dialog.password.length
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    text: dots ? "•".repeat(dots) : "Password"
                    elide: Text.ElideLeft
                    font.pixelSize: dots ? 14 : Ui.menuFontSize
                    font.bold: false
                    color: dialog.wrong ? Ui.red : dialog.password ? Ui.fg : Ui.gray
                }
            }
        }
    }
}
