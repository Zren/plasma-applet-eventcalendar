var maximumValue = 65536;

function bound(value, min, max) {
    return Math.max(min, Math.min(value, max));
}

function volumePercent(volume) {
    return 100 * volume / maximumValue;
}

function toggleMute(pulseObject) {
    var toMute = !pulseObject.muted;
    pulseObject.muted = toMute;
    return toMute
}

function setPercent(pulseObject, percent) {
    var volume = maximumValue * percent/100
    return setVolume(pulseObject, volume)
}

function setVolume(pulseObject, volume) {
    // console.log('setVolume', pulseObject.volume, '=>', volume);
    if ((volume > 0 && pulseObject.muted) || (volume == 0 && !pulseObject.muted)) {
        toggleMute(pulseObject);
    }
    pulseObject.volume = volume
    return volume
}

function addVolume(pulseObject, step) {
    // console.log('addVolume', pulseObject, step);
    var volume = bound(pulseObject.volume + step, 0, maximumValue);
    if (maximumValue - volume < step) {
        volume = maximumValue;
    } else if (volume < step) {
        volume = 0;
    }
    return setVolume(pulseObject, volume);
}

function increaseVolume(pulseObject) {
    // console.log('increaseVolume', pulseObject);
    var totalSteps = plasmoid.configuration.volumeUpDownSteps;
    var step = maximumValue / totalSteps;
    return addVolume(pulseObject, step);
}


function decreaseVolume(pulseObject) {
    // console.log('decreaseVolume', pulseObject);
    var totalSteps = plasmoid.configuration.volumeUpDownSteps;
    var step = maximumValue / totalSteps;
    return addVolume(pulseObject, -step);
}


// module-loopback
// https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-loopback
// We use source.properties['loopback.moduleid'] != -1 serialize the state.
function getLoopbackModuleId(pulseObject) {
    // Not necessarily a Source
    if (typeof PulseObject.properties === "undefined")
        return;

    var moduleId = PulseObject.properties['loopback.moduleid']
    if (moduleId) {
        return parseInt(moduleId, 10)
    } else {
        return -1
    }
}
function hasLoopbackModuleId(pulseObject) {
    return getLoopbackModuleId(pulseObject) >= 0
}
function toggleModuleLoopback(pulseObject) {
    var moduleId = getLoopbackModuleId(pulseObject)
    if (moduleId >= 0) {
        PulseObjectCommands.disableModuleLoopback(moduleId)
        PulseObjectCommands.setLoopbackProperties(pulseObject.index, -1)
    } else {
        PulseObjectCommands.enableModuleLoopback(pulseObject.index)
    }
}

function enableModuleLoopback(sourceId) {
    var command = 'pactl load-module module-loopback'
    command += ' latency_msec=1'
    command += ' source=' + sourceId
    command += ' source_output_properties="loopback.source=' + sourceId + '"'
    command += ' sink_input_properties="loopback.source=' + sourceId + '"'
    console.log('enableModuleLoopback.command', command)
    var callback = loadModuleLoopbackCallback.bind(null, sourceId)
    executable.execAwait(command, callback)
}

function loadModuleLoopbackCallback(sourceId, command, exitCode, exitStatus, stdout, stderr) {
    console.log('LoopbackCallback.sourceId', sourceId)
    var moduleId = executable.trimOutput(stdout)
    console.log('LoopbackCallback.moduleId', moduleId)
    // disableModuleLoopback(moduleId)
    setLoopbackProperties(sourceId, moduleId)
}

function setLoopbackProperties(sourceId, moduleId) {
    var command = 'pacmd update-source-proplist ' + sourceId + ' loopback.moduleid="' + moduleId + '"'
    console.log('setLoopbackProperties.command', command)
    executable.exec(command)
}

function disableModuleLoopback(moduleId) {
    var command = 'pactl unload-module ' + moduleId
    console.log('disableModuleLoopback.command', command)
    executable.exec(command)
}
