import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: toast
    width: 200
    height: 50
    color: "#2185bf"
    radius: 5
    anchors.centerIn: parent

    Text {
        id: toastText
        text: "Toast message"
        color: "#fff"
        font.pixelSize: 14
        anchors.centerIn: parent
    }

    SequentialAnimation {
        id: toastAnimation
        running: false
        PropertyAnimation { target: toast; property: "opacity"; from: 0; to: 1; duration: 300 }
        PauseAnimation { duration: 2000 }
        PropertyAnimation { target: toast; property: "opacity"; from: 1; to: 0; duration: 300 }
    }

    function show(message) {
        toastText.text = message
        toastAnimation.start()
    }
}
