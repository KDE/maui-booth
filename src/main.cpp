// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QCommandLineParser>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit4/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#ifdef Q_OS_MACOS
#include <MauiKit4/Core/mauimacos.h>
#endif

#include <KLocalizedString>

#include <MauiKit4/Core/mauiapp.h>

#include "../booth_version.h"

#define BOOTH_URI "org.maui.booth"

int Q_DECL_EXPORT main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
        QGuiApplication app(argc, argv);
        if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
                return -1;

        QCameraPermission cameraPermission;
        qApp->requestPermission(cameraPermission, [](const QPermission &permission) {
            // Show UI in any case. If there is no permission, the UI will just
            // be disabled.
            if (permission.status() != Qt::PermissionStatus::Granted)
                qWarning("Camera permission is not granted!");
            // setupView();
        });
#else
        QApplication app(argc, argv);
#endif

        app.setOrganizationName(QStringLiteral("Maui"));
        app.setWindowIcon(QIcon(":/booth.svg"));

        KLocalizedString::setApplicationDomain("booth");
        KAboutData about(QStringLiteral("booth"),
                         QStringLiteral("Booth"),
                         BOOTH_VERSION_STRING,
                         i18n("Camera app to take pictures and record videos."),
                         KAboutLicense::LGPL_V3,
                         APP_COPYRIGHT_NOTICE,
                         QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

        about.addAuthor(QStringLiteral("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
        about.setHomepage("https://mauikit.org");
        about.setProductName("maui/booth");
        about.setBugAddress("https://invent.kde.org/maui/booth/-/issues");
        about.setOrganizationDomain(BOOTH_URI);
        about.setProgramLogo(app.windowIcon());
        about.addComponent("Prison");

        KAboutData::setApplicationData(about);
        MauiApp::instance()->setIconName("qrc:/booth.svg");

        QCommandLineParser parser;
        parser.setApplicationDescription(about.shortDescription());
        parser.process(app);
        about.processCommandLine(&parser);

        QQmlApplicationEngine engine;
        const QUrl url(QStringLiteral("qrc:/app/maui/booth/main.qml"));
        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                                         &app, [url](QObject *obj, const QUrl &objUrl)
        {
                if (!obj && url == objUrl)
                        QCoreApplication::exit(-1);

        }, Qt::QueuedConnection);

        engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    engine.load(url);

#ifdef Q_OS_MACOS
        //    MAUIMacOS::removeTitlebarFromWindow();
        //    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts

#endif
        return app.exec();
}
