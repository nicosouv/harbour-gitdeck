#include "repositorymodel.h"

RepositoryModel::RepositoryModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int RepositoryModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_repositories.size();
}

QVariant RepositoryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_repositories.size())
        return QVariant();

    const QJsonObject &repo = m_repositories.at(index.row());

    switch (role) {
    case IdRole:
        return repo["id"].toInt();
    case NameRole:
        return repo["name"].toString();
    case FullNameRole:
        return repo["full_name"].toString();
    case DescriptionRole:
        return repo["description"].toString();
    case OwnerRole:
        return repo["owner"].toObject()["login"].toString();
    case OwnerAvatarRole:
        return repo["owner"].toObject()["avatar_url"].toString();
    case PrivateRole:
        return repo["private"].toBool();
    case ForkedRole:
        return repo["fork"].toBool();
    case StarsRole:
        return repo["stargazers_count"].toInt();
    case WatchersRole:
        return repo["watchers_count"].toInt();
    case ForksRole:
        return repo["forks_count"].toInt();
    case LanguageRole:
        return repo["language"].toString();
    case UpdatedAtRole:
        return repo["updated_at"].toString();
    case PushedAtRole:
        return repo["pushed_at"].toString();
    case DefaultBranchRole:
        return repo["default_branch"].toString();
    case HasActionsRole:
        return repo["has_actions"].toBool(true);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RepositoryModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "repoId";
    roles[NameRole] = "name";
    roles[FullNameRole] = "fullName";
    roles[DescriptionRole] = "description";
    roles[OwnerRole] = "owner";
    roles[OwnerAvatarRole] = "ownerAvatar";
    roles[PrivateRole] = "isPrivate";
    roles[ForkedRole] = "isForked";
    roles[StarsRole] = "stars";
    roles[WatchersRole] = "watchers";
    roles[ForksRole] = "forks";
    roles[LanguageRole] = "language";
    roles[UpdatedAtRole] = "updatedAt";
    roles[PushedAtRole] = "pushedAt";
    roles[DefaultBranchRole] = "defaultBranch";
    roles[HasActionsRole] = "hasActions";
    return roles;
}

void RepositoryModel::loadFromJson(const QJsonArray &repos)
{
    beginResetModel();
    m_repositories.clear();

    for (const QJsonValue &value : repos) {
        if (value.isObject()) {
            m_repositories.append(value.toObject());
        }
    }

    endResetModel();
    emit countChanged();
}

void RepositoryModel::clear()
{
    beginResetModel();
    m_repositories.clear();
    endResetModel();
    emit countChanged();
}

QVariantMap RepositoryModel::get(int index) const
{
    QVariantMap map;
    if (index >= 0 && index < m_repositories.size()) {
        const QJsonObject &repo = m_repositories.at(index);
        map["repoId"] = repo["id"].toInt();
        map["name"] = repo["name"].toString();
        map["fullName"] = repo["full_name"].toString();
        map["description"] = repo["description"].toString();
        map["owner"] = repo["owner"].toObject()["login"].toString();
        map["ownerAvatar"] = repo["owner"].toObject()["avatar_url"].toString();
        map["isPrivate"] = repo["private"].toBool();
        map["stars"] = repo["stargazers_count"].toInt();
        map["language"] = repo["language"].toString();
        map["defaultBranch"] = repo["default_branch"].toString();
    }
    return map;
}
