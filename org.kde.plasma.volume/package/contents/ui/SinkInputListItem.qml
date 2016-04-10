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

StreamListItemBase {
    // FIXME: all of this needs to be dependent on how many sinks we have...
    expanderIconVisible: false
    enabled: true
    subComponent: PlasmaComponents.ComboBox {
        model: SinkModel {}
        textRole: 'Description'
        onModelChanged: updateIndex()
        onCountChanged: updateIndex()
        onActivated: {
            if (index === -1) {
                // Current index doesn't map to anything. Oh the agony.
                return;
            }
            PulseObject.sinkIndex = modelIndexToSinkIndex(index)
        }

        function updateIndex() {
            currentIndex = sinkIndexToModelIndex(SinkIndex);
        }

        function sinkIndexToModelIndex(sinkIndex) {
            textRole = 'Index';
            var searchString = '';
            if (sinkIndex !== 0) {
                // The stringy representation of 0 is '' oddly enough.
                searchString = '' + sinkIndex;
            }
            var modelIndex = find(searchString);
            textRole = 'Description';
            return modelIndex;
        }

        function modelIndexToSinkIndex(modelIndex) {
            textRole = 'Index';
            var sinkIndex = Number(textAt(modelIndex));
            textRole = 'Description';
            return sinkIndex;
        }

        Component.onCompleted: updateIndex();
    }
}
