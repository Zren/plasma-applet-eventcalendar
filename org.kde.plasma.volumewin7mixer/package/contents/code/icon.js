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

function name(volume, muted, prefix) {
    if (!prefix) {
        prefix = "audio-volume";
    }
    // FIXME: hardcoded max value
    var split_base = 65536/3.0;
    var icon = null;
    if ((volume / split_base <= 0) || muted) {
        icon = prefix + "-muted";
    } else if (volume / split_base <= 1) {
        icon = prefix + "-low";
    } else if (volume / split_base <= 2) {
        icon = prefix + "-medium";
    } else {
        icon = prefix + "-high";
    }
    return icon;
}
