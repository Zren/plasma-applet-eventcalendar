import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."
import "../lib"

ConfigPage {
    id: page

    Base64JsonListModel {
        id: calendarsModel
        configKey: 'icalCalendarList'

        function addCalendar() {
            addItem({
                url: '',
                name: 'Label',
                backgroundColor: '' + theme.highlightColor,
                show: true,
                isReadOnly: true,
            });
        }
    }

    RowLayout {
        HeaderText {
            text: i18n("Calendars")
        }
        Button {
            iconName: "resource-calendar-insert"
            text: i18n("Add Calendar")
            onClicked: calendarsModel.addCalendar()
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 20 * units.devicePixelRatio // double the default 10

        Repeater {
            model: calendarsModel
            delegate: RowLayout {
                spacing: 0

                CheckBox {
                    Layout.preferredHeight: labelTextField.height
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignTop
                    checked: show
                    style: CheckBoxStyle {}

                    onClicked: {
                        calendarsModel.setProperty(index, 'show', checked)
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Rectangle {
                            Layout.preferredHeight: labelTextField.height
                            Layout.preferredWidth: height
                            color: model.backgroundColor
                        }
                        TextField {
                            id: labelTextField
                            Layout.fillWidth: true
                            text: model.name
                            placeholderText: i18n("Calendar Label")
                        }
                        Button {
                            iconName: "trash-empty"
                            onClicked: calendarsModel.removeIndex(index)
                        }
                    }
                    RowLayout {
                        TextField {
                            Layout.fillWidth: true
                            text: model.url
                        }

                        Button {
                            iconName: "folder-open"
                        }
                    }
                }
            }
        }
    }
}
