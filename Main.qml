import QtQuick
import QtQuick.Controls 6.7
import QtQuick.Layouts 1.15
import QtMultimedia 6.7
import QtQuick.Dialogs
import "."

ApplicationWindow {
    id: root
    width: 800
    height: 600
    visible: true
    title: qsTr("Video Player")

    Component.onCompleted: {
        var size = preferences.loadWindowSize();
        root.width = size[0];
        root.height = size[1];
        root.x = size[2];
        root.y = size[3];
    }

    onClosing: {
        preferences.saveWindowSize(root.width, root.height, root.x, root.y);
    }

    RecentFilesPopup {
        id: recentFilesPopup
        x: toolbar.x
        y: toolbar.height

        onFileSelected: {
            videoPlayer.source = filePath
            playVideo()
            recentFiles.addFile(filePath)
            recentFilesPopup.close()
        }
    }

    Rectangle {
        id: toolbar
        width: parent.width
        height: 50
        color: "#f2f2f2"

        Rectangle {
            id: recentFilesButton
            height: parent.height
            width: parent.width / 4
            anchors.left: parent.left
            radius: 60
            color: "#e8eaeb"

            Text {
                id: openRecentFilesText
                text: qsTr("Recent")
                font.pixelSize: 14
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: recentFilesPopup.open()
            }
        }

        Rectangle {
            id: toolbarTextRectangle
            height: parent.height
            width: parent.width / 2
            anchors.left: recentFilesButton.right
            color: "#f2f2f2"

            Text {
                id: toolbarText
                text: qsTr("Video Player")
                font.pixelSize: 16
                font.family: "Courier New"
                font.italic: true
                font.bold: true
                color: "#368cc2"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: openFileButton
            height: parent.height
            width: parent.width / 4
            anchors.left: toolbarTextRectangle.right
            radius: 50
            color: "#e8eaeb"

            Text {
                id: openFileText
                text: qsTr("Open")
                font.pixelSize: 14
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: fileDialog.open()
            }
        }
    }

    // Menu for controls(play/pause/reset/volume) at the bottom of the screen
    Rectangle {
        id: controlsMenu
        width: parent.width
        height: 100
        anchors.bottom: parent.bottom
        color: "#f2f2f2"
        border.color: "#cccccc"

        Rectangle {
            id: progressBar
            width: parent.width - 40
            height: 5
            color: "#d7d8d9"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 10
            radius: 10
            visible: false

            Rectangle {
                id: filledProgress
                height: parent.height
                color: "#29a7f0"
                width: 0
                radius: 10
            }
        }

        Rectangle {
            id: volumeControl
            width: 200
            height: parent.height - 50
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.margins: 50
            color: "#f2f2f2"
            radius: 10

            Button {
                id: volumeButton
                width: 30
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                icon.source: "qrc:/images/volume_icon.png"
                icon.color: "white"
                visible: false
                background: Rectangle {
                    color: "#07a6eb"
                    radius: 5
                }
                onClicked: {
                    volumeSlider.visible = !volumeSlider.visible
                }
            }

            Slider {
                id: volumeSlider
                width: volumeControl.width / 2
                height: 30
                from: 0
                to: 100
                value: (preferences !== null && preferences !== undefined) ? preferences.getVolume() : 50
                onValueChanged: if (preferences !== null && preferences !== undefined) {
                    preferences.setVolume(value);
                }
                anchors.centerIn: parent
                visible: false
                opacity: 0
                contentItem: Rectangle {
                    width: volumeSlider.width
                    height: volumeSlider.height
                    color: "transparent"

                    Rectangle {
                        width: volumeSlider.visualPosition * volumeSlider.width
                        height: 5
                        color: "#07a6eb"
                        radius: 5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Behavior on opacity {
                    PropertyAnimation {
                        duration: 500
                    }
                }
                onVisibleChanged: {
                    if (visible) {
                        volumeSlider.opacity = 1;
                    } else {
                        volumeSlider.opacity = 0;
                    }
                }
            }
        }

        Rectangle {
            id: controls
            width: 200
            height: 40
            anchors.centerIn: parent
            color: "#f2f2f2"
            visible: false

            Button {
                id: backwardsButton
                width: 40
                height: parent.height
                anchors.left: parent.left
                Image {
                    id: backwardsImage
                    anchors.fill: parent
                    source:  "qrc:/images/backwards_icon.png"
                    fillMode: Image.PreserveAspectFit
                    visible: true
                }
                onClicked: videoPlayer.position -= 5000
            }

            Button {
                id: playPauseButton
                width: 50
                height: 50
                anchors.centerIn: parent
                Image {
                    id: playPauseImage
                    anchors.fill: parent
                    source: videoPlayer ? (videoPlayer.playbackState === MediaPlayer.PlayingState ?
                        "qrc:/images/play_icon.png" : "qrc:/images/play_icon.png") : ""
                    fillMode: Image.PreserveAspectFit
                    visible: true
                }
                onClicked: {
                    if (videoPlayer && videoPlayer.playbackState === MediaPlayer.PlayingState) {
                        videoPlayer.pause()
                    } else if (videoPlayer) {
                        videoPlayer.play()
                    }
                }
            }

            Button {
                id: forwardButton
                width: 40
                height: parent.height
                anchors.right: parent.right
                Image {
                    id: forwardImage
                    anchors.fill: parent
                    source:  "qrc:/images/forward_icon.png"
                    fillMode: Image.PreserveAspectFit
                    visible: true
                }
                onClicked: videoPlayer.position += 5000
            }
        }

        Button {
            id: resetButton
            width: 40
            height: 40
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            Image {
                id: resetImage
                anchors.fill: parent
                source:  "qrc:/images/reset_icon.png"
                fillMode: Image.PreserveAspectFit
                visible: true
            }
            onClicked: {
                videoPlayer.stop()
                videoPlayer.position = 0
                videoPlayer.play()
                toastMessage.visible = true
                toastMessage.show("Video has been reset")
            }
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height - toolbar.height - controlsMenu.height
        anchors.top: toolbar.bottom

        MediaPlayer {
            id: videoPlayer
            videoOutput: videoOutput
            // The source will be updated dynamically when new file is opened.
            audioOutput: AudioOutput {
                volume: volumeSlider.value / 100
            }
        }

        Rectangle {
            anchors.fill: parent

            Image {
                id: videoPlayerImage
                width: parent.width / 1.5
                height: parent.height / 1.5
                anchors.centerIn: parent
                source:  "qrc:/images/video_player_icon.png"
                fillMode: Image.PreserveAspectFit
                visible: true
            }

            VideoOutput {
                id: videoOutput
                anchors.centerIn: parent
                fillMode: VideoOutput.PreserveAspectFit
                width: parent.width
                height: parent.height

                TapHandler {
                    onDoubleTapped: {
                        if (root.visibility === Window.FullScreen) {
                            root.showNormal()
                        } else {
                            root.showFullScreen()
                        }
                    }
                }
            }

            ToastMessage {
                id: toastMessage
                anchors.centerIn: parent
                visible: false
            }
        }
    }

    Connections {
        target: videoPlayer
        function onPlaybackStateChanged() {
            if (videoPlayer) {
                playPauseImage.source = videoPlayer.playbackState === MediaPlayer.PlayingState ?
                    "qrc:/images/pause_icon.png" : "qrc:/images/play_icon.png";
            }
        }
        function onPositionChanged() {
            if (videoPlayer.duration > 0) {
                filledProgress.width = (videoPlayer.position / videoPlayer.duration) * progressBar.width;
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Open Video File"
        nameFilters: ["Video files (*.mp4 *.mkv *.avi *.mov)"]
        onAccepted: {
            recentFiles.addFile(fileDialog.selectedFile)
            videoPlayer.source = fileDialog.selectedFile
            playVideo()
        }
    }

    function show(message) {
        toastText.text = message
        toastAnimation.start()
    }

    function playVideo() {
        videoPlayer.play()
        controls.visible = true
        resetButton.visible = true
        progressBar.visible = true
        volumeButton.visible = true
        videoPlayerImage.visible = false
    }
}
