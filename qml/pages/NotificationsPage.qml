import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: notificationsPage

    property var notificationsData: []

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: notificationsData

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: loadData()
            }
        }

        header: PageHeader {
            title: "Notifications"
        }

        delegate: ListItem {
            contentHeight: column.height + Theme.paddingLarge

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
                        width: Theme.paddingSmall
                        height: Theme.paddingSmall
                        radius: width / 2
                        color: Theme.highlightColor
                        visible: modelData.unread
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: modelData.subject.title
                        color: modelData.unread ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: modelData.unread ? Font.Bold : Font.Normal
                        truncationMode: TruncationMode.Fade
                        width: parent.width - (modelData.unread ? Theme.paddingSmall * 2 : 0)
                    }
                }

                Label {
                    text: modelData.repository.full_name
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    text: formatNotificationType(modelData.subject.type) + " • " + formatDate(modelData.updated_at)
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            onClicked: {
                var repoPath = modelData.repository.full_name.split("/")
                var owner = repoPath[0]
                var repo = repoPath[1]

                // Navigate based on notification type
                if (modelData.subject.type === "Issue") {
                    var issueNumber = extractNumber(modelData.subject.url)
                    if (issueNumber > 0) {
                        pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {
                            repositoryOwner: owner,
                            repositoryName: repo,
                            issueNumber: issueNumber
                        })
                    }
                } else if (modelData.subject.type === "PullRequest") {
                    var prNumber = extractNumber(modelData.subject.url)
                    if (prNumber > 0) {
                        pageStack.push(Qt.resolvedUrl("PullRequestPage.qml"), {
                            repositoryOwner: owner,
                            repositoryName: repo,
                            prNumber: prNumber
                        })
                    }
                } else {
                    // Open repository page as fallback
                    pageStack.push(Qt.resolvedUrl("RepositoryPage.qml"), {
                        repositoryOwner: owner,
                        repositoryName: repo,
                        repositoryFullName: modelData.repository.full_name
                    })
                }
            }
        }

        ViewPlaceholder {
            enabled: notificationsData.length === 0 && !githubApi.loading
            text: "No notifications"
            hintText: "You're all caught up!"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && notificationsData.length === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Connections {
        target: githubApi
        onNotificationsReceived: {
            notificationsData = []
            for (var i = 0; i < notifications.length; i++) {
                notificationsData.push(notifications[i])
            }
            notificationsData = notificationsData
        }
    }

    Component.onCompleted: loadData()

    function loadData() {
        githubApi.fetchNotifications()
    }

    function formatNotificationType(type) {
        if (type === "PullRequest") return "Pull Request"
        if (type === "Issue") return "Issue"
        if (type === "Release") return "Release"
        if (type === "Commit") return "Commit"
        return type
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

    function extractNumber(url) {
        if (!url) return 0
        var parts = url.split("/")
        var lastPart = parts[parts.length - 1]
        return parseInt(lastPart) || 0
    }
}
