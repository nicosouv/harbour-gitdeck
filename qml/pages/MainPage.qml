import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "../components"

Page {
    id: mainPage

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: repositoryModel

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchUserRepositories()
            }
        }

        header: Column {
            width: parent.width
            spacing: 0

            PageHeader {
                title: "Repositories"
            }

            // User info banner
            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium
                visible: appSettings.isAuthenticated

                Row {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    Image {
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                        source: appSettings.avatarUrl || "image://theme/icon-m-contact"
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: Theme.iconSizeMedium
                                height: Theme.iconSizeMedium
                                radius: width / 2
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: appSettings.username || "User"
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        Label {
                            text: repositoryModel.count + " repositories"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }

                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }

            // Search field
            SearchField {
                width: parent.width
                placeholderText: "Search repositories"
                visible: repositoryModel.count > 0

                onTextChanged: {
                    // TODO: Implement search filtering
                }
            }
        }

        delegate: RepositoryDelegate {
            onClicked: {
                pageStack.push(Qt.resolvedUrl("RepositoryPage.qml"), {
                    repositoryName: name,
                    repositoryOwner: owner,
                    repositoryFullName: fullName,
                    repositoryDescription: description
                })
            }
        }

        ViewPlaceholder {
            enabled: repositoryModel.count === 0 && !githubApi.loading
            text: "No repositories"
            hintText: "Pull down to refresh"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && repositoryModel.count === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }
}
