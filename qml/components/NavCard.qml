import QtQuick 2.0
import Sailfish.Silica 1.0

// WebOS-style navigation card
BackgroundItem {
    id: navCard
    width: parent.width
    height: Theme.itemSizeMedium

    property string iconSource
    property string label
    property int animationDelay: 0

    // Fade-in animation with delay
    opacity: 0
    Component.onCompleted: fadeIn.start()
    NumberAnimation on opacity {
        id: fadeIn
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutQuad
    }

    // Card background
    Rectangle {
        anchors {
            fill: parent
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)
        radius: Theme.paddingMedium
        opacity: navCard.highlighted ? 1.0 : 0.5
        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin + Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        Image {
            source: iconSource
            width: Theme.iconSizeMedium
            height: Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
        }

        Label {
            text: label
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Arrow indicator
    Image {
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin + Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        source: "image://theme/icon-m-right"
        width: Theme.iconSizeSmall
        height: Theme.iconSizeSmall
        opacity: 0.3
    }
}
