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
    request.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);

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
    qDebug() << "[API] GET request:" << request.url().toString();
    qDebug() << "[API] Request type:" << requestType;
    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", requestType);

    connect(reply, &QNetworkReply::finished, this, &GitHubAPI::onRequestFinished);
}

void GitHubAPI::post(const QString &endpoint, const QString &requestType, const QByteArray &data)
{
    setLoading(true);
    QNetworkRequest request = createRequest(endpoint);
    if (!data.isEmpty()) {
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    }
    qDebug() << "[API] POST request:" << request.url().toString();
    qDebug() << "[API] Request type:" << requestType;
    QNetworkReply *reply = m_networkManager->post(request, data);
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
    qDebug() << "[API] Response for:" << requestType;
    qDebug() << "[API] URL:" << reply->url().toString();
    qDebug() << "[API] Error:" << reply->error();
    qDebug() << "[API] HTTP Status:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

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
        qWarning() << "[API] Error:" << errorMsg;
        qWarning() << "[API] Error details:" << reply->readAll();
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
    } else if (requestType == "workflowArtifacts") {
        emit workflowArtifactsReceived(doc.object()["artifacts"].toArray());
    } else if (requestType == "rerunWorkflow") {
        qDebug() << "[Workflow] Workflow rerun initiated";
        emit requestError(""); // Success notification
    } else if (requestType == "cancelWorkflow") {
        qDebug() << "[Workflow] Workflow cancelled";
        emit requestError(""); // Success notification
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
    } else if (requestType == "readme") {
        QJsonObject obj = doc.object();
        QString content = QByteArray::fromBase64(obj["content"].toString().toUtf8());
        qDebug() << "[README] Received README, size:" << content.size();
        emit readmeReceived(content);
    } else if (requestType == "commits") {
        emit commitsReceived(doc.array());
    } else if (requestType == "commit") {
        emit commitReceived(doc.object());
    } else if (requestType == "branches") {
        emit branchesReceived(doc.array());
    } else if (requestType == "issueComments") {
        emit issueCommentsReceived(doc.array());
    } else if (requestType == "pullRequestComments") {
        emit pullRequestCommentsReceived(doc.array());
    } else if (requestType == "notifications") {
        emit notificationsReceived(doc.array());
    } else if (requestType == "contributors") {
        emit contributorsReceived(doc.array());
    } else if (requestType == "user") {
        emit userReceived(doc.object());
    } else if (requestType == "userFollowers") {
        emit userFollowersReceived(doc.array());
    } else if (requestType == "userFollowing") {
        emit userFollowingReceived(doc.array());
    } else if (requestType == "userPublicRepos") {
        emit userPublicReposReceived(doc.array());
    } else if (requestType == "repositoryLabels") {
        emit repositoryLabelsReceived(doc.array());
    } else if (requestType == "repositoryMilestones") {
        emit repositoryMilestonesReceived(doc.array());
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

void GitHubAPI::fetchWorkflowRunDetails(const QString &owner, const QString &repo, qint64 runId)
{
    get(QString("/repos/%1/%2/actions/runs/%3").arg(owner, repo).arg(runId), "workflowRunDetails");
}

void GitHubAPI::fetchWorkflowRunJobs(const QString &owner, const QString &repo, qint64 runId)
{
    QString endpoint = QString("/repos/%1/%2/actions/runs/%3/jobs").arg(owner, repo).arg(runId);
    qDebug() << "[Workflow] Fetching jobs for run:" << runId;
    qDebug() << "[Workflow] Endpoint:" << endpoint;
    get(endpoint, "workflowJobs");
}

void GitHubAPI::fetchWorkflowRunArtifacts(const QString &owner, const QString &repo, qint64 runId)
{
    qDebug() << "[Workflow] Fetching artifacts for run:" << runId;
    get(QString("/repos/%1/%2/actions/runs/%3/artifacts").arg(owner, repo).arg(runId), "workflowArtifacts");
}

void GitHubAPI::downloadWorkflowArtifact(const QString &owner, const QString &repo, qint64 artifactId, const QString &fileName)
{
    qDebug() << "[Workflow] Downloading artifact:" << artifactId << fileName;
    QString endpoint = QString("/repos/%1/%2/actions/artifacts/%3/zip").arg(owner, repo).arg(artifactId);

    setLoading(true);
    QNetworkRequest req = createRequest(endpoint);

    QNetworkReply *reply = m_networkManager->get(req);
    reply->setProperty("requestType", "downloadArtifact");
    reply->setProperty("fileName", fileName);

    connect(reply, &QNetworkReply::downloadProgress, this, &GitHubAPI::onDownloadProgress);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[Workflow] Download finished, status:" << statusCode;

        // Handle redirect manually for Qt 5.6 compatibility
        if (statusCode == 302 || statusCode == 301) {
            QUrl redirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
            qDebug() << "[Workflow] Following redirect to:" << redirectUrl.toString();

            QString fileName = reply->property("fileName").toString();
            reply->deleteLater();

            QNetworkRequest redirectReq(redirectUrl);
            QNetworkReply *redirectReply = m_networkManager->get(redirectReq);
            redirectReply->setProperty("fileName", fileName);

            connect(redirectReply, &QNetworkReply::finished, this, [this, redirectReply]() {
                if (redirectReply->error() == QNetworkReply::NoError) {
                    QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
                    QString fileName = redirectReply->property("fileName").toString();
                    QString filePath = downloadsPath + "/" + fileName;

                    QFile file(filePath);
                    if (file.open(QIODevice::WriteOnly)) {
                        file.write(redirectReply->readAll());
                        file.close();
                        qDebug() << "[Workflow] Artifact downloaded:" << filePath;
                        emit assetDownloadCompleted(filePath);
                    } else {
                        emit requestError("Failed to save artifact: " + fileName);
                    }
                } else {
                    emit requestError("Artifact download failed: " + redirectReply->errorString());
                }
                redirectReply->deleteLater();
                setLoading(false);
            });
            return;
        }

        if (reply->error() == QNetworkReply::NoError) {
            QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
            QString fileName = reply->property("fileName").toString();
            QString filePath = downloadsPath + "/" + fileName;

            QFile file(filePath);
            if (file.open(QIODevice::WriteOnly)) {
                file.write(reply->readAll());
                file.close();
                qDebug() << "[Workflow] Artifact downloaded:" << filePath;
                emit assetDownloadCompleted(filePath);
            } else {
                emit requestError("Failed to save artifact: " + fileName);
            }
        } else {
            emit requestError("Artifact download failed: " + reply->errorString());
        }
        reply->deleteLater();
        setLoading(false);
    });
}

