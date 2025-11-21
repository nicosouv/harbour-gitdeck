import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: tokenDialog

    property string token: ""

    canAccept: tokenField.text.length > 0

    onAccepted: {
        appSettings.saveToken(tokenField.text, 2) // PersonalToken = 2
        githubApi.fetchCurrentUser()
        githubApi.fetchUserRepositories()
        pageStack.replace(Qt.resolvedUrl("MainPage.qml"))
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: "Personal Access Token"
                acceptText: "Login"
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                text: "Enter your GitHub Personal Access Token"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
            }

            TextField {
                id: tokenField
                width: parent.width
                label: "Access Token"
                placeholderText: "ghp_xxxxxxxxxxxx"
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: tokenDialog.accept()
            }

            SectionHeader {
                text: "How to generate a token"
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                text: "1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)\n\n" +
                      "2. Click 'Generate new token (classic)'\n\n" +
                      "3. Select these scopes:\n" +
                      "   • repo (Full control of repositories)\n" +
                      "   • workflow (Update GitHub Action workflows)\n" +
                      "   • read:user (Read user profile data)\n\n" +
                      "4. Copy the generated token and paste it above"
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Open GitHub Settings"
                onClicked: Qt.openUrlExternally("https://github.com/settings/tokens")
            }
        }
    }
}
