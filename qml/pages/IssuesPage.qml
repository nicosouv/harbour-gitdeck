import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: issuesPage

    property string repositoryOwner
    property string repositoryName

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: issueModel

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchIssues(repositoryOwner, repositoryName)
            }
        }

        header: PageHeader {
            title: "Issues"
            description: repositoryName
        }

        delegate: IssueDelegate {}

        ViewPlaceholder {
            enabled: issueModel.count === 0 && !githubApi.loading
            text: "No issues"
            hintText: "This repository has no issues"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && issueModel.count === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        issueModel.clear()
        githubApi.fetchIssues(repositoryOwner, repositoryName)
    }
}
