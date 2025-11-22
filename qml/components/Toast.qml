import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

// WebOS-style toast notification
Item {
    id: toast

    property string message: ""
    property int duration: 3000
    property bool isError: false

    signal clicked()

    width: parent.width
    height: toastRect.height
    anchors {
        bottom: parent.bottom
        bottomMargin: Theme.paddingLarge
        left: parent.left
        right: parent.right
        leftMargin: Theme.horizontalPageMargin
        rightMargin: Theme.horizontalPageMargin
    }

    opacity: 0
    scale: 0.9

    MouseArea {
        anchors.fill: parent
        onClicked: {
            toast.clicked()
            hideToast()
        }
    }

    Rectangle {
        id: toastRect
        anchors.centerIn: parent
        width: parent.width
        height: toastLabel.height + Theme.paddingLarge * 2
        radius: Theme.paddingMedium
        color: isError ? Theme.rgba("#cf222e", 0.95) : Theme.rgba(Theme.highlightBackgroundColor, 0.95)

        Label {
            id: toastLabel
            anchors.centerIn: parent
            width: parent.width - Theme.paddingLarge * 2
            text: toast.message
            color: isError ? "white" : Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 3
        }
    }

    // Show animation - WebOS-style slide up with bounce
    SequentialAnimation {
        id: showAnimation

        ParallelAnimation {
            NumberAnimation {
                target: toast
                property: "opacity"
                to: 1.0
                duration: 250
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: toast
                property: "scale"
                to: 1.0
                duration: 250
                easing.type: Easing.OutBack
                easing.overshoot: 1.5
            }

            NumberAnimation {
                target: toast
                property: "anchors.bottomMargin"
                from: -toast.height
                to: Theme.paddingLarge
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        PauseAnimation {
            duration: toast.duration
        }

        ScriptAction {
            script: hideToast()
        }
    }

    // Hide animation
    ParallelAnimation {
        id: hideAnimation

        NumberAnimation {
            target: toast
            property: "opacity"
            to: 0
            duration: 200
            easing.type: Easing.InQuad
        }

        NumberAnimation {
            target: toast
            property: "scale"
            to: 0.9
            duration: 200
            easing.type: Easing.InQuad
        }

        onStopped: toast.destroy()
    }

    function show() {
        showAnimation.start()
    }

    function hideToast() {
        showAnimation.stop()
        hideAnimation.start()
    }

    Component.onCompleted: {
        show()
    }
}
