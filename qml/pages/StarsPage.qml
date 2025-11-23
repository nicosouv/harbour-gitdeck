import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: starsPage

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: starredModel


        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchStarredRepositories()
            }
        }

        header: PageHeader {
            title: "Starred Repositories"
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
            enabled: starredModel.count === 0 && !githubApi.loading
            text: "No starred repositories"
            hintText: "Star repositories to see them here"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && starredModel.count === 0
            size: BusyIndicatorSize.Large
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
