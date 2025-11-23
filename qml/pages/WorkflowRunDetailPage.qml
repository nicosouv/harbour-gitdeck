import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: detailPage

    property string repositoryOwner
    property string repositoryName
    property var runId
    property string runName
    property string runStatus
    property string runConclusion

    property var jobsData: []
    property var artifactsData: []

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/actions/runs/" + runId)
            }
            MenuItem {
                text: "Cancel"
                visible: runStatus === "in_progress" || runStatus === "queued"
                onClicked: {
                    githubApi.cancelWorkflow(repositoryOwner, repositoryName, runId)
                    appWindow.showNotification("Workflow cancelled")
                }
            }
            MenuItem {
                text: "Re-run"
                visible: runStatus === "completed"
                onClicked: {
                    githubApi.rerunWorkflow(repositoryOwner, repositoryName, runId)
                    appWindow.showNotification("Workflow rerun initiated")
                }
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
                title: runName
                description: "#" + runId
            }

            // Status banner
            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                enabled: false

                Rectangle {
                    anchors.fill: parent
                    color: getStatusColor(runStatus, runConclusion)
                    opacity: 0.2
                }

                Label {
                    anchors.centerIn: parent
                    text: getStatusText(runStatus, runConclusion)
                    color: getStatusColor(runStatus, runConclusion)
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                }
            }

            // Action buttons row
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                visible: runStatus === "completed" || runStatus === "in_progress"

                Button {
                    text: "Re-run"
                    visible: runStatus === "completed"
                    onClicked: {
                        githubApi.rerunWorkflow(repositoryOwner, repositoryName, runId)
                        appWindow.showNotification("Workflow rerun initiated")
                    }
                }

                Button {
                    text: "Cancel"
                    visible: runStatus === "in_progress" || runStatus === "queued"
                    onClicked: {
                        githubApi.cancelWorkflow(repositoryOwner, repositoryName, runId)
                        appWindow.showNotification("Workflow cancelled")
                    }
                }
            }

            // Artifacts section
            SectionHeader {
                text: "Artifacts (" + artifactsData.length + ")"
                visible: artifactsData.length > 0
            }

            Repeater {
                model: artifactsData
                delegate: ListItem {
                    contentHeight: Theme.itemSizeSmall

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
                            source: "image://theme/icon-m-file-archive"
                            width: Theme.iconSizeSmall
                            height: Theme.iconSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium

                            Label {
                                text: modelData.name
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                truncationMode: TruncationMode.Fade
                                width: parent.width
                            }

                            Label {
                                text: formatSize(modelData.size_in_bytes)
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }
                    }

                    onClicked: {
                        githubApi.downloadWorkflowArtifact(repositoryOwner, repositoryName, modelData.id, modelData.name + ".zip")
                        appWindow.showNotification("Downloading " + modelData.name)
                    }
                }
            }

            SectionHeader {
                text: "Jobs"
            }

            // Jobs list
            Repeater {
                model: jobsData
                delegate: Column {
                    width: parent.width
                    spacing: 0

                    BackgroundItem {
                        width: parent.width
                        height: Theme.itemSizeMedium

                        Row {
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.horizontalPageMargin
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: Theme.paddingMedium

                            Rectangle {
                                width: Theme.iconSizeSmall
                                height: Theme.iconSizeSmall
                                radius: width / 2
                                color: getStatusColor(modelData.status, modelData.conclusion)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium

                                Label {
                                    text: modelData.name
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeMedium
                                }

                                Label {
                                    text: getStatusText(modelData.status, modelData.conclusion) + " • " +
                                          formatDuration(modelData.started_at, modelData.completed_at)
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                }
                            }
                        }

                        onClicked: {
                            if (modelData.steps) {
                                modelData.expanded = !modelData.expanded
                                jobsData = jobsData // Force refresh
                            }
                        }
                    }

                    // Steps
                    Column {
                        width: parent.width
                        visible: modelData.expanded && modelData.steps
                        spacing: 0

                        Repeater {
                            model: modelData.steps || []
                            delegate: BackgroundItem {
                                width: parent.width
                                height: Theme.itemSizeSmall
                                enabled: false

                                Row {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        leftMargin: Theme.horizontalPageMargin + Theme.iconSizeMedium
                                        rightMargin: Theme.horizontalPageMargin
                                        verticalCenter: parent.verticalCenter
                                    }
                                    spacing: Theme.paddingSmall

                                    Rectangle {
                                        width: Theme.paddingSmall
                                        height: Theme.paddingSmall
                                        radius: width / 2
                                        color: getStatusColor(modelData.status, modelData.conclusion)
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Label {
                                        text: modelData.name
                                        color: Theme.secondaryColor
                                        font.pixelSize: Theme.fontSizeSmall
                                        width: parent.width - Theme.paddingSmall - Theme.paddingSmall
                                        truncationMode: TruncationMode.Fade
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ViewPlaceholder {
                enabled: jobsData.length === 0 && !githubApi.loading
                text: "No jobs found"
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
        onWorkflowJobsReceived: {
            jobsData = []
            for (var i = 0; i < jobs.length; i++) {
                var job = jobs[i]
                job.expanded = false
                jobsData.push(job)
            }
            jobsData = jobsData // Force update
        }
        onWorkflowArtifactsReceived: {
            artifactsData = []
            for (var i = 0; i < artifacts.length; i++) {
                artifactsData.push(artifacts[i])
            }
            artifactsData = artifactsData // Force update
        }
    }

    Component.onCompleted: loadData()

    function loadData() {
        githubApi.fetchWorkflowRunJobs(repositoryOwner, repositoryName, runId)
        githubApi.fetchWorkflowRunArtifacts(repositoryOwner, repositoryName, runId)
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        return (bytes / (1024 * 1024)).toFixed(1) + " MB"
    }

    function getStatusColor(status, conclusion) {
        if (status === "completed") {
            if (conclusion === "success") return "#2da44e"
            if (conclusion === "failure") return "#cf222e"
            if (conclusion === "cancelled") return "#6e7781"
            return Theme.secondaryColor
        }
        if (status === "in_progress") return "#bf8700"
        if (status === "queued") return Theme.secondaryHighlightColor
        return Theme.secondaryColor
    }

    function getStatusText(status, conclusion) {
        if (status === "completed") {
            if (conclusion === "success") return "Success"
            if (conclusion === "failure") return "Failed"
            if (conclusion === "cancelled") return "Cancelled"
            return conclusion
        }
        if (status === "in_progress") return "In progress"
        if (status === "queued") return "Queued"
        return status
    }

    function formatDuration(start, end) {
        if (!start) return ""
        var startTime = new Date(start)
        var endTime = end ? new Date(end) : new Date()
        var diff = endTime - startTime
        var seconds = Math.floor(diff / 1000)
        var minutes = Math.floor(seconds / 60)
        seconds = seconds % 60

        if (minutes > 0) {
            return minutes + "m " + seconds + "s"
        }
        return seconds + "s"
    }
}
