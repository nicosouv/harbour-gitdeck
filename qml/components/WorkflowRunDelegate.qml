import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: Theme.itemSizeLarge + Theme.paddingMedium

    // Subtle background highlight
    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.03)
        opacity: delegate.highlighted ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

    Row {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        // Enhanced status indicator
        Item {
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: statusCircle
                anchors.fill: parent
                radius: width / 2
                color: getStatusColor(status, conclusion)

                // Smooth color transition
                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
                }

                // Pulse animation for in-progress
                SequentialAnimation on scale {
                    running: status === "in_progress"
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 1.15; duration: 800; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 1.15; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: status === "in_progress" || status === "queued"
                    size: BusyIndicatorSize.ExtraSmall
                    opacity: 0.8
                }
            }
        }

        Column {
            width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
            spacing: Theme.paddingSmall

            // Title with better layout
            Item {
                width: parent.width
                height: titleLabel.height

                Label {
                    id: titleLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    text: name + " #" + runNumber
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 1
                }
            }

            // Commit message with better truncation
            Label {
                width: parent.width
                text: commitMessage
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                maximumLineCount: 1
                truncationMode: TruncationMode.Fade
                wrapMode: Text.NoWrap
            }

            // Metadata row with better spacing
            Flow {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    text: branch
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Label {
                    text: "•"
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    opacity: 0.5
                }

                Label {
                    text: getStatusText(status, conclusion)
                    color: getStatusColor(status, conclusion)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.weight: Font.Medium
                }

                Label {
                    text: "•"
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    opacity: 0.5
                }

                Label {
                    text: formatDate(updatedAt)
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
        }
    }

    // Subtle divider
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        height: 1
        color: Theme.primaryColor
        opacity: 0.1
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
