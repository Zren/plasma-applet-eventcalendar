
import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."

Item {
    id: generalPage

    implicitWidth: pageColumn.implicitWidth
    implicitHeight: pageColumn.implicitHeight

    property alias cfg_weather_app_id: weather_app_id.text
    property alias cfg_weather_city_id: weather_city_id.text
    property string cfg_weather_units: 'metric'
    

    SystemPalette {
        id: palette
    }

    Layout.fillWidth: true

    ColumnLayout {
        id: pageColumn
        Layout.fillWidth: true

        PlasmaExtras.Heading {
            level: 2
            text: i18n("OpenWeatherMap")
            color: palette.text
        }
        Item {
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            spacing: units.smallSpacing * 2
            Layout.fillWidth: true
            

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("API App Id:")
                }
                TextField {
                    id: weather_app_id
                    Layout.fillWidth: true
                }
            }

            LinkText {
                text: 'Get your city\'s id at <a href="https://openweathermap.org/">https://openweathermap.org/</a>,'
            }
            LinkText {
                text: 'or by searching google with `<a href="https://www.google.ca/search?q=site%3Aopenweathermap.org%2Fcity+toronto">site:openweathermap.org/city</a>`.'
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("City Id:")
                }
                TextField {
                    id: weather_city_id
                    Layout.fillWidth: true
                }
            }

            GroupBox {
                Layout.fillWidth: true

                RowLayout {
                    Label {
                        text: "Units:"
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    }
                    ColumnLayout {
                        ExclusiveGroup { id: weather_unitsGroup }
                        RadioButton {
                            text: "Celsius"
                            checked: cfg_weather_units == 'metric'
                            exclusiveGroup: weather_unitsGroup
                            onClicked: {
                                cfg_weather_units = 'metric'
                            }
                        }
                        RadioButton {
                            text: "Fahrenheit"
                            checked: cfg_weather_units == 'imperial'
                            exclusiveGroup: weather_unitsGroup
                            onClicked: {
                                cfg_weather_units = 'imperial'
                            }
                        }
                        RadioButton {
                            text: "Kelvin"
                            checked: cfg_weather_units == 'kelvin'
                            exclusiveGroup: weather_unitsGroup
                            onClicked: {
                                cfg_weather_units = 'kelvin'
                            }
                        }
                    }
                }
            }
        }



    }
}
