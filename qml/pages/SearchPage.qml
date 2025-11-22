import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: searchPage

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: searchResultsModel

        // WebOS-style smooth scrolling
        flickDeceleration: 1500
        maximumFlickVelocity: 2500

        header: Column {
            width: parent.width
            spacing: 0

            PageHeader {
                title: "Search Repositories"
            }

            // Search field
            SearchField {
                id: searchField
                width: parent.width
                placeholderText: "Search GitHub repositories"

                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if (text.length > 0) {
                        githubApi.searchRepositories(text)
                        searchField.focus = false
                    }
                }

                onTextChanged: {
                    if (text.length === 0) {
                        searchResultsModel.clear()
                    }
                }

                Component.onCompleted: {
                    forceActiveFocus()
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

        // Loading indicator
        BusyIndicator {
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: githubApi.loading && searchResultsModel.count === 0
        }

        // Empty state
        ViewPlaceholder {
            enabled: searchResultsModel.count === 0 && !githubApi.loading && searchField.text.length > 0
            text: "No repositories found"
            hintText: "Try a different search term"
        }

        ViewPlaceholder {
            enabled: searchResultsModel.count === 0 && !githubApi.loading && searchField.text.length === 0
            text: "Search GitHub"
            hintText: "Enter a search term to find repositories"
        }

        VerticalScrollDecorator {}
    }

    // Model for search results
    ListModel {
        id: searchResultsModel
    }

    Connections {
        target: githubApi
        onSearchResultsReceived: {
            searchResultsModel.clear()
            for (var i = 0; i < repos.length; i++) {
                var repo = repos[i]
                searchResultsModel.append({
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
