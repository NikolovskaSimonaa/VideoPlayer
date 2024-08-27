#ifndef PREFERENCES_H
#define PREFERENCES_H

#include <QObject>
#include <QVariant>

class Preferences : public QObject {
    Q_OBJECT
public:
    explicit Preferences(QObject *parent = nullptr);

    Q_INVOKABLE void saveWindowSize(int width, int height, int x, int y);
    Q_INVOKABLE QVariantList loadWindowSize();
    Q_INVOKABLE int getVolume();
    Q_INVOKABLE void setVolume(int volume);
};

#endif // PREFERENCES_H
