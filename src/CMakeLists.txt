# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

qt_add_resources(booth_QML_QRC qml.qrc)

if(ANDROID)
    add_library(${PROJECT_NAME}
        SHARED
        main.cpp
        assets/assets.qrc
        ${booth_QML_QRC})
else()
    add_executable(${PROJECT_NAME}
        main.cpp
        assets/assets.qrc
        ${booth_QML_QRC})
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt6::AndroidExtras Qt6::QuickControls2)
else()
    target_link_libraries(${PROJECT_NAME} Qt6::Widgets)
endif()

target_link_libraries(${PROJECT_NAME}
    MauiKit4
    Qt6::Quick
    Qt6::Qml
    Qt6::Multimedia
    KF6::I18n
    KF6::CoreAddons)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

    #TODO: port to ecm_install_icons()
    install(FILES assets/booth.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
