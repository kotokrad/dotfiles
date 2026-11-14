//@ pragma UseQApplication
import Quickshell

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
}
