pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Codex's app-server, so the CLI handles auth and token refresh; started per fetch
Singleton {
    id: codex
    property var usage: null
    property date updated
    property date tried
    property string error: ""
    readonly property alias interval: poll.interval
    readonly property string icon: "\uec81" // nf-cod-openai
    readonly property var session: asWindow(usage?.primary)
    readonly property var week: asWindow(usage?.secondary)
    readonly property var details: [
        ["Plan", usage?.planType ?? "unknown"],
        ["Credits", usage?.credits?.hasCredits ? usage.credits.balance : "none"]
    ]

    // The shape Usage.qml reads: percent used, reset time in ms
    function asWindow(w) {
        return w ? { percent: w.usedPercent, resetsAt: w.resetsAt * 1000 } : null;
    }
    // Fetches now and restarts the countdown; at most once a minute
    function refresh() {
        if (new Date() - tried > 60000)
            poll.restart();
    }

    function send(message) {
        server.write(JSON.stringify(message) + "\n");
    }
    function finish(message) {
        error = message;
        timeout.stop();
        server.running = false;
    }

    Process {
        id: server
        // The systemd bar does not inherit the interactive shell's Bun PATH
        command: [Quickshell.env("HOME") + "/.bun/bin/codex", "app-server"]
        stdinEnabled: true
        onStarted: codex.send({ id: 0, method: "initialize", params: { clientInfo: { name: "quickshell", version: "1.0" } } })
        stdout: SplitParser {
            // Replies carry the id of our request; notifications carry none and are skipped
            onRead: line => {
                const r = JSON.parse(line);
                if (r.error) {
                    codex.finish(r.error.message);
                } else if (r.id === 0) {
                    codex.send({ method: "initialized" });
                    codex.send({ id: 1, method: "account/rateLimits/read" });
                } else if (r.id === 1) {
                    codex.usage = r.result.rateLimits;
                    codex.updated = new Date();
                    codex.finish("");
                }
            }
        }
    }

    // Also covers a server that never starts or dies before answering
    Timer {
        id: timeout
        interval: 20000
        onTriggered: codex.finish("no response")
    }

    Timer {
        id: poll
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            codex.tried = new Date();
            timeout.restart();
            server.running = true;
        }
    }
}
