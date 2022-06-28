// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <QDate>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QCommandLineParser>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifdef Q_OS_MACOS
#include <MauiKit/Core/mauimacos.h>
#endif

#include <MauiKit/Core/mauiapp.h>

#include <KAboutData>
#include <KI18n/KLocalizedString>

#include "../booth_version.h"

#define BOOTH_URI "org.maui.booth"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
		QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
		QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

#ifdef Q_OS_ANDROID
		QGuiApplication app(argc, argv);
		if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
				return -1;
#else
		QApplication app(argc, argv);
#endif

		app.setOrganizationName(QStringLiteral("Maui"));
        app.setWindowIcon(QIcon(":/booth.svg"));

        MauiApp::instance()->setIconName("qrc:/booth.svg");

		KLocalizedString::setApplicationDomain("booth");
        KAboutData about(QStringLiteral("booth"), i18n("Booth"), BOOTH_VERSION_STRING, i18n("Camera app to take pictures and record videos."), KAboutLicense::LGPL_V3, i18n("© 2020 - %1 Maui Development Team",QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

		about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
		about.setHomepage("https://mauikit.org");
		about.setProductName("maui/booth");
		about.setBugAddress("https://invent.kde.org/maui/booth/-/issues");
		about.setOrganizationDomain(BOOTH_URI);
		about.setProgramLogo(app.windowIcon());

		KAboutData::setApplicationData(about);

		QCommandLineParser parser;
        parser.setApplicationDescription(about.shortDescription());
		parser.process(app);
		about.processCommandLine(&parser);

		QQmlApplicationEngine engine;
		const QUrl url(QStringLiteral("qrc:/main.qml"));
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
