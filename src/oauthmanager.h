#ifndef OAUTHMANAGER_H
#define OAUTHMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTcpServer>
#include <QString>
#include <QUrl>

class AppSettings;

class OAuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticating READ isAuthenticating NOTIFY isAuthenticatingChanged)

public:
    explicit OAuthManager(AppSettings *settings, QObject *parent = nullptr);
    ~OAuthManager();

    bool isAuthenticating() const { return m_isAuthenticating; }

    Q_INVOKABLE void startAuthentication();
    Q_INVOKABLE void cancelAuthentication();

signals:
    void isAuthenticatingChanged();
    void authenticationSuccessful(const QString &token);
    void authenticationFailed(const QString &error);

private slots:
    void handleIncomingConnection();
    void handleTokenResponse();

private:
    void openAuthorizationUrl();
    bool startLocalServer();
    void stopLocalServer();
    QString generateRandomState();
    void sendResponseToClient(QTcpSocket *socket, const QString &message);
    void exchangeCodeForToken(const QString &code);

    AppSettings *m_settings;
    QNetworkAccessManager *m_networkManager;
    QTcpServer *m_localServer;
    bool m_isAuthenticating;
    QString m_state;
    quint16 m_localPort;

    static const QString CLIENT_ID;
    static const QString CLIENT_SECRET;
    static const QString REDIRECT_URI;
    static const QString AUTHORIZATION_URL;
    static const QString TOKEN_URL;
    static const QString SCOPE;
};

#endif // OAUTHMANAGER_H
