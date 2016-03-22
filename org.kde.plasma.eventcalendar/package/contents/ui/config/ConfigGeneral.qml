
import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: generalPage

    implicitWidth: pageColumn.implicitWidth
    implicitHeight: pageColumn.implicitHeight

    property alias cfg_timer_repeats: timer_repeats.checked
    property alias cfg_timer_in_taskbar: timer_in_taskbar.checked
    property alias cfg_timer_ends_at: timer_ends_at.text

    property bool showDebug: false

    SystemPalette {
        id: palette
    }

    Layout.fillWidth: true

    ColumnLayout {
        id: pageColumn
        Layout.fillWidth: true

        RowLayout {
            visible: showDebug
            Layout.fillWidth: true
            Label {
                text: i18n("timer_repeats:")
            }
            PlasmaComponents.Switch {
                id: timer_repeats
                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: showDebug
            Layout.fillWidth: true
            Label {
                text: i18n("timer_in_taskbar:")
            }
            PlasmaComponents.Switch {
                id: timer_in_taskbar
                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: showDebug
            Layout.fillWidth: true
            Label {
                text: i18n("timer_ends_at:")
            }
            TextField {
                id: timer_ends_at
                Layout.fillWidth: true
            }
        }
    }
}