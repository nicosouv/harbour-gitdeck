#include "oauthmanager.h"
#include "appsettings.h"
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QDebug>

// These will be defined at compile time via qmake
#ifndef GITDECK_CLIENT_ID
#define GITDECK_CLIENT_ID ""
#endif

#ifndef GITDECK_CLIENT_SECRET
#define GITDECK_CLIENT_SECRET ""
#endif

const QString OAuthManager::CLIENT_ID = QString(GITDECK_CLIENT_ID);
const QString OAuthManager::CLIENT_SECRET = QString(GITDECK_CLIENT_SECRET);
const QString OAuthManager::REDIRECT_URI = "https://localhost/oauth/callback";
const QString OAuthManager::SCOPE = "repo,user,workflow";

OAuthManager::OAuthManager(AppSettings *settings, QObject *parent)
    : QObject(parent)
    , m_settings(settings)
    , m_isAuthenticating(false)
{
}

void OAuthManager::setIsAuthenticating(bool authenticating)
{
    if (m_isAuthenticating != authenticating) {
        m_isAuthenticating = authenticating;
        emit isAuthenticatingChanged();
    }
}

QString OAuthManager::generateRandomState()
{
    QString state;
    const char charset[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    const int length = 32;
    const int charsetSize = static_cast<int>(sizeof(charset) - 1);

    qsrand(static_cast<uint>(QDateTime::currentMSecsSinceEpoch()));

    for (int i = 0; i < length; i++) {
        int index = qrand() % charsetSize;
        state.append(charset[index]);
    }

    return state;
}

QString OAuthManager::getAuthorizationUrl()
{
    if (CLIENT_ID.isEmpty()) {
        qWarning() << "OAuth Client ID not configured";
        emit authenticationFailed("OAuth not configured. Please use Personal Access Token.");
        return QString();
    }

    m_state = generateRandomState();
    setIsAuthenticating(true);

    QUrl url("https://github.com/login/oauth/authorize");
    QUrlQuery query;
    query.addQueryItem("client_id", CLIENT_ID);
    query.addQueryItem("redirect_uri", REDIRECT_URI);
    query.addQueryItem("scope", SCOPE);
    query.addQueryItem("state", m_state);
    url.setQuery(query);

    return url.toString();
}

void OAuthManager::exchangeCodeForToken(const QString &code)
{
    if (CLIENT_ID.isEmpty() || CLIENT_SECRET.isEmpty()) {
        qWarning() << "OAuth credentials not configured";
        emit authenticationFailed("OAuth not configured");
        setIsAuthenticating(false);
        return;
    }

    QNetworkAccessManager *manager = new QNetworkAccessManager(this);

    QUrl url("https://github.com/login/oauth/access_token");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Accept", "application/json");

    QJsonObject json;
    json["client_id"] = CLIENT_ID;
    json["client_secret"] = CLIENT_SECRET;
    json["code"] = code;
    json["redirect_uri"] = REDIRECT_URI;

    QByteArray data = QJsonDocument(json).toJson();

    QNetworkReply *reply = manager->post(request, data);

    connect(reply, &QNetworkReply::finished, this, [this, reply, manager]() {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            QJsonObject obj = doc.object();

            if (obj.contains("access_token")) {
                QString token = obj["access_token"].toString();
                m_settings->saveToken(token, AppSettings::OAuth);
                emit authenticationSuccessful(token);
            } else {
                QString error = obj.value("error_description").toString("Authentication failed");
                qWarning() << "OAuth error:" << error;
                emit authenticationFailed(error);
            }
        } else {
            QString error = reply->errorString();
            qWarning() << "Network error during OAuth:" << error;
            emit authenticationFailed(error);
        }

        setIsAuthenticating(false);
        reply->deleteLater();
        manager->deleteLater();
    });
}

void OAuthManager::cancelAuthentication()
{
    setIsAuthenticating(false);
}
