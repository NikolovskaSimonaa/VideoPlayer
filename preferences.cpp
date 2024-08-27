#include "preferences.h"
#include <QSettings>

Preferences::Preferences(QObject *parent) : QObject(parent) {}

void Preferences::saveWindowSize(int width, int height, int x, int y) {
    QSettings settings("Simona", "VideoPlayer");
    settings.setValue("windowWidth", width);
    settings.setValue("windowHeight", height);
    settings.setValue("windowX", x);
    settings.setValue("windowY", y);
}

QVariantList Preferences::loadWindowSize() {
    QSettings settings("Simona", "VideoPlayer");
    int width = settings.value("windowWidth", 800).toInt();
    int height = settings.value("windowHeight", 600).toInt();
    int x = settings.value("windowX", 200).toInt();
    int y = settings.value("windowY", 200).toInt();
    return QVariantList() << width << height << x << y;
}

void Preferences:: setVolume(int volume) {
    QSettings settings("Simona", "VideoPlayer");
    settings.setValue("volumeLevel", volume);
}

int Preferences:: getVolume() {
    QSettings settings("Simona", "VideoPlayer");
    return settings.value("volumeLevel", 50).toInt();
}
