
import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: generalPage

    implicitWidth: pageColumn.implicitWidth
    implicitHeight: pageColumn.implicitHeight

    property alias cfg_weather_app_id2: weather_app_id2.text
    property alias cfg_weather_city_id2: weather_city_id2.text

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
                    id: weather_app_id2
                    Layout.fillWidth: true
                }
            }

            Text {
                text: 'Get your city\'s id at <a href="https://openweathermap.org/">https://openweathermap.org/</a>'
                // linkColor: "#369"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("City Id:")
                }
                TextField {
                    id: weather_city_id2
                    Layout.fillWidth: true
                }
            }
        }



    }
}