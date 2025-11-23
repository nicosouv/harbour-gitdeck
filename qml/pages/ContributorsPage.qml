import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: contributorsPage

    property string repositoryOwner
    property string repositoryName
    property var contributorsData: []

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: contributorsData

        header: PageHeader {
            title: "Contributors"
            description: repositoryName
        }

        delegate: BackgroundItem {
            height: Theme.itemSizeMedium

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingMedium

                Rectangle {
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    radius: width / 2
                    clip: true
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: modelData.avatar_url || ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                Column {
                    width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        text: modelData.login
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    Label {
                        text: modelData.contributions + " contributions"
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("UserProfilePage.qml"), {
                    username: modelData.login
                })
            }
        }

        ViewPlaceholder {
            enabled: contributorsData.length === 0 && !githubApi.loading
            text: "No contributors found"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && contributorsData.length === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Connections {
        target: githubApi
        onContributorsReceived: {
            contributorsData = []
            for (var i = 0; i < contributors.length; i++) {
                contributorsData.push(contributors[i])
            }
            contributorsData = contributorsData
        }
    }

    Component.onCompleted: {
        githubApi.fetchContributors(repositoryOwner, repositoryName)
    }
}
