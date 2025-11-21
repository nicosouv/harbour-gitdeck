import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: Theme.itemSizeLarge

    Column {
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

            Label {
                text: name
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                truncationMode: TruncationMode.Fade
                width: Math.min(implicitWidth, parent.width - visibilityLabel.width - parent.spacing)
            }

            Label {
                id: visibilityLabel
                text: isPrivate ? "🔒" : ""
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Label {
            width: parent.width
            text: description || "No description"
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            truncationMode: TruncationMode.Fade
        }

        Row {
            spacing: Theme.paddingLarge

            Row {
                spacing: Theme.paddingSmall
                visible: language

                Rectangle {
                    width: Theme.paddingSmall
                    height: Theme.paddingSmall
                    radius: width / 2
                    color: getLanguageColor(language)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    text: language
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Label {
                text: "⭐ " + stars
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: stars > 0
            }

            Label {
                text: "🍴 " + forks
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: forks > 0
            }
        }
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
            "QML": "#44a51c"
        }
        return colors[lang] || Theme.highlightColor
    }
}
