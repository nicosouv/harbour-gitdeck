import QtQuick 2.0
import Sailfish.Silica 1.0
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
                onClicked: githubApi.fetchUserRepositories()
            }
        }

        header: PageHeader {
            title: "Repositories"
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
