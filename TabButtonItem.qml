import QtQuick 2.15
import QtQuick.Controls 2.5

TabButton {
    text: qsTr("Untitled")
    width: 640 / 4
    property var newTabButton: nTabButton
    background: Rectangle {
        anchors.fill: parent
        color: titlebarColor
        border.color: color
    }

    Button {
        id: nTabButton
        width: parent.width / 8
        height: parent.height
        anchors.right: parent.right
        Text {
            anchors.centerIn: parent
            text: qsTr("+")
            color: "#E91E63"
            font.pixelSize: parent.font.pixelSize
        }

        background: Rectangle {
            anchors.fill: parent
            color: titlebarColor
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.2)
            radius: 2
        }
        onClicked: {
            newTabAction.trigger()
        }
    }

    onClicked: {
        getTextAreaItem(tabBar.currentIndex).textArea.forceActiveFocus()
    }
}
