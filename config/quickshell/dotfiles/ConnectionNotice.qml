import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: notice
    required property var notifications
    property string title: ""
    property string icon: ""
    property string symbol: ""
    property string desiredBody: ""
    property string sentBody: ""
    property string sendingBody: ""
    property int notificationId: 0
    property bool announce: false

    function publish(title, body, icon, symbol, announce) {
        notice.title = title;
        notice.icon = icon;
        notice.symbol = symbol;
        desiredBody = body;
        notice.announce = notice.announce || announce;
        flush();
    }

    function flush() {
        if (sender.running || desiredBody === sentBody)
            return;
        const replace = notifications.isActive(notificationId) ? notificationId : 0;
        // Codec and battery updates must not resurrect a dismissed or expired notification.
        if (!announce && replace === 0)
            return;
        announce = false;
        sendingBody = desiredBody;
        const escaped = sendingBody.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        sender.command = ["notify-send", "--app-name", "Quickshell", "--icon", icon,
            "--hint", "string:x-quickshell-symbol:" + symbol, "--transient", "--print-id",
            "--replace-id", String(replace), "--", title, escaped];
        sender.running = true;
    }

    Process {
        id: sender
        stdout: StdioCollector {
            onStreamFinished: {
                const id = Number(text.trim());
                if (id > 0) {
                    notice.notificationId = id;
                    notice.sentBody = notice.sendingBody;
                }
                Qt.callLater(notice.flush);
            }
        }
        onExited: code => {
            if (code !== 0)
                notice.sentBody = notice.desiredBody;
            Qt.callLater(notice.flush);
        }
    }
}
