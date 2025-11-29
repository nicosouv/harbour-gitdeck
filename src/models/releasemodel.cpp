#include "releasemodel.h"

ReleaseModel::ReleaseModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int ReleaseModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_releases.size();
}

QVariant ReleaseModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_releases.size())
        return QVariant();

    const QJsonObject &release = m_releases.at(index.row());

    switch (role) {
    case IdRole:
        return release["id"].toVariant().toLongLong();
    case TagNameRole:
        return release["tag_name"].toString();
    case NameRole:
        return release["name"].toString();
    case BodyRole:
        return release["body"].toString();
    case DraftRole:
        return release["draft"].toBool();
    case PrereleaseRole:
        return release["prerelease"].toBool();
    case CreatedAtRole:
        return release["created_at"].toString();
    case PublishedAtRole:
        return release["published_at"].toString();
    case AuthorRole:
        return release["author"].toObject()["login"].toString();
    case AuthorAvatarRole:
        return release["author"].toObject()["avatar_url"].toString();
    case AssetsRole: {
        QVariantList assets;
        QJsonArray assetsArray = release["assets"].toArray();
        for (const QJsonValue &asset : assetsArray) {
            QJsonObject assetObj = asset.toObject();
            QVariantMap assetMap;
            assetMap["name"] = assetObj["name"].toString();
            assetMap["size"] = assetObj["size"].toInt();
            // Use API URL instead of browser_download_url for proper authentication and redirects
            assetMap["downloadUrl"] = assetObj["url"].toString();
            assetMap["contentType"] = assetObj["content_type"].toString();
            assetMap["downloadCount"] = assetObj["download_count"].toInt();
            assets.append(assetMap);
        }
        return assets;
    }
    case TarballUrlRole:
        return release["tarball_url"].toString();
    case ZipballUrlRole:
        return release["zipball_url"].toString();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ReleaseModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "releaseId";
    roles[TagNameRole] = "tagName";
    roles[NameRole] = "name";
    roles[BodyRole] = "body";
    roles[DraftRole] = "isDraft";
    roles[PrereleaseRole] = "isPrerelease";
    roles[CreatedAtRole] = "createdAt";
    roles[PublishedAtRole] = "publishedAt";
    roles[AuthorRole] = "author";
    roles[AuthorAvatarRole] = "authorAvatar";
    roles[AssetsRole] = "assets";
    roles[TarballUrlRole] = "tarballUrl";
    roles[ZipballUrlRole] = "zipballUrl";
    return roles;
}

void ReleaseModel::loadFromJson(const QJsonArray &releases)
{
    beginResetModel();
    m_releases.clear();

    for (const QJsonValue &value : releases) {
        if (value.isObject()) {
            m_releases.append(value.toObject());
        }
    }

    endResetModel();
    emit countChanged();
}

void ReleaseModel::clear()
{
    beginResetModel();
    m_releases.clear();
    endResetModel();
    emit countChanged();
}

QVariantMap ReleaseModel::get(int index) const
{
    QVariantMap map;
    if (index >= 0 && index < m_releases.size()) {
        const QJsonObject &release = m_releases.at(index);
        map["releaseId"] = release["id"].toVariant().toLongLong();
        map["tagName"] = release["tag_name"].toString();
        map["name"] = release["name"].toString();
        map["body"] = release["body"].toString();
        map["isDraft"] = release["draft"].toBool();
        map["isPrerelease"] = release["prerelease"].toBool();
        map["author"] = release["author"].toObject()["login"].toString();
    }
    return map;
}

void ReleaseModel::removeById(qint64 releaseId)
{
    for (int i = 0; i < m_releases.size(); ++i) {
        if (m_releases.at(i)["id"].toVariant().toLongLong() == releaseId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_releases.removeAt(i);
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}
