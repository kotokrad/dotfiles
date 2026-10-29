import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Island {
    id: media
    // playerctld proxies the other players
    readonly property var players: Mpris.players.values.filter(p => !p.dbusName.includes("playerctld"))
    readonly property var player: players.find(p => p.isPlaying) ?? players[0] ?? null

    visible: player !== null && player.trackTitle !== ""
    hoverable: true
    onClicked: player.togglePlaying()

    Txt {
        Layout.maximumWidth: 220
        elide: Text.ElideRight
        text: (media.player?.isPlaying ? "\u{f04c}  " : "\u{f04b}  ") + [media.player?.trackArtist, media.player?.trackTitle].filter(s => s).join(" – ")
    }
}
