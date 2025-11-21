import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Settings"
            }

            SectionHeader {
                text: "Account"
            }

            DetailItem {
                label: "Username"
                value: appSettings.username || "Not logged in"
            }

            DetailItem {
                label: "Auth method"
                value: appSettings.authMethod === 1 ? "OAuth" : appSettings.authMethod === 2 ? "Personal Token" : "None"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Logout"
                onClicked: {
                    remorse.execute("Logging out", function() {
                        appSettings.clearAuth()
                        repositoryModel.clear()
                        workflowRunModel.clear()
                        releaseModel.clear()
                        issueModel.clear()
                        pullRequestModel.clear()
                        pageStack.replace(Qt.resolvedUrl("LoginPage.qml"))
                    })
                }
            }

            RemorsePopup {
                id: remorse
            }

            SectionHeader {
                text: "About"
            }

            DetailItem {
                label: "Version"
                value: "0.1.0"
            }

            DetailItem {
                label: "License"
                value: "GPLv3"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "GitHub Repository"
                onClicked: Qt.openUrlExternally("https://github.com/yourusername/harbour-gitdeck")
            }
        }

        VerticalScrollDecorator {}
    }
}
