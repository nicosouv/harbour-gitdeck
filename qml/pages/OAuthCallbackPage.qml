import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: callbackPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Waiting for authorization"
            }

            Item {
                width: parent.width
                height: Theme.itemSizeHuge
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
                size: BusyIndicatorSize.Large
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Complete the authorization in your browser"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                text: "After authorizing GitDeck in your browser, copy the authorization code and paste it below."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: codeField
                width: parent.width
                label: "Authorization Code"
                placeholderText: "Paste code here"
                inputMethodHints: Qt.ImhNoPredictiveText

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if (text.length > 0) {
                        oauthManager.exchangeCodeForToken(text)
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Submit Code"
                enabled: codeField.text.length > 0
                onClicked: oauthManager.exchangeCodeForToken(codeField.text)
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Cancel"
                onClicked: {
                    oauthManager.cancelAuthentication()
                    pageStack.pop()
                }
            }
        }
    }
}
