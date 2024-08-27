import QtQuick
import QtQuick.Controls 6.7
import QtQuick.Layouts 1.15

Popup {
    id: recentFilesPopup
    width: 400
    height: recentFilesListView.contentHeight + 15
    modal: true
    focus: true
    background: Rectangle {
        width: parent.width
        height: parent.height
        radius: 10
        color: "#f2f2f2"
        opacity: 1
        anchors.centerIn: parent
    }
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 300
                easing.type: Easing.InQuad
            }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.8
                duration: 300
                easing.type: Easing.InQuad
            }
        }
    } 
    onOpened: {
        updateModel()
        recentFilesPopup.width = parent ? parent.width / 2 : 400;
    }
    property ListModel recentFilesModel: ListModel { }

    ListView {
        id: recentFilesListView
        width: parent ? parent.width : 400
        height: parent ? (parent.height) : 250
        anchors.horizontalCenter: parent.horizontalCenter
        model: recentFilesModel
        clip: true

        delegate: Rectangle {
            width: recentFilesListView.width
            height: 50
            color: mouseAreaElement.containsMouse ? "#dddddd" : "#f9f9f9"
            border.color: "#dddddd"

            GridLayout {
               columns: 3
               anchors.fill: parent
               anchors.verticalCenter: parent.verticalCenter
               anchors.margins: 10

                Image {
                    id: videoPlayerIcon
                    Layout.row: 0
                    Layout.column: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.10
                    source: model.thumbnailPath
                    fillMode: Image.PreserveAspectFit
                    visible: true
                }

                Text {
                    Layout.row: 0
                    Layout.column: 1
                    text: getFileName(model.filePath)
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width * 0.55
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.row: 0
                    Layout.column: 2
                    text: model.timestamp.toString("yyyy-mm-dd HH:mm:ss")
                    font.pixelSize: 11
                    color: "#737373"
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width * 0.35
                    horizontalAlignment: Text.AlignLeft
                }
            }
            MouseArea {
                id: mouseAreaElement
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    recentFilesPopup.onFileSelected(model.filePath, model.timestamp)
                    recentFilesPopup.close()
                }
            }
        }
    }
    signal fileSelected(string filePath)

    function onFileSelected(filePath) {
        fileSelected(filePath)
    }

    function getFileName(filePath) {
        var path = filePath.toString();
        var pathSegments = path.split('/');
        return pathSegments.pop();
    }

    function updateModel() {
        recentFilesModel.clear()
        var files = recentFiles.getRecentFiles() // The time is stored in CET(Central European Time).

        // Note: The time is automatically converted to UTC(Coordinated Universal Time) when passed to QML, so we need to convert it back to CET when displaying on the List View.

        var sortedFiles = []
        for (var key in files) {
            var fileInfo = files[key]
            sortedFiles.push([key, new Date(fileInfo.timestamp), fileInfo.thumbnailPath])
        }

        sortedFiles.sort(function(a, b) {
            return b[1] - a[1]  // Sort by date
        })

        while (sortedFiles.length > 5) { // We need to display the last 5 recently opened files, so we remove the oldest ones
            var removedFile = sortedFiles.pop()
            recentFiles.removeFile(removedFile[0])
        }

        for (var i = 0; i < sortedFiles.length; i++) {
            key = sortedFiles[i][0]
            var localTimestamp = sortedFiles[i][1]
            var thumbnailPath = sortedFiles[i][2]

            var tmp = new Date(localTimestamp.getTime() - localTimestamp.getTimezoneOffset() * 60000)
            var formattedTimestamp = tmp.toISOString().replace('T', ' ').slice(0, 19)

            recentFilesModel.append({
                "filePath": key,
                "timestamp": formattedTimestamp,
                "thumbnailPath": thumbnailPath
            })
        }
    }
}
