# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


add_executable(booth
    main.cpp
    qml.qrc
)

if (ANDROID)
    target_link_libraries(booth Qt5::AndroidExtras)
endif()

target_link_libraries(booth MauiKit Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg Qt5::Multimedia)

install(TARGETS booth ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.maui.booth.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/booth.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
# install(FILES org.kde.booth.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

