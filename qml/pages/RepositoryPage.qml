import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

// WebOS-style repository page with card-based navigation
Page {
    id: repoPage

    property string repositoryName
    property string repositoryOwner
    property string repositoryFullName
    property string repositoryDescription
    property bool isStarred: false
    property string readmeContent: ""

    Component.onCompleted: {
        githubApi.checkIfStarred(repositoryOwner, repositoryName)
        githubApi.fetchReadme(repositoryOwner, repositoryName)
    }

    Connections {
        target: githubApi
        onRepositoryStarStatusReceived: {
            if (owner === repositoryOwner && repo === repositoryName) {
                repoPage.isStarred = isStarred
            }
        }
        onRepositoryStarred: {
            if (owner === repositoryOwner && repo === repositoryName) {
                repoPage.isStarred = true
                appWindow.showNotification("Repository starred")
            }
        }
        onRepositoryUnstarred: {
            if (owner === repositoryOwner && repo === repositoryName) {
                repoPage.isStarred = false
                appWindow.showNotification("Repository unstarred")
            }
        }
        onReadmeReceived: {
            readmeContent = content
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        // WebOS-style smooth scrolling
        flickDeceleration: 1500
        maximumFlickVelocity: 2500

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + repositoryFullName)
            }
            MenuItem {
                text: isStarred ? "Unstar" : "Star"
                onClicked: {
                    if (isStarred) {
                        githubApi.unstarRepository(repositoryOwner, repositoryName)
                    } else {
                        githubApi.starRepository(repositoryOwner, repositoryName)
                    }
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: {
                    githubApi.fetchRepository(repositoryOwner, repositoryName)
                    refreshAnimation.start()
                }
            }
        }

        // Subtle refresh animation
        SequentialAnimation {
            id: refreshAnimation
            NumberAnimation {
                target: column
                property: "opacity"
                to: 0.5
                duration: 150
            }
            NumberAnimation {
                target: column
                property: "opacity"
                to: 1.0
                duration: 150
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: repositoryName
                description: repositoryOwner

                // Subtle title animation on load
                opacity: 0
                Component.onCompleted: {
                    opacity = 1
                }
                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }

            // Description with better styling
            Item {
                width: parent.width
                height: descriptionLabel.height
                visible: repositoryDescription

                Label {
                    id: descriptionLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.horizontalPageMargin
                    }
                    text: repositoryDescription
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                }
            }

            // README section
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                visible: readmeContent.length > 0

                Label {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                    }
                    text: "README"
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                }

                Rectangle {
                    width: parent.width - Theme.horizontalPageMargin * 2
                    height: readmeText.height + Theme.paddingLarge * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)
                    radius: Theme.paddingSmall

                    Label {
                        id: readmeText
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Theme.paddingLarge
                        }
                        text: readmeContent
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.family: "Monospace"
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                    }
                }
            }

            // Actions section
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                }
                text: "Actions"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
            }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                NavCard {
                    iconSource: "image://theme/icon-m-play"
                    label: "Workflow Runs"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("WorkflowRunsPage.qml"), {
                            repositoryOwner: repositoryOwner,
                            repositoryName: repositoryName
                        })
                    }
                }

                NavCard {
                    iconSource: "image://theme/icon-m-download"
                    label: "Releases"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("ReleasesPage.qml"), {
                            repositoryOwner: repositoryOwner,
                            repositoryName: repositoryName
                        })
                    }
                }

                NavCard {
                    iconSource: "image://theme/icon-m-note"
                    label: "Issues"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("IssuesPage.qml"), {
                            repositoryOwner: repositoryOwner,
                            repositoryName: repositoryName
                        })
                    }
                }

                NavCard {
                    iconSource: "image://theme/icon-m-share"
                    label: "Pull Requests"
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("PullRequestsPage.qml"), {
                            repositoryOwner: repositoryOwner,
                            repositoryName: repositoryName
                        })
                    }
                }
            }

            // Code section
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                }
                text: "Code"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
            }

            NavCard {
                iconSource: "image://theme/icon-m-file-folder"
                label: "Browse Files"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("RepositoryBrowserPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }

            NavCard {
                iconSource: "image://theme/icon-m-device-upload"
                label: "Branches"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("BranchesPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName
                    })
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
