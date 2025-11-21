#include "pullrequestmodel.h"

PullRequestModel::PullRequestModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int PullRequestModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_pullRequests.size();
}

QVariant PullRequestModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_pullRequests.size())
        return QVariant();

    const QJsonObject &pr = m_pullRequests.at(index.row());

    switch (role) {
    case IdRole:
        return pr["id"].toInt();
    case NumberRole:
        return pr["number"].toInt();
    case TitleRole:
        return pr["title"].toString();
    case BodyRole:
        return pr["body"].toString();
    case StateRole:
        return pr["state"].toString();
    case CreatedAtRole:
        return pr["created_at"].toString();
    case UpdatedAtRole:
        return pr["updated_at"].toString();
    case ClosedAtRole:
        return pr["closed_at"].toString();
    case MergedAtRole:
        return pr["merged_at"].toString();
    case UserRole:
        return pr["user"].toObject()["login"].toString();
    case UserAvatarRole:
        return pr["user"].toObject()["avatar_url"].toString();
    case HeadBranchRole:
        return pr["head"].toObject()["ref"].toString();
    case BaseBranchRole:
        return pr["base"].toObject()["ref"].toString();
    case MergeableRole:
        return pr["mergeable"].toBool();
    case MergedRole:
        return pr["merged"].toBool();
    case DraftRole:
        return pr["draft"].toBool();
    case CommentsCountRole:
        return pr["comments"].toInt();
    case ReviewCommentsCountRole:
        return pr["review_comments"].toInt();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PullRequestModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "prId";
    roles[NumberRole] = "number";
    roles[TitleRole] = "title";
    roles[BodyRole] = "body";
    roles[StateRole] = "state";
    roles[CreatedAtRole] = "createdAt";
    roles[UpdatedAtRole] = "updatedAt";
    roles[ClosedAtRole] = "closedAt";
    roles[MergedAtRole] = "mergedAt";
    roles[UserRole] = "user";
    roles[UserAvatarRole] = "userAvatar";
    roles[HeadBranchRole] = "headBranch";
    roles[BaseBranchRole] = "baseBranch";
    roles[MergeableRole] = "mergeable";
    roles[MergedRole] = "merged";
    roles[DraftRole] = "isDraft";
    roles[CommentsCountRole] = "commentsCount";
    roles[ReviewCommentsCountRole] = "reviewCommentsCount";
    return roles;
}

void PullRequestModel::loadFromJson(const QJsonArray &prs)
{
    beginResetModel();
    m_pullRequests.clear();

    for (const QJsonValue &value : prs) {
        if (value.isObject()) {
            m_pullRequests.append(value.toObject());
        }
    }

    endResetModel();
    emit countChanged();
}

void PullRequestModel::clear()
{
    beginResetModel();
    m_pullRequests.clear();
    endResetModel();
    emit countChanged();
}

QVariantMap PullRequestModel::get(int index) const
{
    QVariantMap map;
    if (index >= 0 && index < m_pullRequests.size()) {
        const QJsonObject &pr = m_pullRequests.at(index);
        map["prId"] = pr["id"].toInt();
        map["number"] = pr["number"].toInt();
        map["title"] = pr["title"].toString();
        map["body"] = pr["body"].toString();
        map["state"] = pr["state"].toString();
        map["user"] = pr["user"].toObject()["login"].toString();
        map["headBranch"] = pr["head"].toObject()["ref"].toString();
        map["baseBranch"] = pr["base"].toObject()["ref"].toString();
    }
    return map;
}
