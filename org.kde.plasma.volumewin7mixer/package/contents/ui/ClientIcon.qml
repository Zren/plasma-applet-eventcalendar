/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

import org.kde.kquickcontrolsaddons 2.0

QIconItem {
    property QtObject client

    icon: {
        // Virtual streams don't have a valid client object, force a default icon for them
        if (client) {
            if (client.properties['application.icon_name']) {
                return client.properties['application.icon_name'].toLowerCase();
            } else if (client.properties['application.process.binary']) {
                var binary = client.properties['application.process.binary'].toLowerCase()
                // FIXME: I think this should do a reverse-desktop-file lookup
                // or maybe appdata could be used?
                // At any rate we need to attempt mapping binary to desktop file
                // such that we could get the icon.
                if (binary === 'chrome' || binary === 'chromium') {
                    return 'google-chrome';
                }
                return binary;
            }
            return 'unknown';
        } else {
            return 'audio-card';
        }
    }
}
