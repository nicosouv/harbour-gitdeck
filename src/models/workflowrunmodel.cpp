#include "workflowrunmodel.h"

WorkflowRunModel::WorkflowRunModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int WorkflowRunModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_runs.size();
}

QVariant WorkflowRunModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_runs.size())
        return QVariant();

    const QJsonObject &run = m_runs.at(index.row());

    switch (role) {
    case IdRole:
        return run["id"].toInt();
    case NameRole:
        return run["name"].toString();
    case HeadBranchRole:
        return run["head_branch"].toString();
    case StatusRole:
        return run["status"].toString();
    case ConclusionRole:
        return run["conclusion"].toString();
    case EventRole:
        return run["event"].toString();
    case RunNumberRole:
        return run["run_number"].toInt();
    case CreatedAtRole:
        return run["created_at"].toString();
    case UpdatedAtRole:
        return run["updated_at"].toString();
    case HeadShaRole:
        return run["head_sha"].toString();
    case HeadCommitMessageRole:
        return run["head_commit"].toObject()["message"].toString();
    case ActorRole:
        return run["actor"].toObject()["login"].toString();
    case ActorAvatarRole:
        return run["actor"].toObject()["avatar_url"].toString();
    case WorkflowIdRole:
        return run["workflow_id"].toInt();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> WorkflowRunModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "runId";
    roles[NameRole] = "name";
    roles[HeadBranchRole] = "branch";
    roles[StatusRole] = "status";
    roles[ConclusionRole] = "conclusion";
    roles[EventRole] = "event";
    roles[RunNumberRole] = "runNumber";
    roles[CreatedAtRole] = "createdAt";
    roles[UpdatedAtRole] = "updatedAt";
    roles[HeadShaRole] = "headSha";
    roles[HeadCommitMessageRole] = "commitMessage";
    roles[ActorRole] = "actor";
    roles[ActorAvatarRole] = "actorAvatar";
    roles[WorkflowIdRole] = "workflowId";
    return roles;
}

void WorkflowRunModel::loadFromJson(const QJsonArray &runs)
{
    beginResetModel();
    m_runs.clear();

    for (const QJsonValue &value : runs) {
        if (value.isObject()) {
            m_runs.append(value.toObject());
        }
    }

    endResetModel();
    emit countChanged();
}

void WorkflowRunModel::clear()
{
    beginResetModel();
    m_runs.clear();
    endResetModel();
    emit countChanged();
}

QVariantMap WorkflowRunModel::get(int index) const
{
    QVariantMap map;
    if (index >= 0 && index < m_runs.size()) {
        const QJsonObject &run = m_runs.at(index);
        map["runId"] = run["id"].toInt();
        map["name"] = run["name"].toString();
        map["branch"] = run["head_branch"].toString();
        map["status"] = run["status"].toString();
        map["conclusion"] = run["conclusion"].toString();
        map["runNumber"] = run["run_number"].toInt();
        map["commitMessage"] = run["head_commit"].toObject()["message"].toString();
    }
    return map;
}
