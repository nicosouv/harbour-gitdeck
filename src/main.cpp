#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>

#include "githubapi.h"
#include "oauthmanager.h"
#include "appsettings.h"
#include "models/repositorymodel.h"
#include "models/workflowrunmodel.h"
#include "models/releasemodel.h"
#include "models/issuemodel.h"
#include "models/pullrequestmodel.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setOrganizationName("harbour-gitdeck");
    app->setApplicationName("GitDeck");

    QScopedPointer<QQuickView> view(SailfishApp::createView());

    // Initialize core components
    AppSettings *settings = new AppSettings(app.data());
    GitHubAPI *api = new GitHubAPI(settings, app.data());
    OAuthManager *oauth = new OAuthManager(settings, app.data());

    // Initialize models
    RepositoryModel *repoModel = new RepositoryModel(app.data());
    WorkflowRunModel *workflowModel = new WorkflowRunModel(app.data());
    ReleaseModel *releaseModel = new ReleaseModel(app.data());
    IssueModel *issueModel = new IssueModel(app.data());
    PullRequestModel *prModel = new PullRequestModel(app.data());

    // Expose to QML
    QQmlContext *context = view->rootContext();
    context->setContextProperty("appSettings", settings);
    context->setContextProperty("githubApi", api);
    context->setContextProperty("oauthManager", oauth);
    context->setContextProperty("repositoryModel", repoModel);
    context->setContextProperty("workflowRunModel", workflowModel);
    context->setContextProperty("releaseModel", releaseModel);
    context->setContextProperty("issueModel", issueModel);
    context->setContextProperty("pullRequestModel", prModel);

    // Connect API signals to models
    QObject::connect(api, &GitHubAPI::repositoriesReceived,
                     repoModel, &RepositoryModel::loadFromJson);
    QObject::connect(api, &GitHubAPI::workflowRunsReceived,
                     workflowModel, &WorkflowRunModel::loadFromJson);
    QObject::connect(api, &GitHubAPI::releasesReceived,
                     releaseModel, &ReleaseModel::loadFromJson);
    QObject::connect(api, &GitHubAPI::releaseDeleted,
                     releaseModel, &ReleaseModel::removeById);
    QObject::connect(api, &GitHubAPI::issuesReceived,
                     issueModel, &IssueModel::loadFromJson);
    QObject::connect(api, &GitHubAPI::pullRequestsReceived,
                     prModel, &PullRequestModel::loadFromJson);

    view->setSource(SailfishApp::pathTo("qml/harbour-gitdeck.qml"));
    view->show();

    return app->exec();
}
