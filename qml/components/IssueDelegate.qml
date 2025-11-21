import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: column.height + Theme.paddingMedium

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
                width: Theme.iconSizeSmall
                height: Theme.iconSizeSmall
                radius: Theme.paddingSmall
                color: state === "open" ? "#2da44e" : "#8256d0"
                opacity: 0.3
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.centerIn: parent
                    source: isPullRequest ? "image://theme/icon-s-merge" : "image://theme/icon-s-bug"
                    width: Theme.iconSizeExtraSmall
                    height: Theme.iconSizeExtraSmall
                }
            }

            Column {
                width: parent.width - Theme.iconSizeSmall - Theme.paddingSmall

                Label {
                    text: title
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Row {
                    spacing: Theme.paddingMedium

                    Label {
                        text: "#" + number
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        text: state
                        color: state === "open" ? "#2da44e" : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        text: "by " + user
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }

                    Label {
                        text: commentsCount > 0 ? "💬 " + commentsCount : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        visible: commentsCount > 0
                    }
                }

                // Labels
                Flow {
                    width: parent.width
                    spacing: Theme.paddingSmall
                    visible: labels.length > 0

                    Repeater {
                        model: labels
                        delegate: Rectangle {
                            width: labelText.width + Theme.paddingSmall * 2
                            height: labelText.height + Theme.paddingSmall
                            radius: Theme.paddingSmall
                            color: "#" + modelData.color
                            opacity: 0.3

                            Label {
                                id: labelText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }
                    }
                }
            }
        }
    }

    onClicked: {
        Qt.openUrlExternally("https://github.com/" + repositoryOwner + "/" + repositoryName + "/issues/" + number)
    }
}
