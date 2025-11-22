#include "oauthmanager.h"
#include "appsettings.h"
#include <QDesktopServices>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTcpSocket>
#include <QDateTime>
#include <QDebug>

// GitHub OAuth configuration
#ifndef GITDECK_CLIENT_ID
#define GITDECK_CLIENT_ID ""
#endif

#ifndef GITDECK_CLIENT_SECRET
#define GITDECK_CLIENT_SECRET ""
#endif

const QString OAuthManager::CLIENT_ID = QString(GITDECK_CLIENT_ID);
const QString OAuthManager::CLIENT_SECRET = QString(GITDECK_CLIENT_SECRET);
const QString OAuthManager::REDIRECT_URI = "http://localhost:8080/callback";
const QString OAuthManager::AUTHORIZATION_URL = "https://github.com/login/oauth/authorize";
const QString OAuthManager::TOKEN_URL = "https://github.com/login/oauth/access_token";
const QString OAuthManager::SCOPE = "repo,user,workflow";

OAuthManager::OAuthManager(AppSettings *settings, QObject *parent)
    : QObject(parent)
    , m_settings(settings)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_localServer(new QTcpServer(this))
    , m_isAuthenticating(false)
    , m_localPort(8080)
{
    connect(m_localServer, &QTcpServer::newConnection,
            this, &OAuthManager::handleIncomingConnection);
}

OAuthManager::~OAuthManager()
{
    stopLocalServer();
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

    static bool seeded = false;
    if (!seeded) {
        qsrand(static_cast<uint>(QDateTime::currentMSecsSinceEpoch()));
        seeded = true;
    }

    for (int i = 0; i < length; i++) {
        int index = qrand() % charsetSize;
        state.append(charset[index]);
    }

    return state;
}

void OAuthManager::startAuthentication()
{
    if (m_isAuthenticating) {
        qDebug() << "Authentication already in progress";
        return;
    }

    if (CLIENT_ID.isEmpty() || CLIENT_SECRET.isEmpty()) {
        qWarning() << "OAuth credentials not configured";
        emit authenticationFailed("OAuth not configured. Please use Personal Access Token.");
        return;
    }

    qDebug() << "Starting OAuth authentication flow...";

    setIsAuthenticating(true);

    // Generate random state for CSRF protection
    m_state = generateRandomState();

    // Start local HTTP server to receive callback
    if (!startLocalServer()) {
        emit authenticationFailed("Failed to start local callback server");
        setIsAuthenticating(false);
        return;
    }

    // Open browser with authorization URL
    openAuthorizationUrl();
}

void OAuthManager::cancelAuthentication()
{
    qDebug() << "Canceling authentication";
    stopLocalServer();
    setIsAuthenticating(false);
}

void OAuthManager::openAuthorizationUrl()
{
    QUrl url(AUTHORIZATION_URL);
    QUrlQuery query;

    query.addQueryItem("client_id", CLIENT_ID);
    query.addQueryItem("scope", SCOPE);
    query.addQueryItem("redirect_uri", REDIRECT_URI);
    query.addQueryItem("state", m_state);

    url.setQuery(query);

    qDebug() << "Opening browser with URL:" << url.toString();

    if (!QDesktopServices::openUrl(url)) {
        qWarning() << "Failed to open browser";
        emit authenticationFailed("Failed to open browser");
        setIsAuthenticating(false);
    }
}

bool OAuthManager::startLocalServer()
{
    // Try to bind to port 8080, if busy try 8081-8090
    for (quint16 port = 8080; port < 8090; ++port) {
        if (m_localServer->listen(QHostAddress::LocalHost, port)) {
            m_localPort = port;
            qDebug() << "Local server started on port:" << port;
            return true;
        }
    }

    qWarning() << "Failed to start local server on any port";
    return false;
}

void OAuthManager::stopLocalServer()
{
    if (m_localServer->isListening()) {
        m_localServer->close();
        qDebug() << "Local server stopped";
    }
}

