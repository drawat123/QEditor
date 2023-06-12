import QtQuick 2.15
import QtQuick.Controls 2.5

TabButton {
    text: qsTr("Untitled")
    width: 640 / 4
    background: Rectangle {
        anchors.fill: parent
        color: titlebarColor
        border.color: color
    }

    onClicked: {
        getTextAreaItem(tabBar.currentIndex).textArea.forceActiveFocus()
    }
}
