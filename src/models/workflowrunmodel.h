#ifndef WORKFLOWRUNMODEL_H
#define WORKFLOWRUNMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class WorkflowRunModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum WorkflowRunRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        HeadBranchRole,
        StatusRole,
        ConclusionRole,
        EventRole,
        RunNumberRole,
        CreatedAtRole,
        UpdatedAtRole,
        HeadShaRole,
        HeadCommitMessageRole,
        ActorRole,
        ActorAvatarRole,
        WorkflowIdRole
    };

    explicit WorkflowRunModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_runs.size(); }

    Q_INVOKABLE void loadFromJson(const QJsonArray &runs);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int index) const;

signals:
    void countChanged();

private:
    QList<QJsonObject> m_runs;
};

#endif // WORKFLOWRUNMODEL_H
