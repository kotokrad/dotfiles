import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

// One screen of the lock screen; Lock.qml holds the password and does the checking
Item {
    id: surface
    required property var lock
    readonly property var battery: UPower.displayDevice
    readonly property string kb: Mango.monitors[0]?.keyboardlayout ?? ""
    property point pointerStart: Qt.point(-1, -1)

    focus: true
    opacity: 0
    Keys.onPressed: event => {
        event.accepted = true;
        if (surface.lock.inGrace()) {
            surface.lock.unlock();
            return;
        }
        if (surface.lock.checking)
            return;
        const ctrl = event.modifiers & Qt.ControlModifier;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            surface.lock.submit();
        else if (event.key === Qt.Key_Escape || ctrl && (event.key === Qt.Key_U || event.key === Qt.Key_Backspace))
            surface.lock.clear();
        else if (event.key === Qt.Key_Backspace)
            surface.lock.backspace();
        else if (!ctrl && event.text !== "" && event.text.charCodeAt(0) >= 0x20 && event.text !== "\x7f")
            surface.lock.type(event.text);
    }

    // From the first frame on screen: the surface is built well before it's shown
    Connections {
        id: firstFrame
        target: surface.Window.window
        function onFrameSwapped() {
            firstFrame.enabled = false;
            fadeIn.start();
        }
    }

    NumberAnimation on opacity {
        id: fadeIn
        running: false
        to: 1
        duration: 200
        easing.type: Easing.OutCubic
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        color: Ui.bg
    }

    // The bar's islands, where the bar keeps them
    Island {
        anchors.left: parent.left
        anchors.leftMargin: Ui.gap
        anchors.top: parent.top
        anchors.topMargin: Ui.topGap
        Txt {
            text: "\u{f033e}"
        }
        Txt {
            text: Quickshell.env("USER") ?? ""
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: Ui.gap
        anchors.top: parent.top
        anchors.topMargin: Ui.topGap
        spacing: Ui.gap

        Island {
            visible: surface.kb !== ""
            Txt {
                text: Ui.kbLayouts[surface.kb] ?? surface.kb
            }
        }

        Island {
            id: power
            readonly property int pct: Math.round(surface.battery.percentage * 100)
            readonly property bool charging: surface.battery.state === UPowerDeviceState.Charging
            visible: surface.battery.isLaptopBattery
            Txt {
                text: Ui.batteryIcon(power.pct, power.charging) + " " + power.pct + "%"
                color: power.charging ? Ui.fg : power.pct < 15 ? Ui.red : power.pct < 30 ? Ui.yellow : Ui.fg
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height * 0.04
        spacing: 0

        Txt {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "HH") + "<font color=\"" + Ui.accent + "\">:</font>" + Qt.formatDateTime(clock.date, "mm")
            textFormat: Text.StyledText
            font.pixelSize: 112
        }
        Txt {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: -10
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
            font.pixelSize: 15
            font.bold: false
            color: Ui.gray
        }

        // Just the dots: gray while checking, red when wrong
        Txt {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: surface.width * 0.6
            Layout.topMargin: 36
            text: "•".repeat(surface.lock.checking || surface.lock.failed ? surface.lock.tried : surface.lock.password.length) || " "
            elide: Text.ElideLeft
            font.pixelSize: 20
            color: surface.lock.failed ? Ui.red : surface.lock.checking ? Ui.gray : Ui.fg
        }
    }

    // On top of the islands so grace-period moves register everywhere
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.BlankCursor
        acceptedButtons: Qt.AllButtons
        // The pointer resting where the surface appears isn't a move
        onPositionChanged: mouse => {
            if (surface.pointerStart.x < 0)
                surface.pointerStart = Qt.point(mouse.x, mouse.y);
            else if (Math.hypot(mouse.x - surface.pointerStart.x, mouse.y - surface.pointerStart.y) > 8 && surface.lock.inGrace())
                surface.lock.unlock();
        }
        onPressed: if (surface.lock.inGrace())
            surface.lock.unlock()
    }
}
