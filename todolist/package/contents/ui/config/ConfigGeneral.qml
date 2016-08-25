import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
// import "../../code/utils.js" as Utils

ConfigPage {
    id: page

    property alias cfg_showCompletedItems: showCompletedItems.checked
    
    ConfigSection {
        label: i18n("Options")

        CheckBox {
            id: showCompletedItems
            text: i18n("Show Completed Items")
        }

    }
}
