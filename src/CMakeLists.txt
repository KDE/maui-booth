# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

qt_add_resources(booth_QRC assets/assets.qrc)

if(ANDROID)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        main.cpp
        ${booth_QRC})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)

else()
    qt_add_executable(${PROJECT_NAME}
        main.cpp
        ${booth_QRC})
endif()

qt_add_qml_module(${PROJECT_NAME} URI app.maui.booth
    NO_PLUGIN
    QML_FILES
    main.qml
    widgets/CameraButton.qml
    widgets/CameraListButton.qml
    widgets/CameraListPopup.qml
    widgets/CameraPropertyButton.qml
    widgets/CameraPropertyPopup.qml
    widgets/FocusButton.qml
    widgets/PhotoCaptureControls.qml
    widgets/PhotoPreview.qml
    widgets/Popup.qml
    widgets/VideoCaptureControls.qml
    widgets/VideoPreview.qml
    widgets/ZoomControl.qml
    views/roll/RollView.qml
    views/CameraPage.qml)

if (ANDROID)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::Sql
        Qt6::QuickControls2)
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets)
endif()

target_link_libraries(${PROJECT_NAME}
    PRIVATE
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

qt_finalize_target(${PROJECT_NAME})
