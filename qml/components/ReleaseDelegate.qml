import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    contentHeight: column.height + Theme.paddingLarge

    property string repositoryOwner
    property string repositoryName

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        spacing: Theme.paddingSmall

        Row {
            width: parent.width
            spacing: Theme.paddingSmall

            Label {
                text: tagName
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
            }

            Label {
                text: isPrerelease ? "Pre-release" : ""
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: isPrerelease
            }

            Label {
                text: isDraft ? "Draft" : ""
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                visible: isDraft
            }
        }

        Label {
            width: parent.width
            text: name || tagName
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            visible: name && name !== tagName
        }

        Label {
            width: parent.width
            text: formatDate(publishedAt)
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
            width: parent.width
            text: body
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            maximumLineCount: 4
            truncationMode: TruncationMode.Fade
            visible: body
        }

        // Assets
        SectionHeader {
            text: "Assets (" + assets.length + ")"
            visible: assets.length > 0
        }

        Column {
            width: parent.width
            spacing: 0
            visible: assets.length > 0

            Repeater {
                model: assets
                delegate: BackgroundItem {
                    width: parent.width
                    height: Theme.itemSizeSmall

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: Theme.paddingMedium

                        Image {
                            source: "image://theme/icon-m-file-rpm"
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
                                text: formatSize(modelData.size) + " • " + modelData.downloadCount + " downloads"
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }
                    }

                    onClicked: {
                        var fileName = modelData.name
                        remorse.execute(delegate, "Downloading " + fileName, function() {
                            githubApi.downloadReleaseAsset(modelData.downloadUrl, fileName)
                        })
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

    function formatDate(dateString) {
        var date = new Date(dateString)
        return Qt.formatDate(date, "MMM d, yyyy")
    }
}
