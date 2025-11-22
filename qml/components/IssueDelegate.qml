import QtQuick 2.0
import Sailfish.Silica 1.0

// WebOS-style issue/PR delegate with smooth animations
ListItem {
    id: delegate
    contentHeight: column.height + Theme.paddingLarge

    // Fade-in animation
    opacity: 0
    Component.onCompleted: fadeIn.start()
    NumberAnimation on opacity {
        id: fadeIn
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutQuad
    }

    // Subtle background highlight
    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.03)
        opacity: delegate.highlighted ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

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
            spacing: Theme.paddingMedium

            // Enhanced state indicator
            Rectangle {
                width: Theme.iconSizeSmall
                height: Theme.iconSizeSmall
                radius: Theme.paddingSmall
                color: state === "open" ? "#2da44e" : "#8256d0"
                opacity: 0.3
                anchors.verticalCenter: parent.verticalCenter

                // Smooth color transition
                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
                }

                Image {
                    anchors.centerIn: parent
                    source: isPullRequest ? "image://theme/icon-s-merge" : "image://theme/icon-s-bug"
                    width: Theme.iconSizeExtraSmall
                    height: Theme.iconSizeExtraSmall
                }
            }

            Column {
                width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                spacing: Theme.paddingSmall

                // Title with better layout
                Label {
                    text: title
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    wrapMode: Text.WordWrap
                    width: parent.width
                    maximumLineCount: 3
                }

                // Metadata row with better spacing
                Flow {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Label {
                        text: "#" + number
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.weight: Font.Medium
                    }

                    Label {
                        text: "•"
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        opacity: 0.5
                    }

                    // State badge
                    Rectangle {
                        width: stateLabel.width + Theme.paddingSmall
                        height: stateLabel.height + Theme.paddingSmall / 4
                        radius: Theme.paddingSmall / 2
                        color: state === "open" ? Theme.rgba("#2da44e", 0.2) : Theme.rgba("#8256d0", 0.2)
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: stateLabel
                            anchors.centerIn: parent
                            text: state
                            color: state === "open" ? "#2da44e" : "#8256d0"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.weight: Font.Medium
                        }
                    }

                    Label {
                        text: "•"
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        opacity: 0.5
                    }

                    Label {
                        text: "by " + user
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    // Comments indicator
                    Row {
                        spacing: Theme.paddingSmall / 2
                        visible: commentsCount > 0

                        Label {
                            text: "•"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            opacity: 0.5
                        }

                        Label {
                            text: "💬 " + commentsCount
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }

                // Enhanced labels with better badges
                Flow {
                    width: parent.width
                    spacing: Theme.paddingSmall / 2
                    visible: labels.length > 0

                    Repeater {
                        model: labels
                        delegate: Rectangle {
                            width: labelText.width + Theme.paddingSmall * 1.5
                            height: labelText.height + Theme.paddingSmall / 2
                            radius: Theme.paddingSmall / 2
                            color: Theme.rgba("#" + modelData.color, 0.3)
                            border.color: Theme.rgba("#" + modelData.color, 0.6)
                            border.width: 1

                            Label {
                                id: labelText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: getLabelTextColor(modelData.color)
                                font.pixelSize: Theme.fontSizeExtraSmall
                                font.weight: Font.Medium
                            }
                        }
                    }
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

    function getLabelTextColor(colorHex) {
        // Simple contrast check - if color is light, return dark text
        var r = parseInt(colorHex.substring(0, 2), 16)
        var g = parseInt(colorHex.substring(2, 4), 16)
        var b = parseInt(colorHex.substring(4, 6), 16)
        var brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness > 155 ? "#000000" : Theme.primaryColor
    }

    onClicked: {
        Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/issues/" + number)
    }
}
