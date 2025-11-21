TARGET = harbour-gitdeck

CONFIG += sailfishapp
QT += network sql
CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp nemonotifications-qt5

# OAuth credentials - loaded from .qmake.conf
CLIENT_ID = $$gitdeck_client_id
CLIENT_SECRET = $$gitdeck_client_secret

isEmpty(CLIENT_ID) {
    warning("No GITDECK_CLIENT_ID defined - OAuth will not work")
    DEFINES += GITDECK_CLIENT_ID=\\\"\\\"
} else {
    DEFINES += GITDECK_CLIENT_ID=\\\"$$CLIENT_ID\\\"
}

isEmpty(CLIENT_SECRET) {
    warning("No GITDECK_CLIENT_SECRET defined - OAuth will not work")
    DEFINES += GITDECK_CLIENT_SECRET=\\\"\\\"
} else {
    DEFINES += GITDECK_CLIENT_SECRET=\\\"$$CLIENT_SECRET\\\"
}

SOURCES += \
    src/main.cpp \
    src/githubapi.cpp \
    src/oauthmanager.cpp \
    src/appsettings.cpp \
    src/models/repositorymodel.cpp \
    src/models/workflowrunmodel.cpp \
    src/models/releasemodel.cpp \
    src/models/issuemodel.cpp \
    src/models/pullrequestmodel.cpp

HEADERS += \
    src/githubapi.h \
    src/oauthmanager.h \
    src/appsettings.h \
    src/models/repositorymodel.h \
    src/models/workflowrunmodel.h \
    src/models/releasemodel.h \
    src/models/issuemodel.h \
    src/models/pullrequestmodel.h

DISTFILES += \
    qml/harbour-gitdeck.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/RepositoriesPage.qml \
    qml/pages/RepositoryPage.qml \
    qml/pages/WorkflowRunsPage.qml \
    qml/pages/WorkflowRunDetailPage.qml \
    qml/pages/ReleasesPage.qml \
    qml/pages/IssuesPage.qml \
    qml/pages/PullRequestsPage.qml \
    qml/pages/SettingsPage.qml \
    qml/components/RepositoryDelegate.qml \
    qml/components/WorkflowRunDelegate.qml \
    qml/components/ReleaseDelegate.qml \
    qml/components/IssueDelegate.qml \
    rpm/harbour-gitdeck.spec \
    rpm/harbour-gitdeck.yaml \
    rpm/harbour-gitdeck.changes \
    translations/*.ts \
    harbour-gitdeck.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# Translations
CONFIG += sailfishapp_i18n
TRANSLATIONS += \
    translations/harbour-gitdeck-en.ts \
    translations/harbour-gitdeck-fr.ts
