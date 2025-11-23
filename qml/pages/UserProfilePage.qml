import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: userProfilePage

    property string username
    property var userData: null
    property var userRepos: []
    property int followersCount: 0
    property int followingCount: 0

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Open in browser"
                onClicked: Qt.openUrlExternally("https://github.com/" + username)
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: username
            }

            Column {
                width: parent.width
                spacing: Theme.paddingMedium
                visible: userData

                Rectangle {
                    width: Theme.iconSizeExtraLarge
                    height: Theme.iconSizeExtraLarge
                    radius: width / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: userData ? userData.avatar_url : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                Label {
                    text: userData ? userData.name || username : ""
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: userData && userData.bio ? userData.bio : ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    horizontalAlignment: Text.AlignHCenter
                    visible: userData && userData.bio
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingLarge

                    Column {
                        spacing: Theme.paddingSmall / 2

                        Label {
                            text: followersCount
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            text: "Followers"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {
                        spacing: Theme.paddingSmall / 2

                        Label {
                            text: followingCount
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            text: "Following"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {
                        spacing: Theme.paddingSmall / 2

                        Label {
                            text: userData ? userData.public_repos : 0
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            text: "Repos"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                    }
                    spacing: Theme.paddingMedium
                    visible: userData && (userData.location || userData.company)

                    Label {
                        text: userData && userData.location ? "📍 " + userData.location : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        visible: userData && userData.location
                    }

                    Label {
                        text: userData && userData.company ? "🏢 " + userData.company : ""
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        visible: userData && userData.company
                    }
                }
            }

            SectionHeader {
                text: "Public Repositories"
                visible: userRepos.length > 0
            }

            Repeater {
                model: userRepos
                delegate: RepositoryDelegate {
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("RepositoryPage.qml"), {
                            repositoryName: modelData.name,
                            repositoryOwner: modelData.owner.login,
                            repositoryFullName: modelData.full_name,
                            repositoryDescription: modelData.description || ""
                        })
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: githubApi.loading && !userData
        size: BusyIndicatorSize.Large
    }

    Connections {
        target: githubApi
        onUserReceived: {
            userData = user
        }
        onUserFollowersReceived: {
            followersCount = followers.length
        }
        onUserFollowingReceived: {
            followingCount = following.length
        }
        onUserPublicReposReceived: {
            userRepos = []
            for (var i = 0; i < Math.min(repos.length, 10); i++) {
                userRepos.push(repos[i])
            }
            userRepos = userRepos
        }
    }

    Component.onCompleted: {
        githubApi.fetchUser(username)
        githubApi.fetchUserFollowers(username)
        githubApi.fetchUserFollowing(username)
        githubApi.fetchUserPublicRepos(username)
    }
}
