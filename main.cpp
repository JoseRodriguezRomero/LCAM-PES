#include <QLocale>
#include <QQmlContext>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>

#include "controller.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    Controller controller;

    QLocale::setDefault(QLocale::c());
    engine.rootContext()->setContextProperty("controller",&controller);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    controller.setEngine(&engine);
    controller.loadBackup();

    return app.exec();
}
