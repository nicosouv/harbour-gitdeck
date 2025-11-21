import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: repoPage

    property string repositoryName
    property string repositoryOwner
    property string repositoryFullName
    property string repositoryDescription

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + repositoryFullName)
            }
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchRepository(repositoryOwner, repositoryName)
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: repositoryName
                description: repositoryOwner
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                text: repositoryDescription
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                visible: repositoryDescription
            }

            SectionHeader {
                text: "Actions"
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        source: "image://theme/icon-m-play"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    Label {
                        text: "Workflow Runs"
                        color: Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("WorkflowRunsPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        source: "image://theme/icon-m-download"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    Label {
                        text: "Releases"
                        color: Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ReleasesPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        source: "image://theme/icon-m-bug"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    Label {
                        text: "Issues"
                        color: Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("IssuesPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        source: "image://theme/icon-m-merge"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    Label {
                        text: "Pull Requests"
                        color: Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PullRequestsPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }

            SectionHeader {
                text: "Code"
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        source: "image://theme/icon-m-file-folder"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    Label {
                        text: "Browse Files"
                        color: Theme.primaryColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("RepositoryBrowserPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
