#include "issuemodel.h"

IssueModel::IssueModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int IssueModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_issues.size();
}

QVariant IssueModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_issues.size())
        return QVariant();

    const QJsonObject &issue = m_issues.at(index.row());

    switch (role) {
    case IdRole:
        return issue["id"].toInt();
    case NumberRole:
        return issue["number"].toInt();
    case TitleRole:
        return issue["title"].toString();
    case BodyRole:
        return issue["body"].toString();
    case StateRole:
        return issue["state"].toString();
    case CreatedAtRole:
        return issue["created_at"].toString();
    case UpdatedAtRole:
        return issue["updated_at"].toString();
    case ClosedAtRole:
        return issue["closed_at"].toString();
    case UserRole:
        return issue["user"].toObject()["login"].toString();
    case UserAvatarRole:
        return issue["user"].toObject()["avatar_url"].toString();
    case LabelsRole: {
        QVariantList labels;
        QJsonArray labelsArray = issue["labels"].toArray();
        for (const QJsonValue &label : labelsArray) {
            QJsonObject labelObj = label.toObject();
            QVariantMap labelMap;
            labelMap["name"] = labelObj["name"].toString();
            labelMap["color"] = labelObj["color"].toString();
            labels.append(labelMap);
        }
        return labels;
    }
    case CommentsCountRole:
        return issue["comments"].toInt();
    case IsPullRequestRole:
        return issue.contains("pull_request");
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> IssueModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "issueId";
    roles[NumberRole] = "number";
    roles[TitleRole] = "title";
    roles[BodyRole] = "body";
    roles[StateRole] = "state";
    roles[CreatedAtRole] = "createdAt";
    roles[UpdatedAtRole] = "updatedAt";
    roles[ClosedAtRole] = "closedAt";
    roles[UserRole] = "user";
    roles[UserAvatarRole] = "userAvatar";
    roles[LabelsRole] = "labels";
    roles[CommentsCountRole] = "commentsCount";
    roles[IsPullRequestRole] = "isPullRequest";
    return roles;
}

void IssueModel::loadFromJson(const QJsonArray &issues)
{
    beginResetModel();
    m_issues.clear();

    for (const QJsonValue &value : issues) {
        if (value.isObject()) {
            m_issues.append(value.toObject());
        }
    }

    endResetModel();
    emit countChanged();
}

void IssueModel::clear()
{
    beginResetModel();
    m_issues.clear();
    endResetModel();
    emit countChanged();
}

QVariantMap IssueModel::get(int index) const
{
    QVariantMap map;
    if (index >= 0 && index < m_issues.size()) {
        const QJsonObject &issue = m_issues.at(index);
        map["issueId"] = issue["id"].toInt();
        map["number"] = issue["number"].toInt();
        map["title"] = issue["title"].toString();
        map["body"] = issue["body"].toString();
        map["state"] = issue["state"].toString();
        map["user"] = issue["user"].toObject()["login"].toString();
    }
    return map;
}
