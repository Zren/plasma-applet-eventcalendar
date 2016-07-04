import QtQuick 2.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaExtras.Heading {
    id: heading
    text: "Heading"
    level: 2
    color: palette.text
    // font.underline: true

    SystemPalette {
        id: palette
    }

    Rectangle {
        anchors.bottom: heading.bottom
        width: heading.parent.width
        height: 1
        color: heading.color
    }
}
