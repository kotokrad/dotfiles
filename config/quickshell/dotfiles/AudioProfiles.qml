import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
    id: profiles
    property bool active: false
    property var devices: []
    property string error: ""
    property int pendingDevice: -1
    property int pendingProfile: -1
    property bool awaitSink: false
    property bool awaitSource: false
    readonly property bool changing: pendingDevice !== -1

    onActiveChanged: {
        if (active)
            error = "";
        else if (!changing)
            query.running = false;
    }

    function deviceFor(node) {
        const id = node?.properties?.["device.id"];
        return devices.find(d => d.id === Number(id)) ?? null;
    }

    function isHeadset(profile) {
        return /^headset-head-unit(?:-|$)/.test(profile.name);
    }

    function choices(device, sink) {
        const direction = sink ? "Audio/Sink" : "Audio/Source";
        const available = (device?.profiles ?? [])
            .filter(p => p.available !== "no" && p.classes?.some(c => c[0] === direction))
            .sort((a, b) => (b.priority ?? 0) - (a.priority ?? 0));
        // Priority is PipeWire's preference, not a measured fidelity score; available is sorted by it.
        const recommended = sink ? available.find(p => !isHeadset(p)) : null;

        return available.map(p => {
            const codec = p.description?.match(/codec\s+([^,)]+)/i)?.[1];
            return {
                index: p.index,
                label: codec || p.description || p.name,
                recommended: p === recommended,
                headset: isHeadset(p)
            };
        });
    }

    function refresh() {
        if ((active || changing) && !query.running)
            query.running = true;
    }

    function select(device, index, sink) {
        if (!device || changing)
            return;
        const profile = device.profiles.find(p => p.index === index);
        if (!profile)
            return;
        error = "";
        pendingProfile = index;
        awaitSink = sink || deviceFor(Pipewire.defaultAudioSink)?.id === device.id;
        awaitSource = profile.classes.some(c => c[0] === "Audio/Source")
            && (!sink || deviceFor(Pipewire.defaultAudioSource)?.id === device.id);
        pendingDevice = device.id;
        timeout.restart();
        change.command = ["wpctl", "set-profile", String(device.id), String(index)];
        change.running = true;
    }

    function finish(message) {
        error = message;
        timeout.stop();
        pendingDevice = -1;
    }

    function nodeReady(node, objects) {
        return node?.ready && Number(node.properties?.["device.id"]) === pendingDevice
            && objects.some(o => o.id === node.id && o.type === "PipeWire:Interface:Node"
                && String(o.info?.props["object.serial"]) === String(node.properties["object.serial"]));
    }

    Process {
        id: query
        command: ["pw-dump"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!profiles.active && !profiles.changing)
                    return;
                try {
                    const objects = JSON.parse(text);
                    const devices = objects.filter(d => d.type === "PipeWire:Interface:Device"
                        && (d.info?.props["device.api"] === "bluez5" || d.info?.props["device.bus"] === "bluetooth"))
                        .map(d => ({ id: d.id, profiles: d.info.params?.EnumProfile ?? [], current: d.info.params?.Profile?.[0]?.index ?? -1 }));
                    // wpctl exits before PipeWire finishes replacing the nodes. Commit once
                    // the requested profile and its bound default nodes agree on the new graph.
                    if (profiles.changing) {
                        const device = devices.find(d => d.id === profiles.pendingDevice);
                        if (change.running || device?.current !== profiles.pendingProfile
                            || (profiles.awaitSink && !profiles.nodeReady(Pipewire.defaultAudioSink, objects))
                            || (profiles.awaitSource && !profiles.nodeReady(Pipewire.defaultAudioSource, objects)))
                            return;
                    }
                    // Leave an open codec menu alone when its choices have not changed.
                    if (JSON.stringify(devices) !== JSON.stringify(profiles.devices))
                        profiles.devices = devices;
                    if (profiles.changing)
                        profiles.finish("");
                } catch (e) {
                    if (!profiles.changing)
                        profiles.devices = [];
                }
            }
        }
    }

    Process {
        id: change
        onExited: code => {
            if (code !== 0)
                profiles.finish("Could not change the audio codec. Try again.");
            profiles.refresh();
        }
    }

    Timer {
        id: timeout
        interval: 10000
        onTriggered: {
            profiles.finish("The audio device did not finish changing codec. Try again.");
            profiles.refresh();
        }
    }

    // Profiles are not exposed by Quickshell's PipeWire API; query while the menu is open
    // or a requested switch still needs to finish.
    Timer {
        interval: profiles.changing ? 100 : 2000
        running: profiles.active || profiles.changing
        repeat: true
        triggeredOnStart: true
        onTriggered: profiles.refresh()
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() { profiles.refresh(); }
        function onDefaultAudioSourceChanged() { profiles.refresh(); }
    }
}
