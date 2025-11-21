#include "appsettings.h"

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_settings("harbour-gitdeck", "GitDeck")
    , m_authMethod(None)
{
    loadSettings();
}

void AppSettings::loadSettings()
{
    m_accessToken = m_settings.value("auth/accessToken").toString();
    m_username = m_settings.value("auth/username").toString();
    m_avatarUrl = m_settings.value("auth/avatarUrl").toString();
    m_authMethod = static_cast<AuthMethod>(m_settings.value("auth/method", None).toInt());
}

QString AppSettings::accessToken() const
{
    return m_accessToken;
}

void AppSettings::setAccessToken(const QString &token)
{
    if (m_accessToken != token) {
        m_accessToken = token;
        m_settings.setValue("auth/accessToken", token);
        emit accessTokenChanged();
        emit isAuthenticatedChanged();
    }
}

bool AppSettings::isAuthenticated() const
{
    return !m_accessToken.isEmpty();
}

QString AppSettings::username() const
{
    return m_username;
}

void AppSettings::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        m_settings.setValue("auth/username", username);
        emit usernameChanged();
    }
}

QString AppSettings::avatarUrl() const
{
    return m_avatarUrl;
}

void AppSettings::setAvatarUrl(const QString &url)
{
    if (m_avatarUrl != url) {
        m_avatarUrl = url;
        m_settings.setValue("auth/avatarUrl", url);
        emit avatarUrlChanged();
    }
}

AppSettings::AuthMethod AppSettings::authMethod() const
{
    return m_authMethod;
}

void AppSettings::setAuthMethod(AuthMethod method)
{
    if (m_authMethod != method) {
        m_authMethod = method;
        m_settings.setValue("auth/method", static_cast<int>(method));
        emit authMethodChanged();
    }
}

void AppSettings::clearAuth()
{
    m_settings.remove("auth");
    m_accessToken.clear();
    m_username.clear();
    m_avatarUrl.clear();
    m_authMethod = None;

    emit accessTokenChanged();
    emit isAuthenticatedChanged();
    emit usernameChanged();
    emit avatarUrlChanged();
    emit authMethodChanged();
}

void AppSettings::saveToken(const QString &token, AuthMethod method)
{
    setAccessToken(token);
    setAuthMethod(method);
}
