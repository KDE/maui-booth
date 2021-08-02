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
#include "mauiandroid.h"
#else
#include <QApplication>
#endif

#ifdef Q_OS_MACOS
#include "mauimacos.h"
#endif

#ifdef Q_OS_MACOS
#include <KF5/KI18n/KLocalizedContext>
#else
#include <KI18n/KLocalizedContext>
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "mauiapp.h"
#else
#include <MauiKit/Core/mauiapp.h>
#endif

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedContext>
#include <KF5/KI18n/KLocalizedString>
#else
#include <KI18n/KLocalizedContext>
#include <KI18n/KLocalizedString>
#endif

#ifndef STATIC_MAUIKIT
#include "../booth_version.h"
#endif

#define BOOTH_URI "org.maui.booth"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
		QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
		QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
		QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
		QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_ANDROID
		QGuiApplication app(argc, argv);
		if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
				return -1;
#else
		QApplication app(argc, argv);
#endif

		app.setOrganizationName(QStringLiteral("Maui"));
		app.setWindowIcon(QIcon(":/assets/booth.svg"));
		//MauiApp::instance()->setHandleAccounts(false); //for now index can not handle cloud accounts
		MauiApp::instance()->setIconName("qrc:/assets/booth.svg");

		KLocalizedString::setApplicationDomain("booth");
		KAboutData about(QStringLiteral("booth"), i18n("Booth"), BOOTH_VERSION_STRING, i18n("Booth is a convergent camera app to take pictures and record videos."),
										 KAboutLicense::LGPL_V3, i18n("© 2020 Nitrux Development Team"));
		about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
		about.setHomepage("https://mauikit.org");
		about.setProductName("maui/booth");
		about.setBugAddress("https://invent.kde.org/maui/booth/-/issues");
		about.setOrganizationDomain(BOOTH_URI);
		about.setProgramLogo(app.windowIcon());

		KAboutData::setApplicationData(about);

		QCommandLineParser parser;
		parser.process(app);

		about.setupCommandLine(&parser);
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

#ifdef STATIC_KIRIGAMI
		KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
		MauiKit::getInstance().registerTypes();
#endif
	engine.load(url);

#ifdef Q_OS_MACOS
		//    MAUIMacOS::removeTitlebarFromWindow();
		//    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts

#endif
		return app.exec();
}
