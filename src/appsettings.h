#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>

class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString accessToken READ accessToken WRITE setAccessToken NOTIFY accessTokenChanged)
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY isAuthenticatedChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString avatarUrl READ avatarUrl WRITE setAvatarUrl NOTIFY avatarUrlChanged)
    Q_PROPERTY(AuthMethod authMethod READ authMethod WRITE setAuthMethod NOTIFY authMethodChanged)

public:
    enum AuthMethod {
        None = 0,
        OAuth = 1,
        PersonalToken = 2
    };
    Q_ENUM(AuthMethod)

    explicit AppSettings(QObject *parent = nullptr);

    QString accessToken() const;
    void setAccessToken(const QString &token);

    bool isAuthenticated() const;

    QString username() const;
    void setUsername(const QString &username);

    QString avatarUrl() const;
    void setAvatarUrl(const QString &url);

    AuthMethod authMethod() const;
    void setAuthMethod(AuthMethod method);

    Q_INVOKABLE void clearAuth();
    Q_INVOKABLE void saveToken(const QString &token, AuthMethod method);

signals:
    void accessTokenChanged();
    void isAuthenticatedChanged();
    void usernameChanged();
    void avatarUrlChanged();
    void authMethodChanged();

private:
    QSettings m_settings;
    QString m_accessToken;
    QString m_username;
    QString m_avatarUrl;
    AuthMethod m_authMethod;

    void loadSettings();
};

#endif // APPSETTINGS_H
