import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."
import "../lib"

ConfigPage {
	id: page

	HeaderText {
		text: i18n("Data")
	}

	ConfigComboBox {
		id: weatherService
		configKey: 'weatherService'

		model: [
			{ value: 'OpenWeatherMap', text: 'OpenWeatherMap' },
			{ value: 'WeatherCanada', text: 'WeatherCanada' },
		]
	}

	ConfigSection {
		RowLayout {
			visible: plasmoid.configuration.debugging && weatherService.value === 'OpenWeatherMap'
			Label {
				text: i18n("API App Id:")
			}
			ConfigString {
				configKey: 'openWeatherMapAppId'
			}
		}

		RowLayout {
			visible: weatherService.value === 'OpenWeatherMap'
			Label {
				text: i18n("City Id:")
			}
			ConfigString {
				id: weatherCityId
				configKey: 'openWeatherMapCityId'
				placeholderText: i18n("Eg: 5983720")
			}
			Button {
				text: i18n("Find City")
				onClicked: openWeatherMapCityDialog.open()
			}

			OpenWeatherMapCityDialog {
				id: openWeatherMapCityDialog
				onAccepted: {
					weatherCityId.value = selectedCityId
				}
			}
		}

		RowLayout {
			visible: weatherService.value === 'WeatherCanada'
			Label {
				text: i18n("City Id:")
			}
			ConfigString {
				id: weatherCanadaCityId
				configKey: 'weatherCanadaCityId'
				placeholderText: i18n("Eg: on-14")
			}
			Button {
				text: i18n("Find City")
				onClicked: weatherCanadaCityDialog.open()
			}

			WeatherCanadaCityDialog {
				id: weatherCanadaCityDialog
				onAccepted: {
					weatherCanadaCityId.value = selectedCityId
				}
			}
		}
	}

	HeaderText {
		text: i18n("Settings")
	}

	ConfigSection {
		ConfigSpinBox {
			// configKey: 'weatherPollInterval'
			before: i18n("Update forecast every: ")
			enabled: false
			value: 60
			suffix: i18nc("Polling interval in minutes", "min")
			minimumValue: 60
			maximumValue: 90
		}
	}

	HeaderText {
		text: i18n("Style")
	}

	ConfigSection {
		ConfigSpinBox {
			configKey: 'meteogramHours'
			before: i18n("Show next ")
			suffix: i18np(" hour", " hours", value)
			after: i18n(" in the meteogram.")
			minimumValue: 9
			maximumValue: 48
			stepSize: 3
		}
	}

	ConfigSection {
		ConfigRadioButtonGroup {
			configKey: 'weatherUnits'
			label: i18n("Units:")
			model: [
				{ value: 'metric', text: i18n("Celsius") },
				{ value: 'imperial', text: i18n("Fahrenheit") },
				{ value: 'kelvin', text: i18n("Kelvin") },
			]
		}
	}

	HeaderText {
		text: i18n("Colors")
	}

	AppletConfig { id: config }
	ColorGrid {
		ConfigColor {
			configKey: 'meteogramTextColor'
			label: i18n("Text")
			defaultColor: config.meteogramTextColorDefault
		}
		ConfigColor {
			configKey: 'meteogramGridColor'
			label: i18n("Grid")
			defaultColor: config.meteogramScaleColorDefault
		}
		ConfigColor {
			configKey: 'meteogramRainColor'
			label: i18n("Rain")
			defaultColor: config.meteogramPrecipitationRawColorDefault
		}
		ConfigColor {
			configKey: 'meteogramPositiveTempColor'
			label: i18n("Positive Temp")
			defaultColor: config.meteogramPositiveTempColorDefault
		}
		ConfigColor {
			configKey: 'meteogramNegativeTempColor'
			label: i18n("Negative Temp")
			defaultColor: config.meteogramNegativeTempColorDefault
		}
		ConfigColor {
			configKey: 'meteogramIconColor'
			label: i18n("Icons")
			defaultColor: config.meteogramIconColorDefault
		}
	}

}
