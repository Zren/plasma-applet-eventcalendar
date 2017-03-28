import QtQuick 2.0

Item {
    id: inputMananger

    Connections {
        target: plasmoid
        onExpandedChanged: {
            if (!plasmoid.expanded) {
                inputMananger.selectNone()
            }
        }
        onActivated: {
            // console.log('onActivated', 'expanded', plasmoid.expanded)
            if (!plasmoid.expanded) { // Shouldn't yet be expanded
                inputMananger.selectDefault()
            }
        }
    }

    property var mixerItemGroupList: [
        sourceOutputMixerItemGroup,
        sinkInputMixerItemGroup,
        sourceMixerItemGroup,
        sinkMixerItemGroup,
    ]
    property int selectedGroupIndex: -1
    readonly property var selectedListView: selectedGroupIndex >= 0 ? mixerItemGroupList[selectedGroupIndex].view : null
    readonly property var selectedGroupModel: selectedListView ? selectedListView.model : null
    readonly property int selectedStreamIndex: selectedListView ? selectedListView.currentIndex : -1
    readonly property bool hasSelection: selectedStreamIndex >= 0
    readonly property var selectedMixerItem: hasSelection ? selectedListView.currentItem : null


    function findStream(model, predicate) {
        for (var i = 0; i < model.count; i++) {
            var stream = model.get(i)
            stream = stream.PulseObject
            // console.log(i, stream, predicate(stream, i))
            if (predicate(stream, i)) {
                return i
            }
        }
        return -1
    }
    function setCurrentGroupStreamIndex(streamIndex) {
        if (selectedGroupIndex >= 0) {
            mixerItemGroupList[selectedGroupIndex].view.currentIndex = streamIndex
        }
    }
    function select(groupIndex, streamIndex) {
        // console.log('select', groupIndex, streamIndex)
        if (selectedGroupIndex != groupIndex) {
            setCurrentGroupStreamIndex(-1)
        }
        selectedGroupIndex = groupIndex
        setCurrentGroupStreamIndex(streamIndex)
    }
    function selectDefaultSink() {
        // console.log('selectDefaultSink')
        var defaultSinkIndex = findStream(sinkMixerItemGroup.model, function(stream) { return stream == sinkModel.defaultSink })
        select(3, defaultSinkIndex)
    }
    function selectDefault() {
        // console.log('selectDefault')
        selectDefaultSink()
    }
    function selectNone() {
        // console.log('selectNone')
        select(-1, -1)
    }
    function modulo(n, l) {
        // qml returns a negative remainder, so make n positive first
        return (n + l) % l
    }
    function prevGroup() {
        for (var i = 1; i <= mixerItemGroupList.length; i++) { // Check each group
            var groupIndex = modulo(selectedGroupIndex - i, mixerItemGroupList.length)
            var mixerItemGroup = mixerItemGroupList[groupIndex]
            if (mixerItemGroup.model.count > 0) {
                select(groupIndex, mixerItemGroup.model.count - 1) // Select last item
                return
            }
        }
    }
    function selectLeft() {
        // console.log('selectLeft')
        if (hasSelection) {
            var streamIndex = selectedStreamIndex - 1
            if (streamIndex < 0) {
                prevGroup()
            } else {
                select(selectedGroupIndex, streamIndex)
            }
        } else {
            selectDefault()
        }
    }
    function nextGroup() {
        // console.log('nextGroup')
        for (var i = 1; i <= mixerItemGroupList.length; i++) { // Check each group
            var groupIndex = modulo(selectedGroupIndex + i, mixerItemGroupList.length)
            var mixerItemGroup = mixerItemGroupList[groupIndex]
            if (mixerItemGroup.model.count > 0) {
                select(groupIndex, 0) // Select first item
                return
            }
        }
    }
    function selectRight() {
        // console.log('selectRight')
        if (hasSelection) {
            var streamIndex = selectedStreamIndex + 1
            if (streamIndex >= selectedGroupModel.count) {
                nextGroup()
            } else {
                select(selectedGroupIndex, streamIndex)
            }
        } else {
            selectDefault()
        }
    }
}
