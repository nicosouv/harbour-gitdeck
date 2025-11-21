import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
    id: appWindow

    initialPage: Component {
        MainPage {}
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // Global notification banner
    Component {
        id: notificationComponent
        Label {
            anchors.centerIn: parent
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeMedium
        }
    }

    function showNotification(message) {
        var banner = notificationComponent.createObject(appWindow, { text: message })
        banner.opacity = 1.0
        fadeAnimation.target = banner
        fadeAnimation.start()
    }

    NumberAnimation {
        id: fadeAnimation
        property: "opacity"
        from: 1.0
        to: 0.0
        duration: 3000
        onStopped: {
            if (target) target.destroy()
        }
    }

    Connections {
        target: githubApi
        onRequestError: showNotification(error)
        onAssetDownloadCompleted: showNotification("Downloaded: " + filePath)
    }

    Connections {
        target: oauthManager
        onAuthenticationSuccessful: {
            githubApi.fetchCurrentUser()
            pageStack.replace(Qt.resolvedUrl("pages/MainPage.qml"))
        }
        onAuthenticationFailed: showNotification("Auth failed: " + error)
    }

    Connections {
        target: githubApi
        onCurrentUserReceived: {
            appSettings.setUsername(user.login)
            appSettings.setAvatarUrl(user.avatar_url)
        }
    }

    Component.onCompleted: {
        if (!appSettings.isAuthenticated) {
            pageStack.replace(Qt.resolvedUrl("pages/LoginPage.qml"))
        } else {
            githubApi.fetchCurrentUser()
            githubApi.fetchUserRepositories()
        }
    }
}
