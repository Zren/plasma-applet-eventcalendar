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


    GroupBox {
        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                text: i18n("SubHeading")
                font.bold: true
            }

            CheckBox {
                id: exampleBool
                text: i18n("Boolean")
            }
            SpinBox {
                id: exampleInt
                suffix: i18n(" units")
            }
        }
    }

    
    GroupBox {
        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                text: i18n("SubHeading")
                font.bold: true
            }

            RowLayout {
                Text {
                    text: i18n("test")
                }
                TextField {
                    id: exampleString
                    placeholderText: i18n("String")
                }
            }
        }
    }
}
