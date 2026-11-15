// The lock screen, run as its own instance by quickshell-lock (../lock.nix): a bar crash or reload
// can't take it down, and it exits once unlocked. LOCK_PREVIEW=1 shows it in a window instead.
// The bar's state dir (by-shell/<md5 of ~/.config/quickshell/shell.qml>) brings the saved accent.
//@ pragma StateDir $BASE/quickshell/by-shell/c0d1fa988dfbfb0354a4be2cbf62bd4c
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

ShellRoot {
    id: root
    readonly property bool preview: Quickshell.env("LOCK_PREVIEW") === "1"
    // Idle locks open on any input until then (epoch seconds). Wall clock, so suspend ends it too
    property real graceUntil: Number(Quickshell.env("LOCK_GRACE_UNTIL") ?? 0) * 1000
    property string password: ""
    property int tried: 0 // length of the submitted password; its dots stay up while checking
    property bool failed: false
    readonly property bool checking: pam.active

    function inGrace() {
        return Date.now() < graceUntil;
    }

    function unlock() {
        if (preview) {
            Qt.quit();
            return;
        }
        lock.locked = false;
        quit.start();
    }

    function type(text) {
        failed = false;
        password += text;
        forget.restart();
    }

    function backspace() {
        failed = false;
        password = password.slice(0, -1);
        forget.restart();
    }

    function clear() {
        failed = false;
        password = "";
    }

    function submit() {
        if (checking || password === "")
            return;
        tried = password.length;
        if (!pam.start()) {
            password = "";
            failed = true;
        }
    }

    WlSessionLock {
        id: lock
        locked: !root.preview
        // Also false when mango refuses the lock because another locker holds it
        onSecureChanged: if (!secure)
            quit.start()

        // LockSurface draws the background, so it fades in over the desktop (allow_lock_transparent)
        WlSessionLockSurface {
            color: "transparent"
            LockSurface {
                anchors.fill: parent
                lock: root
            }
        }
    }

    LazyLoader {
        active: root.preview
        FloatingWindow {
            title: "Lock preview"
            implicitWidth: 1100
            implicitHeight: 700
            color: "transparent"
            LockSurface {
                anchors.fill: parent
                lock: root
            }
        }
    }

    PamContext {
        id: pam
        // /etc/pam.d/quickshell-lock: security.pam.services on NixOS, by hand on the macbook
        config: "quickshell-lock"
        onPamMessage: {
            if (responseRequired) {
                respond(root.password);
                root.password = "";
            }
        }
        onCompleted: result => {
            root.password = "";
            if (result === PamResult.Success)
                root.unlock();
            else
                root.failed = true; // PAM errors too (journalctl --user -u quickshell-lock)
        }
    }

    IpcHandler {
        target: "lock"
        // Every screen is covered; quickshell-lock waits for this before letting the system sleep
        function secure(): bool {
            return lock.secure;
        }
        // Another lock request (the lid closed right after an idle lock) wants the password
        function endGrace(): void {
            root.graceUntil = 0;
        }
    }

    // A half-typed password doesn't wait for the next person
    Timer {
        id: forget
        interval: 30000
        onTriggered: root.clear()
    }

    // Exiting right away could close the connection before mango reads the unlock
    Timer {
        id: quit
        interval: 1000
        onTriggered: Qt.quit()
    }
}
