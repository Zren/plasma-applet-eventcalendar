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


// module toggle utils
function getProperty(pulseObject, key, defaultValue) {
    // Not necessarily a Source
    if (typeof pulseObject.properties === "undefined")
        return defaultValue;

    var value = pulseObject.properties[key];
    if (value) {
        return parseInt(value, 10);
    } else {
        return defaultValue;
    }
}

function setSourceProperty(sourceId, key, value) {
    var command = 'pacmd update-source-proplist ' + sourceId + ' ' + key + '="' + value + '"'
    console.log('setSourceProperty.command', command)
    executable.exec(command)
}

function disableModule(moduleId) {
    var command = 'pactl unload-module ' + moduleId
    console.log('disableModule.command', command)
    executable.exec(command)
}

function hasIdProperty(pulseObject, key) {
    return getProperty(pulseObject, key, -1) >= 0
}

// module-loopback
// https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-loopback
// We use source.properties['loopback.module_id'] != -1 serialize the state.
function getLoopbackModuleId(pulseObject) {
    return getProperty(pulseObject, 'loopback.module_id', -1)
}
function hasLoopbackModuleId(pulseObject) {
    return getLoopbackModuleId(pulseObject) >= 0
}
function toggleModuleLoopback(pulseObject) {
    var moduleId = getLoopbackModuleId(pulseObject)
    if (moduleId >= 0) {
        disableModule(moduleId)
        setSourceProperty(pulseObject.index, 'loopback.module_id', -1)
    } else {
        enableModuleLoopback(pulseObject.index)
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
    setSourceProperty(sourceId, 'loopback.module_id', moduleId)
}


// module-echo-cancel
// https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-echo-cancel
// https://github.com/pulseaudio/pulseaudio/blob/master/src/modules/echo-cancel/module-echo-cancel.c
// We use source.properties['echo_cancel.module_id'] != -1 serialize the state.
function getEchoCancelModuleId(pulseObject) {
    return getProperty(pulseObject, 'echo_cancel.module_id', -1)
}
function hasEchoCancelModuleId(pulseObject) {
    return getEchoCancelModuleId(pulseObject) >= 0
}
function toggleModuleEchoCancel(pulseObject) {
    var moduleId = getEchoCancelModuleId(pulseObject)
    console.log('toggleModuleEchoCancel.moduleId', moduleId)
    if (moduleId >= 0) {

        // If the generated stream has loopback enabled, we need to...
        if (true) {
            // ... disable the other stream first.
            var loopbackedStream = main.getStream(filteredSourceModel, function(stream) {
                // console.log('findStream', getProperty(stream, 'echo_cancel.source', -1), pulseObject.index, hasLoopbackModuleId(stream))
                return getProperty(stream, 'echo_cancel.source', -1) == pulseObject.index // The generated echo cancelled source (microphone)
                    && hasLoopbackModuleId(stream) // which also has loopback enabled
            })
            console.log('toggleModuleEchoCancel.loopbackedStream', loopbackedStream)
            if (loopbackedStream) {
                var loopbackModuleId = getLoopbackModuleId(loopbackedStream)
                console.log('toggleModuleEchoCancel.loopbackModuleId', loopbackModuleId)
                if (loopbackModuleId >= 0) {
                    disableModule(loopbackModuleId)
                    // We don't need to block execution, since if echo cancel is disabled first
                    // the loopback will attach itself to the microphone directly.
                    // We should block execution if someone complains a noise when cancelling both.
                }
            }
        } else {
            // ... move the "loopback.module_id" to the current stream
            // Since the loopback will automatically attach itself to the echo cancelled source (this stream)
            // TODO: 
        }
        

        disableModule(moduleId)
        setSourceProperty(pulseObject.index, 'echo_cancel.module_id', -1)
    } else {
        enableModuleEchoCancel(pulseObject.index)
    }
}

function enableModuleEchoCancel(sourceId) {
    var command = 'pactl load-module module-echo-cancel'
    command += ' source_master=' + sourceId
    command += ' source_properties="echo_cancel.source=' + sourceId + '"'
    command += ' sink_properties="echo_cancel.source=' + sourceId + '"'

    // command += " source_properties=echo_cancel.source=\\'" + sourceId + "\\'application.id=\\'org.PulseAudio.pavucontrol\\'"
    // command += " sink_properties=echo_cancel.source=\\'" + sourceId + "\\'application.id=\\'org.PulseAudio.pavucontrol\\'"
    
    console.log('enableModuleEchoCancel.command', command)
    var callback = loadModuleEchoCancelCallback.bind(null, sourceId)
    executable.execAwait(command, callback)
}

function loadModuleEchoCancelCallback(sourceId, command, exitCode, exitStatus, stdout, stderr) {
    console.log('EchoCancelCallback.sourceId', sourceId)
    console.log('EchoCancelCallback.stdout', stdout)
    var moduleId = executable.trimOutput(stdout)
    console.log('EchoCancelCallback.moduleId', moduleId)
    if (moduleId) {
        setSourceProperty(sourceId, 'echo_cancel.module_id', moduleId)
    }
}
