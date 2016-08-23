import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ComboBox {
    id: comboBox
    Layout.fillWidth: true
    property string value: ''

    onCurrentIndexChanged: {
        var current = model[currentIndex]
        if (current) {
            value = getValue(current)
        }
    }

    onModelChanged: updateCurrentIndex()
    onValueChanged: updateCurrentIndex()

    function updateCurrentIndex() {
        if (value && typeof model !== 'number') {
            for (var i = 0, j = sizeOf(comboBox.model); i < j; ++i) {
                if (getValue(comboBox.model[i]) == value) {
                    comboBox.currentIndex = i
                    break;
                }
            }
        }
    }

    function getValue(obj) {
        if (obj && typeof obj.value !== 'undefined') {
            return obj.value;
        } else {
            return obj;
        }
    }

    function sizeOf(arr) {
        return arr.length || arr.count;
    }

}