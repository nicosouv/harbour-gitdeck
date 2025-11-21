import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: workflowPage

    property string repositoryOwner
    property string repositoryName

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: workflowRunModel

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchRepositoryWorkflowRuns(repositoryOwner, repositoryName)
            }
        }

        header: PageHeader {
            title: "Workflow Runs"
            description: repositoryName
        }

        delegate: WorkflowRunDelegate {
            onClicked: {
                pageStack.push(Qt.resolvedUrl("WorkflowRunDetailPage.qml"), {
                    repositoryOwner: repositoryOwner,
                    repositoryName: repositoryName,
                    runId: runId,
                    runName: name,
                    runStatus: status,
                    runConclusion: conclusion
                })
            }
        }

        ViewPlaceholder {
            enabled: workflowRunModel.count === 0 && !githubApi.loading
            text: "No workflow runs"
            hintText: "This repository has no GitHub Actions workflows"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && workflowRunModel.count === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        workflowRunModel.clear()
        githubApi.fetchRepositoryWorkflowRuns(repositoryOwner, repositoryName)
    }
}
