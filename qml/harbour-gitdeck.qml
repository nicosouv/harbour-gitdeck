import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "pages"
import "components"

ApplicationWindow {
    id: appWindow

    initialPage: Component {
        MainPage {}
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // Toast notification component
    Component {
        id: toastComponent
        Toast {}
    }

    function showNotification(message, isError) {
        var toast = toastComponent.createObject(appWindow, {
            message: message,
            isError: isError || false
        })
    }

    function showError(message) {
        showNotification(message, true)
    }

    Connections {
        target: githubApi
        onRequestError: showError(error)
        onAssetDownloadCompleted: {
            var fileName = filePath.split("/").pop()
            showNotification("Downloaded: " + fileName)
        }
    }

    Connections {
        target: oauthManager
        onAuthenticationSuccessful: {
            githubApi.fetchCurrentUser()
            githubApi.fetchUserRepositories()
            pageStack.replace(Qt.resolvedUrl("pages/MainPage.qml"))
        }
        onAuthenticationFailed: showError("Authentication failed: " + error)
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
