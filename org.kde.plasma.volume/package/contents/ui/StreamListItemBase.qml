/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.volume 0.1

ListItemBase {
    label: i18nc("label of stream items", "%1: %2", PulseObject.client.name, PulseObject.name)
    icon: {
        if (PulseObject.client.properties['application.icon_name']) {
            return PulseObject.client.properties['application.icon_name'].toLowerCase();
        } else if (PulseObject.client.properties['application.process.binary']) {
            if (PulseObject.client.properties['application.process.binary'].toLowerCase() === 'chrome') {
                return 'google-chrome';
            }
            return PulseObject.client.properties['application.process.binary'].toLowerCase();
        }
        return 'unknown';
    }
}
