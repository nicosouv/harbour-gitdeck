import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: branchesPage

    property string repositoryOwner
    property string repositoryName

    property var branchesData: []

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: branchesData

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: loadData()
            }
        }

        header: PageHeader {
            title: "Branches"
            description: repositoryName
        }

        delegate: ListItem {
            contentHeight: Theme.itemSizeMedium

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingMedium

                Image {
                    source: "image://theme/icon-m-device-upload"
                    width: Theme.iconSizeSmall
                    height: Theme.iconSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                    spacing: Theme.paddingSmall / 2

                    Label {
                        text: modelData.name
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        truncationMode: TruncationMode.Fade
                        width: parent.width
                    }

                    Label {
                        text: modelData.commit ? modelData.commit.sha.substring(0, 7) : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.family: "Monospace"
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("CommitsPage.qml"), {
                    repositoryOwner: repositoryOwner,
                    repositoryName: repositoryName,
                    branchName: modelData.name
                })
            }
        }

        ViewPlaceholder {
            enabled: branchesData.length === 0 && !githubApi.loading
            text: "No branches"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && branchesData.length === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Connections {
        target: githubApi
        onBranchesReceived: {
            branchesData = []
            for (var i = 0; i < branches.length; i++) {
                branchesData.push(branches[i])
            }
            branchesData = branchesData
        }
    }

    Component.onCompleted: loadData()

    function loadData() {
        githubApi.fetchBranches(repositoryOwner, repositoryName)
    }
}
