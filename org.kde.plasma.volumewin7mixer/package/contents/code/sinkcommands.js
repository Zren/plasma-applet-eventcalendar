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
