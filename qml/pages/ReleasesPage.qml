import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: releasesPage

    property string repositoryOwner
    property string repositoryName

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: releaseModel

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                onClicked: githubApi.fetchReleases(repositoryOwner, repositoryName)
            }
        }

        header: PageHeader {
            title: "Releases"
            description: repositoryName
        }

        delegate: ReleaseDelegate {
            repositoryOwner: releasesPage.repositoryOwner
            repositoryName: releasesPage.repositoryName
        }

        ViewPlaceholder {
            enabled: releaseModel.count === 0 && !githubApi.loading
            text: "No releases"
            hintText: "This repository has no published releases"
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: githubApi.loading && releaseModel.count === 0
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        releaseModel.clear()
        githubApi.fetchReleases(repositoryOwner, repositoryName)
    }
}
