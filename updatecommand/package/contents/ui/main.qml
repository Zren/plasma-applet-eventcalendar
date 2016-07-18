/***************************************************************************
 *   Copyright (C) 2014 by Aleix Pol Gonzalez <aleixpol@blue-systems.com>  *
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

import QtQuick 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.discovernotifier 1.0

Item {
    id: root

    Plasmoid.fullRepresentation: Full {}
    Plasmoid.icon: DiscoverNotifier.iconName
    Plasmoid.title: 'Updates'
    Plasmoid.toolTipSubText: DiscoverNotifier.message
    Plasmoid.status: {
        switch (DiscoverNotifier.state) {
        case DiscoverNotifier.NoUpdates:
            return PlasmaCore.Types.PassiveStatus;
        case DiscoverNotifier.NormalUpdates:
        case DiscoverNotifier.SecurityUpdates:
            return PlasmaCore.Types.ActiveStatus;
        }
    }


    PlasmaCore.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)
    }
    function exec(cmd) {
        executeSource.connectSource(cmd)
    }

    Component.onCompleted: {
        plasmoid.setAction("update", i18n("See Updates..."), "system-software-update");
    }

    function action_update() {
        exec('x-terminal-emulator -hold -e sh -c \'echo \"${PS1}apt list --upgradeable\";apt list --upgradeable;echo \"\\n${PS1}sudo apt upgrade\";sudo apt upgrade;echo \"\\n\\n[Update Finished] You may now close the terminal.\"\'')
    }
}
