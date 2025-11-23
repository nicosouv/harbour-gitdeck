import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: browserPage

    property string repositoryOwner
    property string repositoryName
    property string currentPath: ""

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: ListModel {
            id: contentsModel
        }

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: {
                    var url = "https://github.com/" + repositoryOwner + "/" + repositoryName
                    if (currentPath) url += "/tree/main/" + currentPath
                    Qt.openUrlExternally(url)
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: loadContents()
            }
        }

        header: PageHeader {
            title: currentPath || "Repository"
            description: repositoryName
        }

        delegate: BackgroundItem {
            height: Theme.itemSizeSmall

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingMedium

                Image {
                    source: model.type === "dir" ? "image://theme/icon-m-file-folder" : "image://theme/icon-m-file-document"
                    width: Theme.iconSizeSmall
                    height: Theme.iconSizeSmall
                }

                Label {
                    text: model.name
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                if (model.type === "dir") {
                    pageStack.push(Qt.resolvedUrl("RepositoryBrowserPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName,
                        currentPath: model.path
                    })
                } else {
                    pageStack.push(Qt.resolvedUrl("FileViewerPage.qml"), {
                        repositoryOwner: repositoryOwner,
                        repositoryName: repositoryName,
                        filePath: model.path,
                        fileName: model.name
                    })
                }
            }
        }

        ViewPlaceholder {
            enabled: contentsModel.count === 0 && !githubApi.loading
            text: "Empty directory"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Connections {
        target: githubApi
        onRepositoryContentsReceived: {
            contentsModel.clear()
            for (var i = 0; i < contents.length; i++) {
                var item = contents[i]
                contentsModel.append({
                    name: item.name,
                    path: item.path,
                    type: item.type
                })
            }
        }
    }

    Component.onCompleted: loadContents()

    function loadContents() {
        contentsModel.clear()
        githubApi.fetchRepositoryContents(repositoryOwner, repositoryName, currentPath)
    }
}
