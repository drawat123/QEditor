import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: appWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("QEditor")
    property color titlebarColor: Qt.rgba(242 / 255, 243 / 255, 249 / 255, 1)
    property color tabBarColor: Qt.rgba(128 / 255, 128 / 255, 128 / 255, 0.5)
    property color textEditSelectionColor: Qt.rgba(0 / 255, 120 / 255,
                                                   215 / 255, 1)
    property int tabBoderWidth: 4
    property var textAreaItemIndexes: []
    property bool messageDialogYesClicked: false
    property var textAreaSelectedIdx: []

    function actionText(firstText, secondText) {
        let str = firstText + textFileOperations.spacesBetweenTexts(
                firstText, secondText, fileMenu.font,
                fileMenu.width) + secondText
        return str
    }

    function getTabItem(idx) {
        return tabBar.itemAt(idx)
    }
    function getTextAreaItem(idx) {
        return stackLayout.itemAt(idx)
    }

    function textFileRead(filePath) {
        if (filePath.toString().length > 0) {
            let textAreaItem = getTextAreaItem(textAreaItemIndexes[0])

            textAreaItem.filePath = filePath
            textAreaItem.textArea.text = textFileOperations.readFile(
                        textAreaItem.filePath)
            textAreaItem.savedText = textAreaItem.textArea.text

            getTabItem(textAreaItemIndexes[0]).text = textAreaItem.filePath.toString(
                        ).replace(/^.*[\\\/]/, '')
        } else {
            fileDialog.selectExisting = true
            fileDialog.open()
        }
    }

    function textFileSave(filePath) {
        if (filePath.toString().length > 0) {
            let textAreaItem = getTextAreaItem(textAreaItemIndexes[0])

            textAreaItem.filePath = filePath
            textFileOperations.saveFile(textAreaItem.filePath,
                                        textAreaItem.textArea.text)

            getTabItem(textAreaItemIndexes[0]).text = textAreaItem.filePath.toString(
                        ).replace(/^.*[\\\/]/, '')

            if (messageDialogYesClicked) {
                messageDialogYesClicked = false
                closeTab()
            } else {
                textAreaItem.savedText = textAreaItem.textArea.text
                textAreaItemIndexes.shift()
                textFilesSave()
            }
        } else {
            fileDialog.selectExisting = false
            fileDialog.open()
        }
    }
    function textFilesSave() {
        if (textAreaItemIndexes.length < 1)
            return

        textFileSave(getTextAreaItem(textAreaItemIndexes[0]).filePath)
    }

    function closeTab() {
        getTextAreaItem(textAreaItemIndexes[0]).destroy()
        tabBar.removeItem(textAreaItemIndexes[0])

        if (tabBar.count == 0)
            Qt.quit()
        else {
            getTabItem(tabBar.count - 1).newTabButton.visible = true
            getTextAreaItem(tabBar.currentIndex).textArea.forceActiveFocus()
        }

        textAreaItemIndexes.shift()
        closeTabs()
    }
    function closeTabs() {
        if (textAreaItemIndexes.length < 1)
            return

        let textAreaItem = getTextAreaItem(textAreaItemIndexes[0])
        if (textAreaItem.isModified) {
            messageDialog.text = "Do you want to save changes to " + getTabItem(
                        textAreaItemIndexes[0]).text + (textAreaItem.filePath.toString(
                                                            ).length === 0 ? ".txt" : "") + "?"
            messageDialog.standardButtons = StandardButton.Yes
                    | StandardButton.No | StandardButton.Cancel
            messageDialog.open()
        } else
            closeTab()
    }

    function menuItemAboutToShow() {
        let textArea = getTextAreaItem(tabBar.currentIndex).textArea
        textAreaSelectedIdx = textArea.selectedText.length
                > 0 ? [textArea.selectionStart, textArea.selectionEnd] : []
    }
    function menuItemOpened() {
        if (textAreaSelectedIdx.length === 2)
            getTextAreaItem(tabBar.currentIndex).textArea.select(
                        textAreaSelectedIdx[0], textAreaSelectedIdx[1])
    }

    function findNext(selectText = true) {
        let searchText = searchItem.matchCase ? searchField.text : searchField.text.toLowerCase()
        if (searchText !== "") {
            let textArea = getTextAreaItem(
                    tabBar.currentIndex).textArea, searchIndex = textArea.selectionEnd

            let textAreaText = searchItem.matchCase ? textArea.text : textArea.text.toLowerCase()
            searchIndex = textAreaText.indexOf(searchText, searchIndex)
            searchIndex = searchIndex !== -1 ? searchIndex : textAreaText.indexOf(
                                                   searchText, -1)

            if (searchIndex !== -1 && selectText)
                textArea.select(searchIndex, searchIndex + searchText.length)
            else if (searchIndex === -1) {
                messageDialog.text = "Cannot find " + "\"" + searchText + "\""
                messageDialog.standardButtons = StandardButton.Ok
                messageDialog.open()
            }
            return searchIndex !== -1
        }
        return false
    }
    function replaceText() {
        let textArea = getTextAreaItem(tabBar.currentIndex).textArea

        let searchText = searchItem.matchCase ? searchField.text : searchField.text.toLowerCase()
        let selText = searchItem.matchCase ? textArea.selectedText : textArea.selectedText.toLowerCase()

        if (searchText !== "" && (searchText === selText
                                  || findNext())) {
            textArea.text = textArea.text.substring(
                        0,
                        textArea.selectionStart) + replaceField.text + textArea.text.substring(
                        textArea.selectionEnd)
            findNext()
        }
    }
    function replaceAll() {
        let textArea = getTextAreaItem(tabBar.currentIndex).textArea

        let searchText = searchItem.matchCase ? searchField.text : searchField.text.toLowerCase()
        let selText = searchItem.matchCase ? textArea.selectedText : textArea.selectedText.toLowerCase()

        if (searchText !== "" && (searchText === selText
                                  || findNext(false))) {
            textArea.text = searchItem.matchCase ? textArea.text.replace(new RegExp(searchText, "g"), replaceField.text) :
                                                   textArea.text.replace(new RegExp(searchText, "gi"), replaceField.text)
        }
    }

    Component.onCompleted: {
        getTextAreaItem(tabBar.currentIndex).textArea.forceActiveFocus()
        getTabItem(tabBar.currentIndex).background.border.width = tabBoderWidth
    }

    menuBar: MenuBar {
        background: Rectangle {
            anchors.fill: parent
            color: titlebarColor
        }
        Menu {
            id: fileMenu
            title: qsTr("File")
            onAboutToShow: menuItemAboutToShow()
            onOpened: menuItemOpened()
            Action {
                id: newTabAction
                text: actionText("New Tab", "Ctrl+N")
                shortcut: "Ctrl+N"
                onTriggered: {
                    let success = false
                    let component = Qt.createComponent("TabButtonItem.qml")
                    if (component.status === Component.Ready
                            && component.createObject(tabBar) !== null) {
                        success = true
                    }
                    if (!success) {
                        console.log("Error creating tab button")
                        return
                    }

                    success = false
                    component = Qt.createComponent("TextAreaItem.qml")
                    if (component.status === Component.Ready
                            && component.createObject(stackLayout) !== null) {
                        success = true
                    }
                    if (!success) {
                        console.log("Error creating text area")
                        return
                    }

                    getTabItem(tabBar.count - 2).newTabButton.visible = false
                    tabBar.setCurrentIndex(tabBar.count - 1)
                    getTabItem(tabBar.count - 1).newTabButton.visible = true

                    getTextAreaItem(
                                tabBar.currentIndex).textArea.forceActiveFocus()
                }
            }
            Action {
                text: actionText("Switch Tab", "Ctrl+Tab")
                shortcut: "Ctrl+Tab"
                onTriggered: {
                    if (tabBar.currentIndex < tabBar.count - 1)
                        tabBar.incrementCurrentIndex()
                    else
                        tabBar.setCurrentIndex(0)

                    getTextAreaItem(
                                tabBar.currentIndex).textArea.forceActiveFocus()
                }
            }
            Action {
                text: actionText("Open", "Ctrl+O")
                shortcut: "Ctrl+O"
                onTriggered: {
                    fileDialog.title = "Open"

                    textAreaItemIndexes = []
                    textAreaItemIndexes.push(tabBar.currentIndex)

                    textFileRead("")
                }
            }
            Action {
                text: actionText("Save", "Ctrl+S")
                shortcut: "Ctrl+S"
                onTriggered: {
                    fileDialog.title = "Save"

                    textAreaItemIndexes = []
                    textAreaItemIndexes.push(tabBar.currentIndex)

                    textFilesSave()
                }
            }
            Action {
                text: actionText("Save As", "Ctrl+Shift+S")
                shortcut: "Ctrl+Shift+S"
                onTriggered: {
                    fileDialog.title = "Save As"

                    textAreaItemIndexes = []
                    textAreaItemIndexes.push(tabBar.currentIndex)

                    textFileSave("")
                }
            }
            Action {
                text: qsTr("Save All")
                onTriggered: {
                    fileDialog.title = "Save"

                    textAreaItemIndexes = []
                    for (var i = 0; i < tabBar.count; i++)
                        textAreaItemIndexes.push(i)

                    textFilesSave()
                }
            }
            MenuSeparator {}
            Action {
                text: actionText("Close Tab", "Ctrl+W")
                shortcut: "Ctrl+W"
                onTriggered: {
                    fileDialog.title = "Save"

                    textAreaItemIndexes = []
                    textAreaItemIndexes.push(tabBar.currentIndex)

                    let textAreaItem = getTextAreaItem(tabBar.currentIndex)
                    if (textAreaItem.filePath.toString().length > 0) {
                        if (textAreaItem.savedText !== textAreaItem.textArea.text)
                            textAreaItem.isModified = true
                        else
                            textAreaItem.isModified = false
                    } else {
                        if (textAreaItem.textArea.text.length > 0)
                            textAreaItem.isModified = true
                        else
                            textAreaItem.isModified = false
                    }

                    closeTabs()
                }
            }
            Action {
                id: exitAction
                text: qsTr("Exit")
                shortcut: "Ctrl+E"
                onTriggered: {
                    fileDialog.title = "Save"

                    textAreaItemIndexes = []
                    for (var i = tabBar.count - 1; i >= 0; i--) {
                        textAreaItemIndexes.push(i)

                        let textAreaItem = getTextAreaItem(i)
                        if (textAreaItem.filePath.toString().length > 0) {
                            if (textAreaItem.savedText !== textAreaItem.textArea.text)
                                textAreaItem.isModified = true
                            else
                                textAreaItem.isModified = false
                        } else {
                            if (textAreaItem.textArea.text.length > 0)
                                textAreaItem.isModified = true
                            else
                                textAreaItem.isModified = false
                        }
                    }

                    tabBar.setCurrentIndex(textAreaItemIndexes[0])
                    getTextAreaItem(
                                textAreaItemIndexes[0]).textArea.forceActiveFocus()

                    closeTabs()
                }
            }
        }
        Menu {
            id: editMenu
            title: qsTr("Edit")
            onAboutToShow: menuItemAboutToShow()
            onOpened: menuItemOpened()
            Action {
                text: actionText("Undo", "Ctrl+Z")
                shortcut: "Ctrl+Z"
                onTriggered: {
                    getTextAreaItem(tabBar.currentIndex).textArea.undo()
                }
            }
            MenuSeparator {}
            Action {
                text: actionText("Cut", "Ctrl+X")
                shortcut: "Ctrl+X"
                onTriggered: {
                    getTextAreaItem(tabBar.currentIndex).textArea.cut()
                }
            }
            Action {
                text: actionText("Copy", "Ctrl+C")
                shortcut: "Ctrl+C"
                onTriggered: {
                    getTextAreaItem(tabBar.currentIndex).textArea.copy()
                }
            }
            Action {
                text: actionText("Paste", "Ctrl+V")
                shortcut: "Ctrl+V"
                onTriggered: {
                    getTextAreaItem(tabBar.currentIndex).textArea.paste()
                }
            }
            MenuSeparator {}
            Action {
                text: actionText("Find", "Ctrl+F")
                shortcut: "Ctrl+F"
                onTriggered: {
                    if (getTextAreaItem(
                                tabBar.currentIndex).textArea.text.length) {
                        findAndReplacePopup.height = findAndReplacePopup.originalHeight / 2
                        replaceItem.visible = false
                        findAndReplacePopup.open()
                    }
                }
            }
            Action {
                text: actionText("Replace", "Ctrl+H")
                shortcut: "Ctrl+H"
                onTriggered: {
                    if (getTextAreaItem(
                                tabBar.currentIndex).textArea.text.length) {
                        findAndReplacePopup.height = findAndReplacePopup.originalHeight
                        replaceItem.visible = true
                        findAndReplacePopup.open()
                    }
                }
            }
        }
        Menu {
            id: viewMenu
            title: qsTr("View")
            onAboutToShow: menuItemAboutToShow()
            onOpened: menuItemOpened()
            Action {
                text: actionText("Zoom in", "Ctrl+Plus")
                shortcut: "Ctrl++"
                onTriggered: {
                    getTextAreaItem(
                                tabBar.currentIndex).textArea.font.pixelSize += 2
                }
            }
            Action {
                text: actionText("Zoom out", "Ctrl+Minus")
                shortcut: "Ctrl+-"
                onTriggered: {
                    getTextAreaItem(
                                tabBar.currentIndex).textArea.font.pixelSize -= 2
                }
            }
            Action {
                text: actionText("Word wrap", getTextAreaItem(
                                     tabBar.currentIndex) && getTextAreaItem(
                                     tabBar.currentIndex).textArea.wrapMode
                                 === TextEdit.WrapAnywhere ? "\u2714" : "")
                onTriggered: {
                    let textArea = getTextAreaItem(tabBar.currentIndex).textArea
                    if (textArea.wrapMode === TextEdit.WrapAnywhere)
                        textArea.wrapMode = TextEdit.NoWrap
                    else {
                        textArea.width = appWindow.width
                        textArea.wrapMode = TextEdit.WrapAnywhere
                    }
                }
            }
        }
    }

    Page {
        anchors.fill: parent
        header: TabBar {
            id: tabBar
            width: parent.width
            background: Rectangle {
                anchors.fill: parent
                color: tabBarColor
            }
            property int prevIdx: 0
            TabButtonItem {}
            onCurrentIndexChanged: {
                if (currentIndex != -1 && getTabItem(prevIdx)) {
                    getTabItem(prevIdx).background.border.width = 0
                    prevIdx = currentIndex
                    getTabItem(currentIndex).background.border.width = tabBoderWidth
                }
            }
        }

        StackLayout {
            id: stackLayout
            width: parent.width
            height: parent.height
            currentIndex: tabBar.currentIndex
            TextAreaItem {}
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["Text Documents (*.txt)", "All files (*)"]
        folder: shortcuts.home + "/Downloads"
        selectMultiple: false
        onAccepted: {
            if (selectExisting)
                textFileRead(fileDialog.fileUrl)
            else
                textFileSave(fileDialog.fileUrl)
        }
        onRejected: {

        }
    }

    MessageDialog {
        id: messageDialog
        title: "QEditor"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onYes: {
            messageDialogYesClicked = true
            textFilesSave()
        }
        onNo: {
            closeTab()
        }
        onRejected: {

        }
    }

    Popup {
        id: findAndReplacePopup
        x: parent.width / 2 - width / 2
        width: 600
        height: 80
        modal: true
        focus: true
        property int originalHeight: 80
        contentItem: Rectangle {
            anchors.fill: parent
            radius: 5
            color: "lightgray"

            Item {
                id: searchItem
                width: parent.width
                height: findAndReplacePopup.originalHeight / 2
                property bool matchCase: false
                TextField {
                    id: searchField
                    placeholderText: "Find"
                    width: parent.width * 0.60
                    height: parent.height
                    selectByMouse: true
                    Keys.onReturnPressed: findNext()
                }
                Button {
                    id: searchButton
                    text: "Find"
                    width: parent.width * 0.20
                    height: parent.height
                    anchors.left: searchField.right
                    onClicked: findNext()
                }
                RoundButton {
                    id: matchCaseButton
                    text: "Match Case"
                    anchors.left: searchButton.right
                    width: searchButton.width
                    height: searchButton.height
                    onClicked: {
                        searchItem.matchCase = !searchItem.matchCase
                        text = searchItem.matchCase ? "Match Case\u2713" : "Match Case"
                    }
                }
            }
            Item {
                id: replaceItem
                anchors.top: searchItem.bottom
                width: searchItem.width
                height: searchItem.height
                TextField {
                    id: replaceField
                    placeholderText: "Replace"
                    width: parent.width * 0.60
                    height: searchField.height
                    selectByMouse: true
                    Keys.onReturnPressed: replaceText()
                }
                Button {
                    id: replaceButton
                    text: "Replace"
                    anchors.left: replaceField.right
                    width: searchButton.width
                    height: searchButton.height
                    onClicked: replaceText()
                }
                Button {
                    id: replaceAllButton
                    text: "Replace All"
                    anchors.left: replaceButton.right
                    width: searchButton.width
                    height: searchButton.height
                    onClicked: replaceAll()
                }
            }
        }

        onAboutToShow: {
            menuItemAboutToShow()
            searchField.text = getTextAreaItem(
                        tabBar.currentIndex).textArea.selectedText
            replaceField.text = ""
        }
        onOpened: {
            menuItemOpened()
            searchField.forceActiveFocus()
        }

        closePolicy: Popup.CloseOnEscape
    }

    onClosing: {
        findAndReplacePopup.close()
        exitAction.trigger()
        close.accepted = false
    }
}
