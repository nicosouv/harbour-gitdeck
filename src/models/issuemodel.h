#ifndef ISSUEMODEL_H
#define ISSUEMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class IssueModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum IssueRoles {
        IdRole = Qt::UserRole + 1,
        NumberRole,
        TitleRole,
        BodyRole,
        StateRole,
        CreatedAtRole,
        UpdatedAtRole,
        ClosedAtRole,
        UserRole,
        UserAvatarRole,
        LabelsRole,
        CommentsCountRole,
        IsPullRequestRole
    };

    explicit IssueModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_issues.size(); }

    Q_INVOKABLE void loadFromJson(const QJsonArray &issues);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int index) const;

signals:
    void countChanged();

private:
    QList<QJsonObject> m_issues;
};

#endif // ISSUEMODEL_H
