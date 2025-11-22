#ifndef GITHUBAPI_H
#define GITHUBAPI_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class AppSettings;

class GitHubAPI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit GitHubAPI(AppSettings *settings, QObject *parent = nullptr);

    bool loading() const { return m_loading; }

    // User API
    Q_INVOKABLE void fetchCurrentUser();
    Q_INVOKABLE void fetchUserRepositories();
    Q_INVOKABLE void fetchStarredRepositories();

    // Repository API
    Q_INVOKABLE void fetchRepository(const QString &owner, const QString &repo);
    Q_INVOKABLE void searchRepositories(const QString &query);
    Q_INVOKABLE void starRepository(const QString &owner, const QString &repo);
    Q_INVOKABLE void unstarRepository(const QString &owner, const QString &repo);
    Q_INVOKABLE void checkIfStarred(const QString &owner, const QString &repo);
    Q_INVOKABLE void fetchRepositoryWorkflowRuns(const QString &owner, const QString &repo);
    Q_INVOKABLE void fetchWorkflowRunDetails(const QString &owner, const QString &repo, int runId);
    Q_INVOKABLE void fetchWorkflowRunJobs(const QString &owner, const QString &repo, int runId);

    // Releases API
    Q_INVOKABLE void fetchReleases(const QString &owner, const QString &repo);
    Q_INVOKABLE void downloadReleaseAsset(const QString &assetUrl, const QString &fileName);

    // Issues API
    Q_INVOKABLE void fetchIssues(const QString &owner, const QString &repo);
    Q_INVOKABLE void fetchIssue(const QString &owner, const QString &repo, int issueNumber);

    // Pull Requests API
    Q_INVOKABLE void fetchPullRequests(const QString &owner, const QString &repo);
    Q_INVOKABLE void fetchPullRequest(const QString &owner, const QString &repo, int prNumber);

    // Repository Content API
    Q_INVOKABLE void fetchRepositoryContents(const QString &owner, const QString &repo, const QString &path = "");
    Q_INVOKABLE void fetchFileContent(const QString &owner, const QString &repo, const QString &path);

    // Commits API
    Q_INVOKABLE void fetchCommits(const QString &owner, const QString &repo, const QString &branch = "");
    Q_INVOKABLE void fetchCommit(const QString &owner, const QString &repo, const QString &sha);

signals:
    void loadingChanged();
    void requestError(const QString &error);

    // Response signals
    void currentUserReceived(const QJsonObject &user);
    void repositoriesReceived(const QJsonArray &repos);
    void starredRepositoriesReceived(const QJsonArray &repos);
    void repositoryReceived(const QJsonObject &repo);
    void searchResultsReceived(const QJsonArray &repos);
    void repositoryStarred(const QString &owner, const QString &repo);
    void repositoryUnstarred(const QString &owner, const QString &repo);
    void repositoryStarStatusReceived(bool isStarred, const QString &owner, const QString &repo);
    void workflowRunsReceived(const QJsonArray &runs);
    void workflowRunDetailsReceived(const QJsonObject &run);
    void workflowJobsReceived(const QJsonArray &jobs);
    void releasesReceived(const QJsonArray &releases);
    void assetDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void assetDownloadCompleted(const QString &filePath);
    void issuesReceived(const QJsonArray &issues);
    void issueReceived(const QJsonObject &issue);
    void pullRequestsReceived(const QJsonArray &prs);
    void pullRequestReceived(const QJsonObject &pr);
    void repositoryContentsReceived(const QJsonArray &contents);
    void fileContentReceived(const QJsonObject &file);
    void commitsReceived(const QJsonArray &commits);
    void commitReceived(const QJsonObject &commit);

private slots:
    void onRequestFinished();
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    QNetworkAccessManager *m_networkManager;
    AppSettings *m_settings;
    bool m_loading;

    void setLoading(bool loading);
    QNetworkRequest createRequest(const QString &endpoint);
    void get(const QString &endpoint, const QString &requestType);
    void put(const QString &endpoint, const QString &requestType);
    void deleteRequest(const QString &endpoint, const QString &requestType);
    void handleResponse(QNetworkReply *reply, const QString &requestType);
};

#endif // GITHUBAPI_H
