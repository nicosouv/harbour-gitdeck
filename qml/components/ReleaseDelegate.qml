import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: column.height + Theme.paddingLarge * 2

    property string repositoryOwner
    property string repositoryName
    property bool bodyExpanded: false

    // Card-like background
    Rectangle {
        anchors {
            fill: parent
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            topMargin: Theme.paddingSmall
            bottomMargin: Theme.paddingSmall
        }
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)
        radius: Theme.paddingMedium
        opacity: delegate.highlighted ? 1.0 : 0.5
        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin + Theme.paddingMedium
            rightMargin: Theme.horizontalPageMargin + Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingSmall

        // Tag name with badges
        Flow {
            width: parent.width
            spacing: Theme.paddingSmall

            Label {
                text: tagName
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
            }

            // Pre-release badge
            Rectangle {
                width: prereleaseLabel.width + Theme.paddingMedium
                height: prereleaseLabel.height + Theme.paddingSmall / 2
                radius: Theme.paddingSmall / 2
                color: Theme.rgba(Theme.secondaryHighlightColor, 0.2)
                visible: isPrerelease

                Label {
                    id: prereleaseLabel
                    x: Theme.paddingMedium / 2
                    y: Theme.paddingSmall / 4
                    text: "Pre-release"
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.weight: Font.Medium
                }
            }

            // Draft badge
            Rectangle {
                width: draftLabel.width + Theme.paddingMedium
                height: draftLabel.height + Theme.paddingSmall / 2
                radius: Theme.paddingSmall / 2
                color: Theme.rgba(Theme.secondaryColor, 0.2)
                visible: isDraft

                Label {
                    id: draftLabel
                    x: Theme.paddingMedium / 2
                    y: Theme.paddingSmall / 4
                    text: "Draft"
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.weight: Font.Medium
                }
            }
        }

        // Release name
        Label {
            width: parent.width
            text: name || tagName
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            visible: name && name !== tagName
        }

        // Published date
        Label {
            width: parent.width
            text: formatDate(publishedAt)
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        // Release body/description with toggle
        Column {
            width: parent.width
            spacing: Theme.paddingSmall
            visible: body

            Label {
                width: parent.width
                text: body
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                maximumLineCount: bodyExpanded ? 0 : 4
                elide: bodyExpanded ? Text.ElideNone : Text.ElideRight
            }

            Label {
                text: bodyExpanded ? "Show less" : "Show more"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: body && body.split('\n').length > 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: bodyExpanded = !bodyExpanded
                }
            }
        }

        // Assets section with better styling
        Item {
            width: parent.width
            height: assetsColumn.height
            visible: assets.length > 0

            Column {
                id: assetsColumn
                width: parent.width
                spacing: Theme.paddingSmall

                // Assets header
                Label {
                    text: "Assets (" + assets.length + ")"
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                }

                // Assets list
                Column {
                    width: parent.width
                    spacing: Theme.paddingSmall / 2

                    Repeater {
                        model: assets
                        delegate: BackgroundItem {
                            width: parent.width
                            height: Theme.itemSizeSmall

                            // Asset background
                            Rectangle {
                                anchors.fill: parent
                                color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
                                radius: Theme.paddingSmall
                                opacity: parent.highlighted ? 1.0 : 0.5
                                Behavior on opacity {
                                    NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                                }
                            }

                            Row {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    leftMargin: Theme.paddingMedium
                                    rightMargin: Theme.paddingMedium
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: Theme.paddingMedium

                                // File icon
                                Image {
                                    source: "image://theme/icon-m-file-rpm"
                                    width: Theme.iconSizeSmall
                                    height: Theme.iconSizeSmall
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: 0.8
                                }

                                Column {
                                    width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium
                                    spacing: Theme.paddingSmall / 4

                                    Label {
                                        text: modelData.name
                                        color: Theme.primaryColor
                                        font.pixelSize: Theme.fontSizeSmall
                                        truncationMode: TruncationMode.Fade
                                        width: parent.width
                                    }

                                    Label {
                                        text: formatSize(modelData.size) + " • " + formatDownloads(modelData.downloadCount)
                                        color: Theme.secondaryColor
                                        font.pixelSize: Theme.fontSizeExtraSmall
                                    }
                                }
                            }

                            onClicked: {
                                var fileName = modelData.name
                                console.log("[QML] Downloading asset:", fileName)
                                console.log("[QML] Download URL:", modelData.downloadUrl)
                                console.log("[QML] Asset object:", JSON.stringify(modelData))
                                remorse.execute(delegate, "Downloading " + fileName, function() {
                                    githubApi.downloadReleaseAsset(modelData.downloadUrl, fileName)
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    RemorseItem {
        id: remorse
    }

    Connections {
        target: githubApi
        onAssetDownloadProgress: {
            if (bytesTotal > 0) {
                var progress = Math.floor((bytesReceived / bytesTotal) * 100)
                console.log("Download progress: " + progress + "%")
            }
        }
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        return (bytes / (1024 * 1024)).toFixed(1) + " MB"
    }

    function formatDownloads(count) {
        if (count === 1) return "1 download"
        if (count < 1000) return count + " downloads"
        if (count < 1000000) return (count / 1000).toFixed(1) + "k downloads"
        return (count / 1000000).toFixed(1) + "M downloads"
    }

    function formatDate(dateString) {
        var date = new Date(dateString)
        return Qt.formatDate(date, "MMM d, yyyy")
    }
}
