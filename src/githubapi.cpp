#include "githubapi.h"
#include "appsettings.h"
#include <QNetworkRequest>
#include <QUrlQuery>
#include <QFile>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

GitHubAPI::GitHubAPI(AppSettings *settings, QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_settings(settings)
    , m_loading(false)
{
}

void GitHubAPI::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

QNetworkRequest GitHubAPI::createRequest(const QString &endpoint)
{
    QUrl url("https://api.github.com" + endpoint);
    QNetworkRequest request(url);

    request.setRawHeader("Accept", "application/vnd.github+json");
    request.setRawHeader("X-GitHub-Api-Version", "2022-11-28");

    if (!m_settings->accessToken().isEmpty()) {
        request.setRawHeader("Authorization",
            QString("Bearer %1").arg(m_settings->accessToken()).toUtf8());
    }

    return request;
}

void GitHubAPI::get(const QString &endpoint, const QString &requestType)
{
    setLoading(true);
    QNetworkRequest request = createRequest(endpoint);
    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", requestType);

    connect(reply, &QNetworkReply::finished, this, &GitHubAPI::onRequestFinished);
}

void GitHubAPI::put(const QString &endpoint, const QString &requestType)
{
    setLoading(true);
    QNetworkRequest request = createRequest(endpoint);
    request.setHeader(QNetworkRequest::ContentLengthHeader, 0);
    QNetworkReply *reply = m_networkManager->put(request, QByteArray());
    reply->setProperty("requestType", requestType);

    connect(reply, &QNetworkReply::finished, this, &GitHubAPI::onRequestFinished);
}

void GitHubAPI::deleteRequest(const QString &endpoint, const QString &requestType)
{
    setLoading(true);
    QNetworkRequest request = createRequest(endpoint);
    QNetworkReply *reply = m_networkManager->deleteResource(request);
    reply->setProperty("requestType", requestType);

    connect(reply, &QNetworkReply::finished, this, &GitHubAPI::onRequestFinished);
}

void GitHubAPI::onRequestFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString requestType = reply->property("requestType").toString();
    handleResponse(reply, requestType);

    reply->deleteLater();
    setLoading(false);
}

void GitHubAPI::handleResponse(QNetworkReply *reply, const QString &requestType)
{
    // Handle star/unstar operations (they return 204 No Content on success)
    if (requestType == "starRepository" || requestType == "unstarRepository") {
        if (reply->error() == QNetworkReply::NoError) {
            QString endpoint = reply->url().path();
            QStringList parts = endpoint.split('/');
            if (parts.size() >= 4) {
                QString owner = parts[parts.size() - 2];
                QString repo = parts[parts.size() - 1];
                if (requestType == "starRepository") {
                    emit repositoryStarred(owner, repo);
                } else {
                    emit repositoryUnstarred(owner, repo);
                }
            }
        } else {
            emit requestError(reply->errorString());
        }
        return;
    }

    if (reply->error() != QNetworkReply::NoError) {
        QString errorMsg = reply->errorString();
        qWarning() << "API Error:" << errorMsg;
        emit requestError(errorMsg);
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (requestType == "currentUser") {
        emit currentUserReceived(doc.object());
    } else if (requestType == "repositories") {
        emit repositoriesReceived(doc.array());
    } else if (requestType == "starredRepositories") {
        emit starredRepositoriesReceived(doc.array());
    } else if (requestType == "searchResults") {
        emit searchResultsReceived(doc.object()["items"].toArray());
    } else if (requestType == "repository") {
        emit repositoryReceived(doc.object());
    } else if (requestType == "workflowRuns") {
        emit workflowRunsReceived(doc.object()["workflow_runs"].toArray());
    } else if (requestType == "workflowRunDetails") {
        emit workflowRunDetailsReceived(doc.object());
    } else if (requestType == "workflowJobs") {
        emit workflowJobsReceived(doc.object()["jobs"].toArray());
    } else if (requestType == "releases") {
        emit releasesReceived(doc.array());
    } else if (requestType == "issues") {
        emit issuesReceived(doc.array());
    } else if (requestType == "issue") {
        emit issueReceived(doc.object());
    } else if (requestType == "pullRequests") {
        emit pullRequestsReceived(doc.array());
    } else if (requestType == "pullRequest") {
        emit pullRequestReceived(doc.object());
    } else if (requestType == "contents") {
        if (doc.isArray()) {
            emit repositoryContentsReceived(doc.array());
        } else {
            emit fileContentReceived(doc.object());
        }
    } else if (requestType == "commits") {
        emit commitsReceived(doc.array());
    } else if (requestType == "commit") {
        emit commitReceived(doc.object());
    }
}

// User API
void GitHubAPI::fetchCurrentUser()
{
    get("/user", "currentUser");
}

void GitHubAPI::fetchUserRepositories()
{
    get("/user/repos?sort=updated&per_page=100", "repositories");
}

void GitHubAPI::fetchStarredRepositories()
{
    get("/user/starred?per_page=100", "starredRepositories");
}

// Repository API
void GitHubAPI::fetchRepository(const QString &owner, const QString &repo)
{
    get(QString("/repos/%1/%2").arg(owner, repo), "repository");
}

void GitHubAPI::searchRepositories(const QString &query)
{
    QString encodedQuery = QUrl::toPercentEncoding(query);
    get(QString("/search/repositories?q=%1&per_page=30").arg(encodedQuery), "searchResults");
}

void GitHubAPI::starRepository(const QString &owner, const QString &repo)
{
    put(QString("/user/starred/%1/%2").arg(owner, repo), "starRepository");
}

void GitHubAPI::unstarRepository(const QString &owner, const QString &repo)
{
    deleteRequest(QString("/user/starred/%1/%2").arg(owner, repo), "unstarRepository");
}

void GitHubAPI::checkIfStarred(const QString &owner, const QString &repo)
{
    QNetworkRequest request = createRequest(QString("/user/starred/%1/%2").arg(owner, repo));
    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "checkStarred");
    reply->setProperty("owner", owner);
    reply->setProperty("repo", repo);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QString owner = reply->property("owner").toString();
        QString repo = reply->property("repo").toString();
        bool isStarred = (reply->error() == QNetworkReply::NoError);
        emit repositoryStarStatusReceived(isStarred, owner, repo);
        reply->deleteLater();
    });
}

