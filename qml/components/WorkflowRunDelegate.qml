import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: Theme.itemSizeLarge

    Row {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        // Status icon
        Rectangle {
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
            radius: width / 2
            color: getStatusColor(status, conclusion)
            anchors.verticalCenter: parent.verticalCenter

            BusyIndicator {
                anchors.centerIn: parent
                running: status === "in_progress" || status === "queued"
                size: BusyIndicatorSize.ExtraSmall
            }
        }

        Column {
            width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
            spacing: Theme.paddingSmall

            Label {
                width: parent.width
                text: name + " #" + runNumber
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                truncationMode: TruncationMode.Fade
            }

            Label {
                width: parent.width
                text: commitMessage
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                maximumLineCount: 1
                truncationMode: TruncationMode.Fade
            }

            Row {
                spacing: Theme.paddingMedium

                Label {
                    text: branch
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Label {
                    text: "•"
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Label {
                    text: getStatusText(status, conclusion)
                    color: getStatusColor(status, conclusion)
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Label {
                    text: "•"
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Label {
                    text: formatDate(updatedAt)
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
        }
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
