import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ColumnLayout {
    id: page
    property bool showDebug: false

    SystemPalette {
        id: palette
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft


        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                Label {
                    text: "Click Date:"
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                }
                ColumnLayout {
                    ExclusiveGroup { id: agenda_date_clickGroup }
                    RadioButton {
                        text: "Open New Event In Browser"
                        exclusiveGroup: agenda_date_clickGroup
                        enabled: false
                    }
                    RadioButton {
                        text: "Open New Event Form"
                        exclusiveGroup: agenda_date_clickGroup
                        checked: true
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                Label {
                    text: "Click Event:"
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                }
                ColumnLayout {
                    ExclusiveGroup { id: agenda_event_clickGroup }
                    RadioButton {
                        text: "Open Event In Browser"
                        checked: true
                        exclusiveGroup: agenda_event_clickGroup
                    }
                }
            }
        }


    }
}