void GitHubAPI::rerunWorkflow(const QString &owner, const QString &repo, qint64 runId)
{
    qDebug() << "[Workflow] Re-running workflow:" << runId;
    post(QString("/repos/%1/%2/actions/runs/%3/rerun").arg(owner, repo).arg(runId), "rerunWorkflow");
}

void GitHubAPI::cancelWorkflow(const QString &owner, const QString &repo, qint64 runId)
{
    qDebug() << "[Workflow] Cancelling workflow:" << runId;
    post(QString("/repos/%1/%2/actions/runs/%3/cancel").arg(owner, repo).arg(runId), "cancelWorkflow");
}

// Releases API
void GitHubAPI::fetchReleases(const QString &owner, const QString &repo)
{
    get(QString("/repos/%1/%2/releases?per_page=30").arg(owner, repo), "releases");
}

void GitHubAPI::downloadReleaseAsset(const QString &assetUrl, const QString &fileName)
{
    setLoading(true);

    qDebug() << "[Download] Starting download";
    qDebug() << "[Download] Asset URL:" << assetUrl;
    qDebug() << "[Download] File name:" << fileName;

    QUrl url(assetUrl);
    QNetworkRequest req(url);
    req.setRawHeader("Accept", "application/octet-stream");
    req.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);

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
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[Download] Finished with error:" << reply->error();
        qDebug() << "[Download] Error string:" << reply->errorString();
        qDebug() << "[Download] HTTP status:" << statusCode;
        qDebug() << "[Download] Final URL:" << reply->url().toString();

        // Handle redirect manually for Qt 5.6 compatibility
        if (statusCode == 302 || statusCode == 301) {
            QUrl redirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
            qDebug() << "[Download] Following redirect to:" << redirectUrl.toString();

            QString fileName = reply->property("fileName").toString();
            reply->deleteLater();

            // Follow the redirect without authentication headers
            QNetworkRequest redirectReq(redirectUrl);
            QNetworkReply *redirectReply = m_networkManager->get(redirectReq);
            redirectReply->setProperty("fileName", fileName);

            connect(redirectReply, &QNetworkReply::finished, this, [this, redirectReply]() {
                qDebug() << "[Download] Redirect finished with error:" << redirectReply->error();
                qDebug() << "[Download] Redirect HTTP status:" << redirectReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

                if (redirectReply->error() == QNetworkReply::NoError) {
                    QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
                    QString fileName = redirectReply->property("fileName").toString();
                    QString filePath = downloadsPath + "/" + fileName;

                    QByteArray data = redirectReply->readAll();
                    qDebug() << "[Download] Downloaded:" << data.size() << "bytes";

                    QFile file(filePath);
                    if (file.open(QIODevice::WriteOnly)) {
                        qint64 written = file.write(data);
                        file.close();
                        qDebug() << "[Download] File saved successfully";
                        emit assetDownloadCompleted(filePath);
                    } else {
                        qDebug() << "[Download] Failed to open file:" << file.errorString();
                        emit requestError("Failed to save file: " + fileName);
                    }
                } else {
                    emit requestError("Download failed: " + redirectReply->errorString());
                }
                redirectReply->deleteLater();
                setLoading(false);
            });
            return;
        }

        if (reply->error() == QNetworkReply::NoError) {
            QString downloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
            QString fileName = reply->property("fileName").toString();
            QString filePath = downloadsPath + "/" + fileName;

            qDebug() << "[Download] Downloads path:" << downloadsPath;
            qDebug() << "[Download] Full file path:" << filePath;

            QByteArray data = reply->readAll();
            qDebug() << "[Download] Data size:" << data.size() << "bytes";

            QFile file(filePath);
            if (file.open(QIODevice::WriteOnly)) {
                qint64 written = file.write(data);
                file.close();
                qDebug() << "[Download] Written:" << written << "bytes";
                qDebug() << "[Download] File saved successfully";
                emit assetDownloadCompleted(filePath);
            } else {
                qDebug() << "[Download] Failed to open file:" << file.errorString();
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

void GitHubAPI::fetchReadme(const QString &owner, const QString &repo)
{
    qDebug() << "[README] Fetching README for" << owner << "/" << repo;
    get(QString("/repos/%1/%2/readme").arg(owner, repo), "readme");
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

// Branches API
void GitHubAPI::fetchBranches(const QString &owner, const QString &repo)
{
    qDebug() << "[Branches] Fetching branches for" << owner << "/" << repo;
    get(QString("/repos/%1/%2/branches?per_page=100").arg(owner, repo), "branches");
}

// Comments API
void GitHubAPI::fetchIssueComments(const QString &owner, const QString &repo, int issueNumber)
{
    qDebug() << "[Comments] Fetching issue comments for" << issueNumber;
    get(QString("/repos/%1/%2/issues/%3/comments").arg(owner, repo).arg(issueNumber), "issueComments");
}

void GitHubAPI::fetchPullRequestComments(const QString &owner, const QString &repo, int prNumber)
{
    qDebug() << "[Comments] Fetching PR comments for" << prNumber;
    get(QString("/repos/%1/%2/pulls/%3/comments").arg(owner, repo).arg(prNumber), "pullRequestComments");
}

// Notifications API
void GitHubAPI::fetchNotifications()
{
    qDebug() << "[Notifications] Fetching notifications";
    get("/notifications?per_page=50", "notifications");
}

// Contributors API
void GitHubAPI::fetchContributors(const QString &owner, const QString &repo)
{
    qDebug() << "[Contributors] Fetching contributors for" << owner << "/" << repo;
    get(QString("/repos/%1/%2/contributors?per_page=100").arg(owner, repo), "contributors");
}

// User API
void GitHubAPI::fetchUser(const QString &username)
{
    qDebug() << "[User] Fetching user profile for" << username;
    get(QString("/users/%1").arg(username), "user");
}

void GitHubAPI::fetchUserFollowers(const QString &username)
{
    qDebug() << "[User] Fetching followers for" << username;
    get(QString("/users/%1/followers?per_page=100").arg(username), "userFollowers");
}

void GitHubAPI::fetchUserFollowing(const QString &username)
{
    qDebug() << "[User] Fetching following for" << username;
    get(QString("/users/%1/following?per_page=100").arg(username), "userFollowing");
}

void GitHubAPI::fetchUserPublicRepos(const QString &username)
{
    qDebug() << "[User] Fetching public repos for" << username;
    get(QString("/users/%1/repos?per_page=100&sort=updated").arg(username), "userPublicRepos");
}

// Labels and Milestones API
void GitHubAPI::fetchRepositoryLabels(const QString &owner, const QString &repo)
{
    qDebug() << "[Labels] Fetching labels for" << owner << "/" << repo;
    get(QString("/repos/%1/%2/labels?per_page=100").arg(owner, repo), "repositoryLabels");
}

void GitHubAPI::fetchRepositoryMilestones(const QString &owner, const QString &repo)
{
    qDebug() << "[Milestones] Fetching milestones for" << owner << "/" << repo;
    get(QString("/repos/%1/%2/milestones?per_page=100&state=all").arg(owner, repo), "repositoryMilestones");
}
