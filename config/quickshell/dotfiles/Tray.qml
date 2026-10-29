import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Island {
    id: tray
    required property QsWindow bar

    // nm-applet keeps running as the Wi-Fi/VPN password agent, and gammastep is the night
    // light tile in quick settings; their icons are redundant
    readonly property var hidden: ["nm-applet", "gammastep"]
    visible: SystemTray.items.values.some(i => !hidden.includes(i.id))

    Repeater {
        model: SystemTray.items

        IconImage {
            id: icon
            required property SystemTrayItem modelData
            // libappindicator items (gammastep, nm-applet, udiskie) don't implement Activate and
            // have no tooltip; like other bars, a left click opens their menu instead
            readonly property bool appIndicator: modelData.tooltipTitle === "" && modelData.tooltipDescription === ""

            visible: !tray.hidden.includes(modelData.id)
            implicitSize: 13
            source: modelData.icon

            MouseArea {
                id: mouse
                anchors.fill: parent
                anchors.topMargin: -Ui.topGap - (Ui.height - icon.height) / 2 // up to the screen edge
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: m => {
                    const item = icon.modelData;
                    if (m.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (m.button === Qt.RightButton || item.onlyMenu || (icon.appIndicator && item.hasMenu)) {
                        const p = tray.bar.contentItem.mapFromItem(icon, 0, icon.height);
                        item.display(tray.bar, p.x, p.y + 6);
                    } else {
                        item.activate();
                    }
                }
            }

            Tooltip {
                target: icon
                anchor.rect.y: (icon.height + Ui.height) / 2 + Ui.gap // the island's bottom edge, then the usual gap
                text: [icon.modelData.tooltipTitle || icon.modelData.title, icon.modelData.tooltipDescription].filter(s => s).join("\n")
                visible: mouse.containsMouse && text !== ""
            }
        }
    }
}
