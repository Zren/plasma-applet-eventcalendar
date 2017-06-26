import QtQuick 2.0
import org.kde.plasma.private.volumewin7mixer 1.0

VolumePeaks {
	id: volumePeaks
	peaking: plasmoid.expanded
	property real defaultSinkPeakRatio: defaultSinkPeak / 65536
	property int defaultSinkPeakPercent: Math.round(defaultSinkPeakRatio*100)
	property string filename: plasmoid.file("", "code/peak/peak_monitor.py")
	peakCommand: {
		var command = ''

		if (mixerItem.mixerItemType == 'Sink' || mixerItem.mixerItemType == 'Source') {
			command = "python2 " + filename + " " + mixerItem.mixerItemType + " " + PulseObject.index
		} else if (mixerItem.mixerItemType == 'SinkInput' || mixerItem.mixerItemType == 'SourceOutput') {
			command = "python2 " + filename + " " + mixerItem.mixerItemType + " " + PulseObject.deviceIndex + " " + PulseObject.index
		}

		// console.log("filename", filename)
		// console.log("command", command)
		return command
	}
}
