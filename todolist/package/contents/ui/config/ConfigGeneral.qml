import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import "../lib"

ConfigPage {
    id: page
    showAppletVersion: true

    ConfigSection {

        ConfigCheckBox {
            configKey: 'deleteOnComplete'
            text: i18n("Delete On Complete")
        }

    }
}
