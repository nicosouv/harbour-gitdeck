import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: prPage

    property string repositoryOwner
    property string repositoryName

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: pullRequestModel

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchPullRequests(repositoryOwner, repositoryName)
            }
        }

        header: PageHeader {
            title: "Pull Requests"
            description: repositoryName
        }

        delegate: BackgroundItem {
            height: column.height + Theme.paddingMedium

            Column {
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingSmall

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Rectangle {
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        radius: Theme.paddingSmall
                        color: state === "open" ? "#2da44e" : (merged ? "#8256d0" : Theme.secondaryColor)
                        opacity: 0.3
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.centerIn: parent
                            source: "image://theme/icon-s-merge"
                            width: Theme.iconSizeExtraSmall
                            height: Theme.iconSizeExtraSmall
                        }
                    }

                    Column {
                        width: parent.width - Theme.iconSizeSmall - Theme.paddingSmall

                        Label {
                            text: title
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeMedium
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Row {
                            spacing: Theme.paddingMedium

                            Label {
                                text: "#" + number
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }

                            Label {
                                text: headBranch + " → " + baseBranch
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }

                            Label {
                                text: isDraft ? "Draft" : ""
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                visible: isDraft
                            }
                        }
                    }
                }
            }

            onClicked: {
                Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/pull/" + number)
            }
        }

        ViewPlaceholder {
            enabled: pullRequestModel.count === 0 && !githubApi.loading
            text: "No pull requests"
            hintText: "This repository has no pull requests"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && pullRequestModel.count === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        pullRequestModel.clear()
        githubApi.fetchPullRequests(repositoryOwner, repositoryName)
    }
}
