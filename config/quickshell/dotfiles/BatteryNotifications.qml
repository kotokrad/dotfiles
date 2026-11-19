import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Scope {
    id: watcher
    property bool ready: false
    property int notified: 0
    property real volts: 0
    property bool voltageLow: false

    readonly property var battery: UPower.displayDevice
    readonly property int pct: Math.round(battery.percentage * 100)
    readonly property bool onBattery: UPower.onBattery && battery.isLaptopBattery
    readonly property int level: !onBattery ? 0 : voltageLow ? 3 : pct <= 15 ? 2 : pct <= 30 ? 1 : 0

    onOnBatteryChanged: if (!onBattery) voltageLow = false

    onLevelChanged: {
        if (ready && level > notified) {
            const critical = level >= 2;
            Quickshell.execDetached(["notify-send", "--app-name", "Quickshell",
                "--urgency", critical ? "critical" : "normal",
                "--hint", "string:x-quickshell-symbol:" + Ui.batteryIcon(pct, false), "--transient",
                "--", level === 3 ? "Plug in now" : critical ? "Battery is critically low" : "Battery is low",
                level === 3 ? volts.toFixed(1) + "V" : pct + "%"]);
        }
        // A brief uptick on battery must not re-arm the warning
        if (level > notified || !onBattery)
            notified = level;
    }

    FileView {
        id: voltage
        readonly property var device: UPower.devices.values.find(d => d.isLaptopBattery)
        path: device && Ui.lowVoltage > 0 ? `/sys/class/power_supply/${device.nativePath}/voltage_now` : ""
        onLoaded: watcher.volts = parseInt(text()) / 1e6
    }
    Timer {
        interval: 5000
        running: watcher.onBattery && Ui.lowVoltage > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: voltage.reload()
    }
    // Load spikes sag the voltage for seconds at any charge
    Timer {
        interval: 60000
        running: watcher.onBattery && watcher.volts > 0 && watcher.volts < Ui.lowVoltage
        onTriggered: watcher.voltageLow = true
    }

    // Seed the current state after the services load, including on a QML reload.
    Timer {
        interval: 1500
        running: true
        onTriggered: {
            watcher.notified = watcher.level;
            watcher.ready = true;
        }
    }
}
