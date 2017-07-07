import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."
import "../lib"

ConfigPage {
    id: page

    property alias cfg_weather_service: cfg_weather_serviceComboBox.value
    property alias cfg_weather_app_id: weather_app_id.text // OpenWeatherMap
    property alias cfg_weather_city_id: weather_city_id.text // OpenWeatherMap
    property alias cfg_weather_canada_city_id: weather_canada_city_id.text // WeatherCanada
    
    property string cfg_weather_units: 'metric'
    property alias cfg_events_pollinterval: weather_pollinterval.value // TODO
    property alias cfg_meteogram_hours: meteogram_hours.value


    HeaderText {
        text: i18n("Data")
    }

    ComboBoxProperty {
        id: cfg_weather_serviceComboBox
        enabled: false
        model: [
            'OpenWeatherMap',
            'WeatherCanada',
        ]
        value: 'OpenWeatherMap'
    }

    ConfigSection {
        RowLayout {
            visible: plasmoid.configuration.debugging && page.cfg_weather_service === 'OpenWeatherMap'
            Layout.fillWidth: true
            Label {
                text: i18n("API App Id:")
            }
            TextField {
                id: weather_app_id
                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: page.cfg_weather_service === 'OpenWeatherMap'
            Layout.fillWidth: true
            Label {
                text: i18n("City Id:")
            }
            TextField {
                id: weather_city_id
                Layout.fillWidth: true
                placeholderText: i18n("Eg: 5983720")
            }
            Button {
                text: i18n("Find City")
                onClicked: openWeatherMapCityDialog.open()
            }

            OpenWeatherMapCityDialog {
                id: openWeatherMapCityDialog
                onAccepted: {
                    page.cfg_weather_city_id = selectedCityId
                }
            }
        }

        RowLayout {
            visible: page.cfg_weather_service === 'WeatherCanada'
            Layout.fillWidth: true
            Label {
                text: i18n("City Id:")
            }
            TextField {
                id: weather_canada_city_id
                Layout.fillWidth: true
                placeholderText: i18n("Eg: on-14")
            }
            Button {
                text: i18n("Find City")
                onClicked: weatherCanadaCityDialog.open()
            }

            WeatherCanadaCityDialog {
                id: weatherCanadaCityDialog
                onAccepted: {
                    page.cfg_weather_canada_city_id = selectedCityId
                }
            }
        }
    }

    HeaderText {
        text: i18n("Settings")
    }

    ConfigSection {
        RowLayout {
            Label {
                text: i18n("Update forecast every: ")
            }
            
            SpinBox {
                id: weather_pollinterval
                enabled: false
                
                suffix: i18ncp("Polling interval in minutes", "min", "min", value)
                minimumValue: 60
                maximumValue: 90
            }
        }
    }

    HeaderText {
        text: i18n("Style")
    }

    ConfigSection {
        RowLayout {
            Label {
                text: i18n("Show next ")
            }
            
            SpinBox {
                id: meteogram_hours
                enabled: true
                
                suffix: i18np(" hours", " hours", value)
                minimumValue: 9
                maximumValue: 48
                stepSize: 3
            }

            Label {
                text: i18n(" in the meteogram.")
            }
        }
    }

    ConfigSection {
        LabeledRowLayout {
            label: i18n("Units:")
            ExclusiveGroup { id: weather_unitsGroup }
            RadioButton {
                text: i18n("Celsius")
                checked: cfg_weather_units == 'metric'
                exclusiveGroup: weather_unitsGroup
                onClicked: {
                    cfg_weather_units = 'metric'
                }
            }
            RadioButton {
                text: i18n("Fahrenheit")
                checked: cfg_weather_units == 'imperial'
                exclusiveGroup: weather_unitsGroup
                onClicked: {
                    cfg_weather_units = 'imperial'
                }
            }
            RadioButton {
                text: i18n("Kelvin")
                checked: cfg_weather_units == 'kelvin'
                exclusiveGroup: weather_unitsGroup
                onClicked: {
                    cfg_weather_units = 'kelvin'
                }
            }
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
