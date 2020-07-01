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
		configKey: 'weather_service'

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
				configKey: 'weather_app_id'
			}
		}

		RowLayout {
			visible: weatherService.value === 'OpenWeatherMap'
			Label {
				text: i18n("City Id:")
			}
			ConfigString {
				id: weatherCityId
				configKey: 'weather_city_id'
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
				configKey: 'weather_canada_city_id'
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
			// configKey: 'weatherPollinterval'
			before: i18n("Update forecast every: ")
			enabled: false
			value: 60
			suffix: i18ncp("Polling interval in minutes", "min", "min", value)
			minimumValue: 60
			maximumValue: 90
		}
	}

	HeaderText {
		text: i18n("Style")
	}

	ConfigSection {
		ConfigSpinBox {
			configKey: 'meteogram_hours'
			before: i18n("Show next ")
			suffix: i18np(" hours", " hours", value)
			after: i18n(" in the meteogram.")
			minimumValue: 9
			maximumValue: 48
			stepSize: 3
		}
	}

	ConfigSection {
		ConfigRadioButtonGroup {
			configKey: 'weather_units'
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
			configKey: 'meteogram_textColor'
			label: i18n("Text")
			defaultColor: config.meteogramTextColorDefault
		}
		ConfigColor {
			configKey: 'meteogram_gridColor'
			label: i18n("Grid")
			defaultColor: config.meteogramScaleColorDefault
		}
		ConfigColor {
			configKey: 'meteogram_rainColor'
			label: i18n("Rain")
			defaultColor: config.meteogramPrecipitationRawColorDefault
		}
		ConfigColor {
			configKey: 'meteogram_positiveTempColor'
			label: i18n("Positive Temp")
			defaultColor: config.meteogramPositiveTempColorDefault
		}
		ConfigColor {
			configKey: 'meteogram_negativeTempColor'
			label: i18n("Negative Temp")
			defaultColor: config.meteogramNegativeTempColorDefault
		}
		ConfigColor {
			configKey: 'meteogram_iconColor'
			label: i18n("Icons")
			defaultColor: config.meteogramIconColorDefault
		}
	}

}
