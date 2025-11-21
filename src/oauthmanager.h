#ifndef OAUTHMANAGER_H
#define OAUTHMANAGER_H

#include <QObject>
#include <QString>
#include <QUrl>

class AppSettings;

class OAuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAuthenticating READ isAuthenticating NOTIFY isAuthenticatingChanged)

public:
    explicit OAuthManager(AppSettings *settings, QObject *parent = nullptr);

    bool isAuthenticating() const { return m_isAuthenticating; }

    Q_INVOKABLE QString getAuthorizationUrl();
    Q_INVOKABLE void exchangeCodeForToken(const QString &code);
    Q_INVOKABLE void cancelAuthentication();

signals:
    void isAuthenticatingChanged();
    void authenticationSuccessful(const QString &token);
    void authenticationFailed(const QString &error);

private:
    AppSettings *m_settings;
    bool m_isAuthenticating;
    QString m_state;

    void setIsAuthenticating(bool authenticating);
    QString generateRandomState();

    static const QString CLIENT_ID;
    static const QString CLIENT_SECRET;
    static const QString REDIRECT_URI;
    static const QString SCOPE;
};

#endif // OAUTHMANAGER_H
