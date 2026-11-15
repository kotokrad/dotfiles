//@ pragma UseQApplication
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Notifications {
        id: notificationArea
    }
    ConnectionNotifications {
        notifications: notificationArea
    }
    Osd {}

    IpcHandler {
        target: "shell"
        // `qs ipc call shell open quicksettings` (or calendar) on the focused screen;
        // returns the panel's bottom edge, 0 if there's no such panel
        function open(name: string): int {
            const panel = Ui.dropdowns.find(p => p.objectName === name && p.screen === Mango.focusedScreen);
            if (!panel)
                return 0;
            panel.visible = true;
            return Math.ceil(panel.contentBottom);
        }
        function close(): void {
            Ui.closeDropdowns();
        }
    }
}
