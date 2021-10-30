# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

if(QUICK_COMPILER)
    qtquick_compiler_add_resources(booth_QML_QRC qml.qrc)
else()
    qt5_add_resources(booth_QML_QRC qml.qrc)
endif()

add_executable(${PROJECT_NAME}
    main.cpp
    ${booth_QML_QRC}
)

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
else()
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

target_link_libraries(${PROJECT_NAME} MauiKit Qt5::Quick Qt5::Qml Qt5::Multimedia)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.maui.booth.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/booth.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
# install(FILES org.kde.booth.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

