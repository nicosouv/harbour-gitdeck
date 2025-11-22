import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "../components"

Page {
    id: starsPage

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: starredModel

        // WebOS-style: smooth scrolling
        flickDeceleration: 1500
        maximumFlickVelocity: 2500

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: {
                    githubApi.fetchStarredRepositories()
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
                title: "Starred Repositories"

                // Subtle title animation on load
                opacity: 0
                Component.onCompleted: {
                    opacity = 1
                }
                Behavior on opacity {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
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
                topMargin: Theme.itemSizeHuge  // Below header
                left: parent.left
                right: parent.right
            }
            visible: githubApi.loading && starredModel.count === 0
            spacing: 0

            Repeater {
                model: 5
                RepositorySkeleton {}
            }
        }

        // Empty state
        ViewPlaceholder {
            enabled: starredModel.count === 0 && !githubApi.loading
            text: "No starred repositories"
            hintText: "Star repositories to see them here"

            // Fade in animation
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
            }
        }

        VerticalScrollDecorator {}
    }

    // Model for starred repos
    ListModel {
        id: starredModel
    }

    Component.onCompleted: {
        githubApi.fetchStarredRepositories()
    }

    Connections {
        target: githubApi
        onStarredRepositoriesReceived: {
            starredModel.clear()
            for (var i = 0; i < repos.length; i++) {
                var repo = repos[i]
                starredModel.append({
                    name: repo.name,
                    owner: repo.owner.login,
                    fullName: repo.full_name,
                    description: repo.description || "",
                    language: repo.language || "",
                    stars: repo.stargazers_count || 0,
                    forks: repo.forks_count || 0,
                    isPrivate: repo.private || false
                })
            }
        }
    }
}
