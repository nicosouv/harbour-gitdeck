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

        // WebOS-style: smooth scrolling
        flickDeceleration: 1500
        maximumFlickVelocity: 2500

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: "Notifications"
                onClicked: pageStack.push(Qt.resolvedUrl("NotificationsPage.qml"))
            }
            MenuItem {
                text: "Starred"
                onClicked: pageStack.push(Qt.resolvedUrl("StarsPage.qml"))
            }
            MenuItem {
                text: "Search"
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
            MenuItem {
                text: "Refresh"
                onClicked: {
                    githubApi.fetchUserRepositories()
                    refreshAnimation.start()
                }
            }
        }

        // Subtle refresh animation
        SequentialAnimation {
            id: refreshAnimation
            NumberAnimation {
                target: listView
                property: "opacity"
                to: 0.5
                duration: 150
            }
            NumberAnimation {
                target: listView
                property: "opacity"
                to: 1.0
                duration: 150
            }
        }

        header: Column {
            width: parent.width
            spacing: 0

            PageHeader {
                title: "Repositories"

                // Subtle title animation on load
                opacity: 0
                Component.onCompleted: {
                    opacity = 1
                }
                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }

            // User info banner - WebOS card style
            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium
                visible: appSettings.isAuthenticated

                Rectangle {
                    anchors.fill: parent
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.05)
                    opacity: parent.highlighted ? 1.0 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }

                Row {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium

                    // Avatar with smooth loading
                    Item {
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                            visible: avatarImage.status !== Image.Ready
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            clip: true
                            color: "transparent"

                            Image {
                                id: avatarImage
                                anchors.fill: parent
                                source: appSettings.avatarUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true

                                opacity: status === Image.Ready ? 1.0 : 0.0
                                Behavior on opacity {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                }
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingSmall / 2

                        Label {
                            text: appSettings.username || "User"
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                        }

                        Label {
                            text: repositoryModel.count + " " + (repositoryModel.count === 1 ? "repository" : "repositories")
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }

                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.primaryColor
                opacity: 0.1
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

        // Skeleton loaders while loading
        Column {
            anchors {
                top: parent.top
                topMargin: Theme.itemSizeHuge * 2  // Below header
                left: parent.left
                right: parent.right
            }
            visible: githubApi.loading && repositoryModel.count === 0
            spacing: 0

            Repeater {
                model: 5
                RepositorySkeleton {}
            }
        }

        // Empty state with better design
        ViewPlaceholder {
            enabled: repositoryModel.count === 0 && !githubApi.loading
            text: "No repositories"
            hintText: "Pull down to refresh"

            // Fade in animation
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
            }
        }

        VerticalScrollDecorator {}
    }
}