void OAuthManager::handleIncomingConnection()
{
    qDebug() << "Received OAuth callback connection";

    QTcpSocket *socket = m_localServer->nextPendingConnection();

    if (!socket) {
        return;
    }

    connect(socket, &QTcpSocket::readyRead, this, [this, socket]() {
        QString request = socket->readAll();
        qDebug() << "OAuth callback request:" << request;

        // Parse HTTP request
        QStringList lines = request.split("\r\n");
        if (lines.isEmpty()) {
            socket->deleteLater();
            return;
        }

        // Extract URL from first line (GET /callback?code=xxx&state=yyy HTTP/1.1)
        QStringList requestLine = lines[0].split(" ");
        if (requestLine.size() < 2) {
            sendResponseToClient(socket, "Invalid request");
            socket->deleteLater();
            return;
        }

        QString path = requestLine[1];
        QUrl url("http://localhost" + path);
        QUrlQuery query(url);

        // Check for error
        if (query.hasQueryItem("error")) {
            QString error = query.queryItemValue("error");
            qWarning() << "OAuth error:" << error;

            sendResponseToClient(socket, "Authentication failed: " + error);

            emit authenticationFailed(error);
            setIsAuthenticating(false);

            socket->deleteLater();
            stopLocalServer();
            return;
        }

        // Verify state (CSRF protection)
        QString state = query.queryItemValue("state");
        if (state != m_state) {
            qWarning() << "State mismatch! Possible CSRF attack.";
            sendResponseToClient(socket, "Security error: state mismatch");

            emit authenticationFailed("State mismatch");
            setIsAuthenticating(false);

            socket->deleteLater();
            stopLocalServer();
            return;
        }

        // Get authorization code
        QString code = query.queryItemValue("code");
        if (code.isEmpty()) {
            sendResponseToClient(socket, "No authorization code received");

            emit authenticationFailed("No authorization code");
            setIsAuthenticating(false);

            socket->deleteLater();
            stopLocalServer();
            return;
        }

        // Send success response to browser
        sendResponseToClient(socket, "Authentication successful! You can close this window.");

        // Exchange code for token
        exchangeCodeForToken(code);

        socket->deleteLater();
        stopLocalServer();
    });
}

void OAuthManager::exchangeCodeForToken(const QString &code)
{
    qDebug() << "Exchanging authorization code for access token...";

    QUrl url(TOKEN_URL);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Accept", "application/json");

    QJsonObject json;
    json["client_id"] = CLIENT_ID;
    json["client_secret"] = CLIENT_SECRET;
    json["code"] = code;
    json["redirect_uri"] = REDIRECT_URI;

    QByteArray data = QJsonDocument(json).toJson();

    QNetworkReply *reply = m_networkManager->post(request, data);

    connect(reply, &QNetworkReply::finished, this, &OAuthManager::handleTokenResponse);
}

void OAuthManager::handleTokenResponse()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        return;
    }

    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        QString error = reply->errorString();
        qWarning() << "Token request failed:" << error;

        emit authenticationFailed(error);
        setIsAuthenticating(false);
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (!doc.isObject()) {
        emit authenticationFailed("Invalid response from GitHub");
        setIsAuthenticating(false);
        return;
    }

    QJsonObject response = doc.object();

    if (response.contains("error")) {
        QString error = response["error_description"].toString();
        if (error.isEmpty()) {
            error = response["error"].toString();
        }
        qWarning() << "Token exchange failed:" << error;

        emit authenticationFailed(error);
        setIsAuthenticating(false);
        return;
    }

    QString accessToken = response["access_token"].toString();
    if (accessToken.isEmpty()) {
        emit authenticationFailed("No access token received");
        setIsAuthenticating(false);
        return;
    }

    qDebug() << "OAuth authentication succeeded!";

    m_settings->saveToken(accessToken, AppSettings::OAuth);

    setIsAuthenticating(false);
    emit authenticationSuccessful(accessToken);
}

void OAuthManager::sendResponseToClient(QTcpSocket *socket, const QString &message)
{
    QString html = QString(
        "<!DOCTYPE html>"
        "<html>"
        "<head>"
        "<title>GitDeck Authentication</title>"
        "<meta charset='utf-8'>"
        "<style>"
        "body { font-family: sans-serif; text-align: center; padding: 50px; background: #0d1117; color: #c9d1d9; }"
        "h1 { color: #58a6ff; }"
        ".container { max-width: 600px; margin: 0 auto; background: #161b22; padding: 40px; border-radius: 8px; }"
        "</style>"
        "</head>"
        "<body>"
        "<div class='container'>"
        "<h1>GitDeck</h1>"
        "<p>%1</p>"
        "<p><small>You can close this window now.</small></p>"
        "</div>"
        "</body>"
        "</html>"
    ).arg(message);

    QString response = QString(
        "HTTP/1.1 200 OK\r\n"
        "Content-Type: text/html; charset=utf-8\r\n"
        "Content-Length: %1\r\n"
        "Connection: close\r\n"
        "\r\n"
        "%2"
    ).arg(html.toUtf8().length()).arg(html);

    socket->write(response.toUtf8());
    socket->flush();
}
