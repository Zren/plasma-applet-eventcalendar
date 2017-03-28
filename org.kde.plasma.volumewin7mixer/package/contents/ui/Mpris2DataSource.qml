import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

// https://github.com/KDE/plasma-workspace/tree/master/dataengines/mpris2
PlasmaCore.DataSource {
    id: mpris2Source

    readonly property string multiplexSource: "@multiplex"
    property string current: multiplexSource

    engine: "mpris2"
    connectedSources: current

    onSourceRemoved: {
        // if player is closed, reset to multiplex source
        if (source === current) {
            current = multiplexSource
        }
    }

    // onNewData: logState()

    property bool hasPlayer: mpris2Source.sources.length >= 2 // We don't count @mutiplexSource
    property string playbackState: hasPlayer && mpris2Source.data[mpris2Source.current].PlaybackStatus
    property bool isPlaying: playbackState == "Playing"
    property bool isPaused: playbackState == "Paused"
    property bool isShuffling: canControl && mpris2Source.data[mpris2Source.current].Shuffle
    property string loopState: canControl && mpris2Source.data[mpris2Source.current].LoopStatus
    property bool isNotLooping: loopState == "None"
    property bool isLoopingTrack: loopState == "Track"
    property bool isLoopingPlaylist: loopState == "Playlist"

    property bool canControl: hasPlayer && mpris2Source.data[mpris2Source.current].CanControl
    property bool canGoPrevious: canControl && mpris2Source.data[mpris2Source.current].CanGoPrevious
    property bool canGoNext: canControl && mpris2Source.data[mpris2Source.current].CanGoNext
    property bool canRaise: hasPlayer && mpris2Source.data[mpris2Source.current].CanRaise
    property bool canShuffle: canControl
    property bool canLoop: canControl

    // if there's no "mpris:length" in teh metadata, we cannot seek, so hide it in that case (org.kde.plasma.mediacontroller)
    property bool canSeekMpris: hasPlayer && mpris2Source.data[mpris2Source.current].CanSeek
    property bool canSeek: canSeekMpris && /*track &&*/ length > 0


    property var currentMetadata: mpris2Source.data[mpris2Source.current] ? mpris2Source.data[mpris2Source.current].Metadata : null
    property string albumArt: currentMetadata ? currentMetadata["mpris:artUrl"] || "" : ""
    property string track: {
        if (!currentMetadata) {
            return ""
        }
        var xesamTitle = currentMetadata["xesam:title"]
        if (xesamTitle) {
            return xesamTitle
        }
        // if no track title is given, print out the file name
        var xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
        if (!xesamUrl) {
            return ""
        }
        var lastSlashPos = xesamUrl.lastIndexOf('/')
        if (lastSlashPos < 0) {
            return ""
        }
        var lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
        return decodeURIComponent(lastUrlPart)
    }
    property string artist: currentMetadata ? currentMetadata["xesam:artist"] || "" : ""
    // onTrackChanged: {
    //     function logObj(obj) {
    //         for (var key in obj) {
    //             if (typeof obj[key] === 'function') continue;
    //             console.log(obj, key, obj[key])
    //         }
    //     }
    //     logObj(currentMetadata)
    // }

    property double length: currentMetadata ? currentMetadata["mpris:length"] || 0 : 0
    property double position: hasPlayer ? mpris2Source.data[mpris2Source.current].Position : 0

    function logState() {
        console.log(JSON.stringify(mpris2Source.data, null, "\t"))
        console.log('hasPlayer', hasPlayer)
        console.log('currentMetadata', currentMetadata)
        console.log('position', position)
        console.log('length', length)
        console.log('canSeek', canSeek, 'canSeekMpris', canSeekMpris)
    }

    function retrievePosition() {
        serviceOp(mpris2Source.current, "GetPosition");
    }

    function setPosition(value) {
        var service = mpris2Source.serviceForSource(mpris2Source.current)
        var operation = service.operationDescription("SetPosition")
        operation.microseconds = value
        service.startOperationCall(operation)
    }

    function raisePlayer() {
        serviceOp(mpris2Source.current, "Raise");
    }

    function playPause() {
        serviceOp(mpris2Source.current, "PlayPause");
    }

    function previous() {
        serviceOp(mpris2Source.current, "Previous");
    }

    function next() {
        serviceOp(mpris2Source.current, "Next");
    }

    function stop() {
        serviceOp(mpris2Source.current, "Stop");
    }

    function raise() {
        serviceOp(mpris2Source.current, "Raise");
    }

    function setShuffle(value) {
        var service = mpris2Source.serviceForSource(mpris2Source.current)
        var operation = service.operationDescription("SetShuffle")
        operation.on = value
        service.startOperationCall(operation)
    }

    function toggleShuffle() {
        setShuffle(!isShuffling)
    }

    function setLoopState(value) {
        var service = mpris2Source.serviceForSource(mpris2Source.current)
        var operation = service.operationDescription("SetLoopStatus")
        operation.status = value
        service.startOperationCall(operation)
    }

    function toggleLoopState() {
        if (isNotLooping) {
            setLoopState("Track")
        } else if (isLoopingTrack) {
            setLoopState("Playlist")
        } else {
            setLoopState("None")
        }
    }

    function serviceOp(src, op) {
        var service = mpris2Source.serviceForSource(src);
        var operation = service.operationDescription(op);
        return service.startOperationCall(operation);
    }

    property bool isPlasmoidExpanded: plasmoid.expanded
    onIsPlasmoidExpandedChanged: {
        if (isPlasmoidExpanded) {
            retrievePosition();
        }
    }
}
