import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    Image {
        anchors.centerIn: parent
        source: "image://theme/icon-l-developer-mode"
        width: Theme.iconSizeExtraLarge
        height: Theme.iconSizeExtraLarge
        opacity: 0.6
    }

    Column {
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Theme.paddingSmall

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "GitDeck"
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.primaryColor
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: repositoryModel.count + " repos"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            visible: appSettings.isAuthenticated
        }
    }
}
