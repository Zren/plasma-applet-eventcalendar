import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
// import "../../code/utils.js" as Utils

ConfigPage {
    id: page

    property alias cfg_exampleBool: exampleBool.checked
    property alias cfg_exampleInt: exampleInt.value
    property alias cfg_exampleString: exampleString.text
    

    // Component.onCompleted: {
    //     cfg_exampleBool = true
    // }


    ConfigSection {
        label: i18n("SubHeading")

        CheckBox {
            id: exampleBool
            text: i18n("Boolean")
        }
        SpinBox {
            id: exampleInt
            suffix: i18n(" units")
        }

    }

    
    ConfigSection {
        label: i18n("SubHeading")

        // RowLayout { // Crashes plasmashell on close... WHAT?
        // ColumnLayout { // Crashes plasmashell on close... WHAT?
            Text {
                text: i18n("String")
            }
            TextField {
                // id: exampleString
                placeholderText: i18n("String")
            }
        // }
    }

    GroupBox {
        Layout.fillWidth: true

        ColumnLayout {
            id: content
            Layout.fillWidth: true

            Text {
                text: i18n("SubHeading")
                font.bold: true
            }

            RowLayout { // Does NOT crash plasmashell on close... WHAT? *headdesk*
                Text {
                    text: i18n("String")
                }
                TextField {
                    id: exampleString
                    placeholderText: i18n("String")
                }
            }
        }
    }
}
