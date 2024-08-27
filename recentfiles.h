#ifndef RECENTFILES_H
#define RECENTFILES_H

#include <QObject>
#include <QStringList>
#include <QDateTime>
#include <QVariantMap>
#include <QSettings>

class RecentFiles: public QObject
{
    Q_OBJECT

public:
    explicit RecentFiles(QObject *parent = nullptr);

    Q_INVOKABLE void addFile(const QString &filePath);
    Q_INVOKABLE void removeFile(const QString &filePath);
    Q_INVOKABLE QVariantMap getRecentFiles() const;

signals:
    void recentFilesChanged();

private:
    void loadSettings();
    void saveSettings();
    QString generateThumbnail(const QString &filePath);

    QVariantMap recentFilesMap;
    const QString settingsGroup = "RecentFiles";
};

#endif // RECENTFILES_H
