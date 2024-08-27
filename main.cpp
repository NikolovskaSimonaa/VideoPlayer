#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QQuickStyle>
#include <QVariant>
#include "recentfiles.h"
#include "preferences.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/window_icon.png"));

    QQuickStyle::setStyle("Fusion");

    QQmlApplicationEngine engine;

    RecentFiles recentFiles;
    engine.rootContext()->setContextProperty("recentFiles", &recentFiles);
    Preferences preferences;
    engine.rootContext()->setContextProperty("preferences", &preferences);

    engine.load(QUrl(QStringLiteral("qrc:/VideoPlayer/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
