#ifndef REPOSITORYMODEL_H
#define REPOSITORYMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class RepositoryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum RepositoryRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        FullNameRole,
        DescriptionRole,
        OwnerRole,
        OwnerAvatarRole,
        PrivateRole,
        ForkedRole,
        StarsRole,
        WatchersRole,
        ForksRole,
        LanguageRole,
        UpdatedAtRole,
        PushedAtRole,
        DefaultBranchRole,
        HasActionsRole
    };

    explicit RepositoryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_repositories.size(); }

    Q_INVOKABLE void loadFromJson(const QJsonArray &repos);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int index) const;

signals:
    void countChanged();

private:
    QList<QJsonObject> m_repositories;
};

#endif // REPOSITORYMODEL_H
