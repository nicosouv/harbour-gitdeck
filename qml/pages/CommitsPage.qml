import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: commitsPage

    property string repositoryOwner
    property string repositoryName
    property string branchName

    property var commitsData: []

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: commitsData

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: loadData()
            }
        }

        header: PageHeader {
            title: branchName
            description: "Commits"
        }

        delegate: ListItem {
            contentHeight: column.height + Theme.paddingMedium * 2

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

                Label {
                    width: parent.width
                    text: modelData.commit.message.split('\n')[0]
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Row {
                    spacing: Theme.paddingMedium

                    Label {
                        text: modelData.sha ? modelData.sha.substring(0, 7) : ""
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.family: "Monospace"
                    }

                    Label {
                        text: modelData.commit && modelData.commit.author ? modelData.commit.author.name : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        text: modelData.commit && modelData.commit.author ? formatDate(modelData.commit.author.date) : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("CommitDetailPage.qml"), {
                    repositoryOwner: repositoryOwner,
                    repositoryName: repositoryName,
                    commitSha: modelData.sha
                })
            }
        }

        ViewPlaceholder {
            enabled: commitsData.length === 0 && !githubApi.loading
            text: "No commits"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && commitsData.length === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Connections {
        target: githubApi
        onCommitsReceived: {
            commitsData = []
            for (var i = 0; i < commits.length; i++) {
                commitsData.push(commits[i])
            }
            commitsData = commitsData
        }
    }

    Component.onCompleted: loadData()

    function loadData() {
        githubApi.fetchCommits(repositoryOwner, repositoryName, branchName)
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
