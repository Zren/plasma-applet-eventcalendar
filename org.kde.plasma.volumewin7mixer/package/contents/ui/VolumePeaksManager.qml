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
			command = "python2 " + filename + " " + mixerItem.mixerItemType + " \"" + PulseObject.name + "\""
		} else if (mixerItem.mixerItemType == 'SinkInput') {
			// console.log('SinkInput', PulseObject.index, PulseObject.name, PulseObject.deviceIndex)
			for (var i = 0; i < filteredSinkModel.count; i++) {
				var sink = filteredSinkModel.get(i);
				sink = sink.PulseObject;
				// console.log('\t', i, sink, sink.name, sink.index)
				if (PulseObject.deviceIndex == sink.index) {
					command = "python2 " + filename + " " + mixerItem.mixerItemType + " \"" + sink.name + "\" " + PulseObject.index
					break;
				}
			}
		} else if (mixerItem.mixerItemType == 'SourceOutput') {
			console.log('SourceOutput', PulseObject.index, PulseObject.name, PulseObject.deviceIndex)
			for (var i = 0; i < filteredSourceModel.count; i++) {
				var source = filteredSourceModel.get(i);
				source = source.PulseObject;
				// console.log('\t', i, source, source.name, source.index)
				if (PulseObject.deviceIndex == source.index) {
					command = "python2 " + filename + " " + mixerItem.mixerItemType + " \"" + source.name + "\" " + PulseObject.index
					break;
				}
			}
		}

		// console.log("filename", filename)
		// console.log("command", command)
		return command
	}
}
