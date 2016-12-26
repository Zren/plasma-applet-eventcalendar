import QtQuick 2.0
import QtQuick.Controls 1.0

SpinBox {
	id: configCheckBox

	property string configKey: ''
	value: plasmoid.configuration[configKey]
	onValueChanged: plasmoid.configuration[configKey] = value
	maximumValue: 2147483647
}
