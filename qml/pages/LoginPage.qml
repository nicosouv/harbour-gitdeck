import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: loginPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "GitDeck"
            }

            Item {
                width: parent.width
                height: Theme.itemSizeHuge
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://theme/icon-l-developer-mode"
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "GitHub Client for Sailfish OS"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Connect to GitHub"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge * 2
            }

            // OAuth Login
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Login with GitHub OAuth"
                preferredWidth: Theme.buttonWidthLarge
                onClicked: oauthManager.startAuthentication()
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "or"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
            }

            // Personal Access Token
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Use Personal Access Token"
                preferredWidth: Theme.buttonWidthLarge
                onClicked: pageStack.push(Qt.resolvedUrl("TokenLoginPage.qml"))
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                text: "OAuth opens in your browser and returns automatically. Choose Personal Access Token if OAuth doesn't work."
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: oauthManager.isAuthenticating
        size: BusyIndicatorSize.Large
    }
}
