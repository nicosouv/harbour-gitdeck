import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: commitDetailPage

    property string repositoryOwner
    property string repositoryName
    property string commitSha
    property var commitData: null

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/commit/" + commitSha)
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: commitSha.substring(0, 7)
                description: repositoryName
            }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                visible: commitData

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    text: commitData ? commitData.commit.message : ""
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                    }
                    spacing: Theme.paddingMedium

                    Label {
                        text: commitData && commitData.commit.author ? commitData.commit.author.name : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    Label {
                        text: commitData && commitData.commit.author ? formatDate(commitData.commit.author.date) : ""
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                Rectangle {
                    width: parent.width - Theme.horizontalPageMargin * 2
                    height: statsRow.height + Theme.paddingMedium
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)
                    radius: Theme.paddingSmall

                    Row {
                        id: statsRow
                        anchors.centerIn: parent
                        spacing: Theme.paddingLarge

                        Label {
                            text: commitData && commitData.stats ? "+" + commitData.stats.additions : ""
                            color: "#2da44e"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                        }

                        Label {
                            text: commitData && commitData.stats ? "-" + commitData.stats.deletions : ""
                            color: "#cf222e"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                        }

                        Label {
                            text: commitData && commitData.files ? commitData.files.length + " files" : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }

            SectionHeader {
                text: "Changed Files"
                visible: commitData && commitData.files
            }

            Repeater {
                model: commitData && commitData.files ? commitData.files : []
                delegate: BackgroundItem {
                    height: fileColumn.height + Theme.paddingMedium
                    width: parent.width

                    Column {
                        id: fileColumn
                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: Theme.horizontalPageMargin
                            rightMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: Theme.paddingSmall

                        Row {
                            spacing: Theme.paddingSmall
                            width: parent.width

                            Rectangle {
                                width: Theme.paddingLarge
                                height: Theme.paddingLarge
                                radius: Theme.paddingSmall / 2
                                color: {
                                    if (modelData.status === "added") return Theme.rgba("#2da44e", 0.3)
                                    if (modelData.status === "removed") return Theme.rgba("#cf222e", 0.3)
                                    return Theme.rgba(Theme.highlightColor, 0.3)
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: modelData.filename
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                font.family: "Monospace"
                                wrapMode: Text.WrapAnywhere
                                width: parent.width - Theme.paddingLarge - Theme.paddingSmall - statusLabel.width - Theme.paddingSmall
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                id: statusLabel
                                text: modelData.status
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Label {
                            text: "+" + modelData.additions + " -" + modelData.deletions + " (" + modelData.changes + " changes)"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    onClicked: {
                        // Could open diff viewer here
                        Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/commit/" + commitSha + "#diff-" + modelData.sha)
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: githubApi.loading && !commitData
        size: BusyIndicatorSize.Large
    }

    Connections {
        target: githubApi
        onCommitReceived: {
            commitData = commit
        }
    }

    Component.onCompleted: {
        githubApi.fetchCommit(repositoryOwner, repositoryName, commitSha)
    }

    function formatDate(dateString) {
        var date = new Date(dateString)
        return Qt.formatDateTime(date, "MMM d, yyyy hh:mm")
    }
}