void GitHubAPI::fetchRepositoryWorkflowRuns(const QString &owner, const QString &repo)
{
    get(QString("/repos/%1/%2/actions/runs?per_page=50").arg(owner, repo), "workflowRuns");
}

void GitHubAPI::fetchWorkflowRunDetails(const QString &owner, const QString &repo, int runId)
{
    get(QString("/repos/%1/%2/actions/runs/%3").arg(owner, repo).arg(runId), "workflowRunDetails");
}

void GitHubAPI::fetchWorkflowRunJobs(const QString &owner, const QString &repo, int runId)
{
    get(QString("/repos/%1/%2/actions/runs/%3/jobs").arg(owner, repo).arg(runId), "workflowJobs");
}

// Releases API
void GitHubAPI::fetchReleases(const QString &owner, const QString &repo)
{
    get(QString("/repos/%1/%2/releases?per_page=30").arg(owner, repo), "releases");
}

void GitHubAPI::downloadReleaseAsset(const QString &assetUrl, const QString &fileName)
{
    setLoading(true);

    QUrl url(assetUrl);
    QNetworkRequest req(url);
    req.setRawHeader("Accept", "application/octet-stream");

    if (!m_settings->accessToken().isEmpty()) {
        req.setRawHeader("Authorization",
            QString("Bearer %1").arg(m_settings->accessToken()).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(req);
    reply->setProperty("requestType", "downloadAsset");
    reply->setProperty("fileName", fileName);

    connect(reply, &QNetworkReply::downloadProgress,
            this, &GitHubAPI::onDownloadProgress);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
            QString fileName = reply->property("fileName").toString();
            QString filePath = downloadsPath + "/" + fileName;

            QFile file(filePath);
            if (file.open(QIODevice::WriteOnly)) {
                file.write(reply->readAll());
                file.close();
                emit assetDownloadCompleted(filePath);
            } else {
                emit requestError("Failed to save file: " + fileName);
            }
        } else {
            emit requestError("Download failed: " + reply->errorString());
        }
        reply->deleteLater();
        setLoading(false);
    });
}

void GitHubAPI::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    emit assetDownloadProgress(bytesReceived, bytesTotal);
}

// Issues API
void GitHubAPI::fetchIssues(const QString &owner, const QString &repo)
{
    get(QString("/repos/%1/%2/issues?state=all&per_page=50").arg(owner, repo), "issues");
}

void GitHubAPI::fetchIssue(const QString &owner, const QString &repo, int issueNumber)
{
    get(QString("/repos/%1/%2/issues/%3").arg(owner, repo).arg(issueNumber), "issue");
}

// Pull Requests API
void GitHubAPI::fetchPullRequests(const QString &owner, const QString &repo)
{
    get(QString("/repos/%1/%2/pulls?state=all&per_page=50").arg(owner, repo), "pullRequests");
}

void GitHubAPI::fetchPullRequest(const QString &owner, const QString &repo, int prNumber)
{
    get(QString("/repos/%1/%2/pulls/%3").arg(owner, repo).arg(prNumber), "pullRequest");
}

// Repository Content API
void GitHubAPI::fetchRepositoryContents(const QString &owner, const QString &repo, const QString &path)
{
    QString endpoint = QString("/repos/%1/%2/contents").arg(owner, repo);
    if (!path.isEmpty()) {
        endpoint += "/" + path;
    }
    get(endpoint, "contents");
}

void GitHubAPI::fetchFileContent(const QString &owner, const QString &repo, const QString &path)
{
    get(QString("/repos/%1/%2/contents/%3").arg(owner, repo, path), "contents");
}

// Commits API
void GitHubAPI::fetchCommits(const QString &owner, const QString &repo, const QString &branch)
{
    QString endpoint = QString("/repos/%1/%2/commits?per_page=50").arg(owner, repo);
    if (!branch.isEmpty()) {
        endpoint += "&sha=" + branch;
    }
    get(endpoint, "commits");
}

void GitHubAPI::fetchCommit(const QString &owner, const QString &repo, const QString &sha)
{
    get(QString("/repos/%1/%2/commits/%3").arg(owner, repo, sha), "commit");
}
