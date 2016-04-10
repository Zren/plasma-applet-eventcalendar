#! /usr/bin/env bash
$XGETTEXT `find . -name \*.js -o -name \*.qml` -o $podir/plasma_applet_org.kde.plasma.volume.pot
rm -f rc.cpp
