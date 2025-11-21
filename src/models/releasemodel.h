#ifndef RELEASEMODEL_H
#define RELEASEMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonObject>

class ReleaseModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ReleaseRoles {
        IdRole = Qt::UserRole + 1,
        TagNameRole,
        NameRole,
        BodyRole,
        DraftRole,
        PrereleaseRole,
        CreatedAtRole,
        PublishedAtRole,
        AuthorRole,
        AuthorAvatarRole,
        AssetsRole,
        TarballUrlRole,
        ZipballUrlRole
    };

    explicit ReleaseModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_releases.size(); }

    Q_INVOKABLE void loadFromJson(const QJsonArray &releases);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QVariantMap get(int index) const;

signals:
    void countChanged();

private:
    QList<QJsonObject> m_releases;
};

#endif // RELEASEMODEL_H
