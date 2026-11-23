pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The endpoint behind Claude Code's /usage (internal, may change)
Singleton {
    id: claude
    objectName: "claude"
    property var usage: null
    property date updated
    property date tried
    property string error: ""
    property date renewed: new Date(0)
    readonly property alias interval: poll.interval
    readonly property string icon: "\uec82" // nf-cod-claude
    // limits[] is what Claude Code's own /usage renders; the older five_hour/seven_day fields can disagree with it
    readonly property var session: asWindow(usage?.limits?.find(l => l.kind === "session"))
    readonly property var week: asWindow(usage?.limits?.find(l => l.kind === "weekly_all"))
    readonly property var details: [
        ["This week", (usage?.seven_day_breakdown?.rows ?? []).filter(r => r.percent > 0).map(r => r.display_name + " " + r.percent + "%").join(" · ") || "nothing yet"],
        ["Extra usage", usage?.spend?.enabled ? (usage.spend.used.amount_minor / 10 ** usage.spend.used.exponent).toFixed(usage.spend.used.exponent) + " " + usage.spend.used.currency + " used" : "off"]
    ]

    // The shape Usage.qml reads: percent used, reset time in ms
    function asWindow(l) {
        return l ? { percent: l.percent, resetsAt: Date.parse(l.resets_at) } : null;
    }
    // Fetches now and restarts the countdown; at most once a minute, the endpoint rate-limits
    function refresh() {
        if (new Date() - tried > 60000)
            poll.restart();
    }

    Process {
        id: curl
        command: ["sh", "-c", "curl -s -m 10 https://api.anthropic.com/api/oauth/usage -H 'anthropic-beta: oauth-2025-04-20' -H \"Authorization: Bearer $(jq -r .claudeAiOauth.accessToken ~/.claude/.credentials.json)\""]
        stdout: StdioCollector {
            // Errors come back as {"type":"error","error":{"message":"OAuth access token is invalid."}}; offline gives no output
            onStreamFinished: {
                let r = null;
                try {
                    r = JSON.parse(text);
                } catch (e) {}
                if (r && r.type !== "error") {
                    claude.usage = r;
                    claude.updated = new Date();
                    claude.error = "";
                } else if (r?.error?.type === "authentication_error" && claude.renewed < claude.tried) {
                    claude.renewed = new Date();
                    renew.running = true;
                } else {
                    claude.error = r?.error?.message?.replace(/^OAuth |\.$/g, "") || "no response";
                }
            }
        }
    }

    // An expired token: headless /usage makes Claude Code renew it (no model call), then fetch again; once per poll
    Process {
        id: renew
        // The systemd bar does not inherit the interactive shell's PATH
        command: [Quickshell.env("HOME") + "/.local/bin/claude", "-p", "/usage", "--no-session-persistence"]
        onExited: curl.running = true
    }

    Timer {
        id: poll
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            claude.tried = new Date();
            curl.running = true;
        }
    }
}
