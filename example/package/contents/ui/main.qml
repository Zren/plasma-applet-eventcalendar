/***************************************************************************
 *   Copyright (C) 2012-2013 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

// import "../code/utils.js" as Utils

Item {
    id: main

    Layout.minimumWidth: units.gridUnit * 1
    Layout.minimumHeight: units.gridUnit * 1
    Layout.preferredWidth: units.gridUnit * 10
    Layout.preferredHeight: units.gridUnit * 10
    Layout.maximumWidth: plasmoid.screenGeometry.width
    Layout.maximumHeight: plasmoid.screenGeometry.height

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    PlasmaCore.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: {
            disconnectSource(sourceName)
        }
    }
    function exec(cmd) {
        executeSource.connectSource(cmd)
    }

    function action_openTaskManager() {
        exec("ksysguard");
    }

    Component.onCompleted: {
        plasmoid.setAction("openTaskManager", i18n("Start Task Manager"), "utilities-system-monitor");
    }
}
