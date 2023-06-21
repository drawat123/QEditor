import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
    property url filePath: ""
    property var textArea: editor
    property bool isModified: false
    property string savedText: ""
    ScrollView {
        anchors.fill: parent
        TextArea {
            id: editor
            font.pixelSize: 14
            focus: true
            selectionColor: textEditSelectionColor
            selectByMouse: true
            background: Rectangle {
                border.width: 0
            }
            onTextChanged: {
                if (filePath.toString().length == 0 && getTabItem(
                            tabBar.currentIndex).text.length < 20) {
                    let str = text.split('\n')[0].slice(0, 20)
                    if (str.length === 0)
                        str = "Untitled"

                    getTabItem(tabBar.currentIndex).text = str
                }
            }
        }
    }
}
