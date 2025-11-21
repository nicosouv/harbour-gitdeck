#ifndef PULLREQUESTMODEL_H
#define PULLREQUESTMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class PullRequestModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum PullRequestRoles {
        IdRole = Qt::UserRole + 1,
        NumberRole,
        TitleRole,
        BodyRole,
        StateRole,
        CreatedAtRole,
        UpdatedAtRole,
        ClosedAtRole,
        MergedAtRole,
        UserRole,
        UserAvatarRole,
        HeadBranchRole,
        BaseBranchRole,
        MergeableRole,
        MergedRole,
        DraftRole,
        CommentsCountRole,
        ReviewCommentsCountRole
    };

    explicit PullRequestModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_pullRequests.size(); }

    Q_INVOKABLE void loadFromJson(const QJsonArray &prs);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int index) const;

signals:
    void countChanged();

private:
    QList<QJsonObject> m_pullRequests;
};

#endif // PULLREQUESTMODEL_H
