pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    property alias accentName: theme.accent

    readonly property color bg: "#232a2e"
    readonly property color bg0: "#2d353b"
    readonly property color bg1: "#3d484d"
    readonly property color bg2: "#475258"
    readonly property color bg3: "#56635f"
    readonly property color fg: "#d3c6aa"
    readonly property color gray: "#859289"
    // Warnings keep gruvbox's colors
    readonly property color yellow: "#fabd2f"
    readonly property color red: "#fb4934"

    // Top row gruvbox's bright tones, bottom row Everforest's own
    readonly property var accents: [
        { name: "Orange", color: "#fe8019" },
        { name: "Aqua", color: "#8ec07c" },
        { name: "Blue", color: "#83a598" },
        { name: "Purple", color: "#d3869b" },
        { name: "Green", color: "#b8bb26" },
        { name: "Soft orange", color: "#e69875" },
        { name: "Soft aqua", color: "#83c092" },
        { name: "Soft blue", color: "#7fbbb3" },
        { name: "Soft purple", color: "#d699b6" },
        { name: "Soft green", color: "#a7c080" }
    ]
    readonly property color accent: (accents.find(a => a.name === accentName) ?? accents[0]).color

    FileView {
        path: Quickshell.statePath("theme.json")
        blockLoading: true // the first frame already has the saved theme
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter(); // first run: save the defaults
        }

        JsonAdapter {
            id: theme
            property string accent: "Blue"
        }
    }

    readonly property string font: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSize: 10
    readonly property int barHeight: 24
    readonly property int height: 21
    // The strip above the islands; their click areas reach over it, so the screen's top edge works
    readonly property int topGap: barHeight - height
    readonly property int radius: 5
    readonly property int gap: 6
    readonly property int menuFontSize: 11

    // mango reports xkb layout names; in mango's xkb_rules_layout order (us,ru,ua)
    readonly property var kbLayouts: ({ "English (US)": "en", "Russian": "ru", "Ukrainian": "ua" })

    function wifiIcon(strength) {
        return ["\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"][Math.min(3, Math.floor(strength * 4))];
    }

    function batteryIcon(pct, charging) {
        if (charging)
            return "\u{f0084}";
        return ["\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"][Math.min(9, Math.floor(pct / 10))];
    }

    property bool idleInhibit: false
    property bool dnd: false
    // xdg-desktop-portal-wlr's screencast node; popups would land on the shared screen
    readonly property bool screencast: Pipewire.nodes.values.some(n => n.name.startsWith("xdpw-stream"))
    readonly property bool quiet: dnd || screencast
}
