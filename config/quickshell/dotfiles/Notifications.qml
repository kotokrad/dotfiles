import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import Quickshell.Wayland

PanelWindow {
    visible: server.trackedNotifications.values.some(n => !Ui.quiet || n.urgency === NotificationUrgency.Critical)
    screen: Mango.focusedScreen
    anchors { top: true; right: true }
    margins { top: Ui.gap; right: Ui.gap }
    WlrLayershell.layer: WlrLayer.Overlay
    implicitWidth: 340
    implicitHeight: column.implicitHeight
    color: "transparent"

    NotificationServer {
        id: server
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: true
        onNotification: n => n.tracked = true
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: Ui.gap

        Repeater {
            model: server.trackedNotifications

            Rectangle {
                id: card
                required property Notification modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                // Apps send a "default" action for clicks on the body (e.g. open the chat)
                readonly property var defaultAction: modelData.actions.find(a => a.identifier === "default") ?? null
                readonly property var buttons: modelData.actions.filter(a => a.identifier !== "default")
                readonly property string icon: modelData.image || (modelData.appIcon.startsWith("/") ? "file://" + modelData.appIcon : modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, true) : "")

                visible: !Ui.quiet || critical
                Layout.fillWidth: true
                implicitHeight: row.implicitHeight + 20
                radius: Ui.radius
                color: Ui.bg0
                border.width: 1
                border.color: critical ? Ui.red : Ui.bg1

                // Critical ones stay; hovering pauses the timeout. Apps may ask for less than 5s,
                // not more: Chromium-based browsers ask for 25s.
                Timer {
                    running: !card.critical && !mouse.containsMouse && !Ui.quiet
                    interval: card.modelData.expireTimeout > 0 ? Math.min(card.modelData.expireTimeout, 5000) : 5000
                    onTriggered: card.modelData.expire()
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: m => m.button === Qt.LeftButton && card.defaultAction ? card.defaultAction.invoke() : card.modelData.dismiss()
                }

                RowLayout {
                    id: row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 10

                    IconImage {
                        Layout.alignment: Qt.AlignTop
                        visible: card.icon !== ""
                        source: card.icon
                        implicitSize: 36
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Txt {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: card.modelData.summary || card.modelData.appName
                                font.pixelSize: Ui.menuFontSize
                            }
                            IconButton {
                                implicitWidth: 18
                                implicitHeight: 18
                                icon: "\u{f0156}"
                                glyphSize: Ui.menuFontSize
                                glyphColor: hovered ? Ui.fg : Ui.gray
                                color: hovered ? Ui.bg2 : "transparent"
                                onClicked: card.modelData.dismiss()
                            }
                        }
                        Txt {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: card.modelData.body
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            font.pixelSize: Ui.menuFontSize
                            font.bold: false
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            visible: card.buttons.length > 0
                            spacing: 6

                            Repeater {
                                model: card.buttons
                                Rectangle {
                                    id: action
                                    required property NotificationAction modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 24
                                    radius: Ui.radius
                                    color: actionMouse.containsMouse ? Ui.bg2 : Ui.bg1
                                    Txt {
                                        anchors.centerIn: parent
                                        text: action.modelData.text
                                        font.pixelSize: Ui.menuFontSize
                                    }
                                    MouseArea {
                                        id: actionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: action.modelData.invoke()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
