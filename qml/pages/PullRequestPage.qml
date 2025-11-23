import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: prPage

    property string repositoryOwner
    property string repositoryName
    property int prNumber

    property var prData: null
    property var commentsData: []

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/pull/" + prNumber)
            }
            MenuItem {
                text: "Refresh"
                onClicked: loadData()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "#" + prNumber
                description: repositoryName
            }

            // PR details
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                visible: prData

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    text: prData ? prData.title : ""
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                    }
                    spacing: Theme.paddingSmall

                    Rectangle {
                        width: statusLabel.width + Theme.paddingMedium
                        height: statusLabel.height + Theme.paddingSmall / 2
                        radius: Theme.paddingSmall / 2
                        color: {
                            if (!prData) return "transparent"
                            if (prData.state === "open") return Theme.rgba("#2da44e", 0.2)
                            if (prData.merged) return Theme.rgba("#8957e5", 0.2)
                            return Theme.rgba("#cf222e", 0.2)
                        }

                        Label {
                            id: statusLabel
                            anchors.centerIn: parent
                            text: {
                                if (!prData) return ""
                                if (prData.state === "open") return "Open"
                                if (prData.merged) return "Merged"
                                return "Closed"
                            }
                            color: {
                                if (!prData) return Theme.primaryColor
                                if (prData.state === "open") return "#2da44e"
                                if (prData.merged) return "#8957e5"
                                return "#cf222e"
                            }
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.weight: Font.Medium
                        }
                    }

                    Label {
                        text: prData ? (prData.user.login + " wants to merge into " + prData.base.ref) : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        anchors.verticalCenter: parent.verticalCenter
                        truncationMode: TruncationMode.Fade
                    }
                }

                Label {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    text: prData ? prData.body : ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                    visible: prData && prData.body
                }
            }

            SectionHeader {
                text: "Comments (" + commentsData.length + ")"
            }

            Repeater {
                model: commentsData
                delegate: Item {
                    width: parent.width
                    height: commentColumn.height + Theme.paddingLarge

                    Column {
                        id: commentColumn
                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: Theme.horizontalPageMargin
                            rightMargin: Theme.horizontalPageMargin
                        }
                        spacing: Theme.paddingSmall

                        Row {
                            spacing: Theme.paddingSmall

                            Label {
                                text: modelData.user.login
                                color: Theme.highlightColor
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                            }

                            Label {
                                text: "commented " + formatDate(modelData.created_at)
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: commentText.height + Theme.paddingLarge
                            color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)
                            radius: Theme.paddingSmall

                            Label {
                                id: commentText
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: Theme.paddingMedium
                                }
                                text: modelData.body
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            ViewPlaceholder {
                enabled: !prData && !githubApi.loading
                text: "Loading pull request..."
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: githubApi.loading
                size: BusyIndicatorSize.Large
            }
        }

        VerticalScrollDecorator {}
    }

    Connections {
        target: githubApi
        onPullRequestReceived: {
            prData = pr
        }
        onPullRequestCommentsReceived: {
            commentsData = []
            for (var i = 0; i < comments.length; i++) {
                commentsData.push(comments[i])
            }
            commentsData = commentsData
        }
    }

    Component.onCompleted: loadData()

    function loadData() {
        githubApi.fetchPullRequest(repositoryOwner, repositoryName, prNumber)
        githubApi.fetchPullRequestComments(repositoryOwner, repositoryName, prNumber)
    }

    function formatDate(dateString) {
        var date = new Date(dateString)
        var now = new Date()
        var diff = now - date
        var minutes = Math.floor(diff / 60000)
        var hours = Math.floor(diff / 3600000)
        var days = Math.floor(diff / 86400000)

        if (minutes < 1) return "just now"
        if (minutes < 60) return minutes + "m ago"
        if (hours < 24) return hours + "h ago"
        if (days < 7) return days + "d ago"
        return Qt.formatDate(date, "MMM d")
    }
}
