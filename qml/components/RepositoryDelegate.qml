import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: contentColumn.height + Theme.paddingLarge * 2

    // Highlight animation
    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
        opacity: delegate.highlighted ? 0.1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    Column {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingSmall

        // Title row with better layout
        Item {
            width: parent.width
            height: Math.max(titleLabel.height, visibilityLabel.height)

            Label {
                id: titleLabel
                anchors {
                    left: parent.left
                    right: visibilityLabel.left
                    rightMargin: Theme.paddingSmall
                }
                text: name
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                truncationMode: TruncationMode.Fade
                maximumLineCount: 1
            }

            Label {
                id: visibilityLabel
                anchors.right: parent.right
                text: isPrivate ? "🔒" : ""
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                visible: isPrivate
            }
        }

        // Description with proper spacing
        Label {
            width: parent.width
            text: description || "No description"
            color: description ? Theme.secondaryColor : Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeExtraSmall
            font.italic: !description
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            truncationMode: TruncationMode.Fade
            opacity: 0.9
        }

        // Metadata row with better spacing
        Row {
            width: parent.width
            spacing: Theme.paddingLarge

            // Language indicator
            Row {
                spacing: Theme.paddingSmall
                visible: language

                Rectangle {
                    width: Theme.paddingSmall * 1.5
                    height: Theme.paddingSmall * 1.5
                    radius: width / 2
                    color: getLanguageColor(language)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    text: language
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Stars
            Row {
                spacing: Theme.paddingSmall / 2
                visible: stars > 0

                Label {
                    text: "⭐"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    text: formatNumber(stars)
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Forks
            Row {
                spacing: Theme.paddingSmall / 2
                visible: forks > 0

                Label {
                    text: "🍴"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    text: formatNumber(forks)
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // Subtle divider (WebOS-style)
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Theme.horizontalPageMargin
        }
        height: 1
        color: Theme.primaryColor
        opacity: 0.1
    }

    function getLanguageColor(lang) {
        var colors = {
            "JavaScript": "#f1e05a",
            "Python": "#3572A5",
            "Java": "#b07219",
            "C++": "#f34b7d",
            "C": "#555555",
            "Go": "#00ADD8",
            "Rust": "#dea584",
            "TypeScript": "#2b7489",
            "Ruby": "#701516",
            "PHP": "#4F5D95",
            "Swift": "#ffac45",
            "Kotlin": "#F18E33",
            "QML": "#44a51c",
            "Shell": "#89e051"
        }
        return colors[lang] || Theme.highlightColor
    }

    function formatNumber(num) {
        if (num >= 1000) {
            return (num / 1000).toFixed(1) + "k"
        }
        return num.toString()
    }
}
