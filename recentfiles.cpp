#include "recentfiles.h"
#include <QDateTime>
#include <QCoreApplication>
#include <QMediaPlayer>
#include <QVideoFrame>
#include <QVideoSink>
#include <QImage>
#include <QPixmap>
#include <QDir>
#include <QFileInfo>
#include <QEventLoop>

RecentFiles::RecentFiles(QObject *parent) : QObject(parent)
{
    loadSettings();
}

void RecentFiles::addFile(const QString &filePath)
{
    if (recentFilesMap.contains(filePath)) { // Remove the file if it already exists
        recentFilesMap.remove(filePath);
    }

    QVariantMap fileData;
    fileData["timestamp"] = QDateTime::currentDateTime();
    QString thumbnailPath = generateThumbnail(filePath);
    fileData["thumbnailPath"] = QUrl::fromLocalFile(thumbnailPath).toString();
    recentFilesMap[filePath] = fileData;

    saveSettings();
}

void RecentFiles::removeFile(const QString &filePath)
{
    recentFilesMap.remove(filePath);
    saveSettings();
}

QVariantMap RecentFiles::getRecentFiles() const
{
    return recentFilesMap;
}

void RecentFiles::loadSettings()
{
    QSettings settings("Simona", "VideoPlayer");
    settings.beginGroup(settingsGroup);
    recentFilesMap = settings.value("files").toMap();
    settings.endGroup();
}

void RecentFiles::saveSettings()
{
    QSettings settings("Simona", "VideoPlayer");
    settings.beginGroup(settingsGroup);
    settings.setValue("files", recentFilesMap);
    settings.endGroup();
}

QString RecentFiles::generateThumbnail(const QString &filePath)
{

    QString appDirPath = QCoreApplication::applicationDirPath();
    QString thumbnailDir = appDirPath + "/VideoThumbnails/"; // Creating a directory for thumbnails if it doesn't exist
    QString thumbnailPath = thumbnailDir + QFileInfo(filePath).baseName() + ".png";
    QString nativeFilePath = QUrl(filePath).toLocalFile();

    QMediaPlayer mediaPlayer;
    QVideoSink videoSink;

    mediaPlayer.setSource(QUrl::fromLocalFile(nativeFilePath));
    mediaPlayer.setVideoSink(&videoSink);
    mediaPlayer.setPosition(0);

    QEventLoop loop;
    QObject::connect(&mediaPlayer, &QMediaPlayer::mediaStatusChanged,  [&loop](QMediaPlayer::MediaStatus status) {
        if (status == QMediaPlayer::EndOfMedia || status == QMediaPlayer::InvalidMedia || status == QMediaPlayer::NoMedia) {
            loop.quit();
        }
    });

    mediaPlayer.play();

    QObject::connect(&videoSink, &QVideoSink::videoFrameChanged, [&](const QVideoFrame &frame) {
        if (frame.isValid()) {
            QImage image = frame.toImage();
            image.save(thumbnailPath, "PNG");
        }
        mediaPlayer.stop();
        loop.quit();
    });

    loop.exec();
    return thumbnailPath;
}
