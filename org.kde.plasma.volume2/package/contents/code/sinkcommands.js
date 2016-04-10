var maximumValue = 65536;
var totalSteps = 15;

function bound(value, min, max) {
    return Math.max(min, Math.min(value, max));
}

function volumePercent(volume) {
    return 100 * volume / maximumValue;
}

function toggleMute(pulseObject) {
    var toMute = !pulseObject.muted;
    pulseObject.muted = toMute;
}

function setVolume(pulseObject, volume) {
    if (volume > 0 && pulseObject.muted) {
        toggleMute(pulseObject);
    }
    pulseObject.volume = volume
}

function addVolume(pulseObject, step) {
    console.log('addVolume', pulseObject, step);
    var volume = bound(pulseObject.volume + step, 0, maximumValue);
    setVolume(pulseObject, volume);
}

function increaseVolume(pulseObject) {
    console.log('increaseVolume', pulseObject);
    var step = maximumValue / totalSteps;
    addVolume(pulseObject, step);
}


function decreaseVolume(pulseObject) {
    console.log('decreaseVolume', pulseObject);
    var step = maximumValue / totalSteps;
    addVolume(pulseObject, -step);
}
