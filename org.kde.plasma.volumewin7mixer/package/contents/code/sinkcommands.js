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

function setVolume(pulseObject, volume) {
    console.log('setVolume', pulseObject.volume, '=>', volume);
    if (volume > 0 && pulseObject.muted) {
        toggleMute(pulseObject);
    }
    pulseObject.volume = volume
    return volume
}

function addVolume(pulseObject, step) {
    console.log('addVolume', pulseObject, step);
    var volume = bound(pulseObject.volume + step, 0, maximumValue);
    return setVolume(pulseObject, volume);
}

function increaseVolume(pulseObject) {
    console.log('increaseVolume', pulseObject);
    var totalSteps = plasmoid.configuration.volumeUpDownSteps;
    var step = maximumValue / totalSteps;
    return addVolume(pulseObject, step);
}


function decreaseVolume(pulseObject) {
    console.log('decreaseVolume', pulseObject);
    var totalSteps = plasmoid.configuration.volumeUpDownSteps;
    var step = maximumValue / totalSteps;
    return addVolume(pulseObject, -step);
}
