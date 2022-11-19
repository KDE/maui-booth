// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQml 2.14
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtMultimedia 5.14
import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui

import "widgets"
import "views"

Maui.ApplicationWindow
{
    id: root

    Maui.Style.styleType: Maui.Handy.isAndroid ? Maui.Style.Dark  : undefined
    Maui.Style.accentColor: "#ffaa00"

    property alias appSettings : settings

    Settings
    {
        id: settings
        category: "Browser"

        property bool darkMode: true
        property bool readQR: true
    }

    Maui.Page
    {
        anchors.fill: parent

        floatingHeader: true
        autoHideHeader: true

        footBar.rightContent: Maui.ToolButtonMenu
        {
            icon.name: "view-refresh"

            Repeater
            {
                model: QtMultimedia.availableCameras
                delegate: MenuItem
                {
                    autoExclusive: true
                    checked: modelData.deviceId === _cameraPage.camera.deviceId
                    action: Action
                    {
                        checkable: true
                        text: modelData.displayName
                    }

                    onTriggered:
                    {
                        _cameraPage.camera.deviceId = modelData.deviceId
                    }
                }
            }
        }

        headBar.background: Rectangle
        {
            color: Maui.Theme.backgroundColor
            opacity: 0.5
        }

        headBar.rightContent: [

            ToolButton
            {
                icon.name: "love" //flash
            },

            Maui.ToolButtonMenu
            {
                icon.name: "adjustlevels" //focus

                Menu
                {
                    title: i18n("Mode")

                    Repeater
                    {
                        model:_cameraPage.camera.focus.supportedFocusModes
                        delegate: MenuItem
                        {
                            checkable: true
                            autoExclusive: true
                            checked: modelData === _cameraPage.camera.focus.focusMode

                            text: switch(modelData)
                            {
                                case Camera.FocusManual: return i18n("Manual")
                                case Camera.FocusHyperfocal: return i18n("Hyperfocal")
                                case Camera.FocusInfinity: return i18n("Infinity")
                                case Camera.FocusAuto: return i18n("Auto")
                                case Camera.FocusContinuous: return i18n("Continuous")
                                case Camera.FocusMacro: return i18n("Macro")
                            }

                            onTriggered:
                            {
                                _cameraPage.camera.focus.focusMode = modelData
                                _cameraPage.camera.searchAndLock()
                            }
                        }
                    }
                }

                Menu
                {
                    title: i18n("Point")

                    Repeater
                    {
                        model:_cameraPage.camera.focus.supportedFocusPointModes
                        delegate: MenuItem
                        {
                            checkable: true
                            autoExclusive: true
                            checked: modelData === _cameraPage.camera.focus.focusPointMode
                            text: switch(modelData)
                            {
                                case Camera.FocusPointAuto: return i18n("Auto")
                                case Camera.FocusPointCenter: return i18n("Center")
                                case Camera.FocusPointFaceDetection: return i18n("Face Detection")
                                case Camera.FocusPointCustom: return i18n("Custom")
                            }

                            onTriggered:
                            {

                                _cameraPage.camera.focus.focusPointMode = modelData
                                _cameraPage.camera.searchAndLock()

                            }
                        }
                    }
                }
            },

            ToolButton
            {
                id: _timer
                property int secs : 0
                checked: secs > 0
                display: secs === 0 ? ToolButton.IconOnly : ToolButton.TextBesideIcon
                text: secs + "s"
                icon.name: "timer"
                onClicked:
                {
                    switch(secs)
                    {
                    case 0: secs = 5; break;
                    case 5: secs = 10; break;
                    case 10: secs = 15; break;
                    case 15: secs = 0; break;
                    }

                }
            },

            Maui.ToolButtonMenu
            {
                icon.name: "overflow-menu"

                MenuItem
                {
                    text: i18n("Read QR")
                    icon.name: "view-barcode"
                    checkable: true
                    checked: settings.readQR
                    onToggled: settings.readQR = checked
                }

                Menu
                {
                    title: i18n("Resolutions")

                    Repeater
                    {
                        model: _cameraPage.camera.imageCapture.supportedResolutions
                        delegate: MenuItem
                        {
                            autoExclusive: true
                            checkable: true
                            checked: modelData === _cameraPage.camera.imageCapture.resolution
                            text: modelData.width + "x" + modelData.height
                            onTriggered: _cameraPage.camera.imageCapture.resolution = modelData
                        }
                    }
                }
            }
        ]

        footBar.leftContent: Maui.ToolButtonMenu
        {
            icon.name: "camera-photo"
            MenuItem
            {
                checked: _cameraPage.state === "PhotoCapture"
                autoExclusive: true
                checkable: true

                text: i18n ("Photo")
                onTriggered: _cameraPage.state = "PhotoCapture"
            }

            MenuItem
            {
                checked: _cameraPage.state === "VideoCapture"
                checkable: true
                autoExclusive: true
                onTriggered: _cameraPage.state = "VideoCapture"

                text: i18n ("Video")
            }

            MenuItem
            {
                checked: _cameraPage.state === "PhotoCapture" && _cameraPage.manualMode
                autoExclusive: true
                checkable: true

                text: i18n ("Manual")
                onTriggered:
                {
                    _cameraPage.state = "PhotoCapture"
                    _cameraPage.manualMode = true
                }

            }
        }


        //                Maui.ToolActions
        //                {
        //                    expanded : isWide
        //                    autoExclusive: true
        //                    currentIndex: 0
        //                    display: ToolButton.TextBesideIcon
        //                    cyclic: true

        //                    Action
        //                    {
        //                        icon.name: "camera-photo"
        //                        text: i18n("Photo")
        //                        checked: cameraPage.state === "PhotoCapture"
        //                        onTriggered: cameraPage.state = "PhotoCapture"
        //                    }

        //                    Action
        //                    {
        //                        icon.name: "camera-video"
        //                        text: i18n("Video")
        //                        checked: cameraPage.state === "VideoCapture"
        //                        onTriggered: cameraPage.state = "VideoCapture"
        //                    }

        //                }

        headBar.leftContent: [

            Maui.ToolButtonMenu
            {
                icon.name: "application-menu"

                MenuItem
                {
                    text: i18n("Settings")
                    icon.name: "settings-configure"
                    onTriggered: openConfigDialog()
                }

                MenuItem
                {
                    text: i18n("About")
                    icon.name: "documentinfo"
                    onTriggered: root.about()
                }
            }

        ]

        footBar.middleContent:AbstractButton
        {
            id: _shutterButton
            Layout.alignment: Qt.AlignCenter
            implicitHeight: Maui.Style.iconSizes.big
            implicitWidth: height

            property color m_color : pressed ? Maui.Theme.highlightColor : Maui.Theme.textColor

            ColorAnimation on m_color
            {
                running: _timerShot.running

                from: Maui.Theme.textColor
                to:  Maui.Theme.highlightColor
                duration: 1000
                loops: Animation.Infinite

                onFinished:  _shutterButton.m_color = Maui.Theme.textColor
            }
            background: null

            contentItem: Rectangle
            {

                radius: height
                border.color: _shutterButton.m_color
                border.width: 2
                color: "transparent"


                Rectangle
                {
                    anchors.fill: parent
                    anchors.margins: Maui.Style.space.tiny
                    color: _cameraPage.state === "PhotoCapture" ? _shutterButton.m_color : "red"
                    radius: parent.radius
                }
            }

            onClicked:
            {
                if(_timer.checked)
                {
                    _timerShot.restart()
                    return
                }

                _cameraPage.capture()
            }
        }

        footerColumn: [

            Maui.ToolBar
            {
                visible: _cameraPage.camera.maximumDigitalZoom > 1 && !Maui.Handy.isTouch
                width: parent.width

                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    opacity: 0.5
                }

                rightContent: Label
                {
                    text: "x" + Math.round(_cameraPage.camera.digitalZoom)
                }

                middleContent: Slider
                {
                    id: _zoomSlider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    stepSize: _cameraPage.camera.maximumDigitalZoom/10
                    from:0
                    to: _cameraPage.camera.maximumDigitalZoom

                    onMoved:
                    {
                        _cameraPage.camera.setDigitalZoom(value)
                    }
                }
            },

            Maui.ToolBar
            {
                visible: _cameraPage.manualMode
                width: parent.width

                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    opacity: 0.5
                }

                ToolButton
                {
                    text: i18n("Aperture")
                }

                ToolButton
                {
                    text: i18n("ISO")
                }

                ToolButton
                {
                    text: i18n("Shutter")
                }

                ToolButton
                {
                    text: i18n("Modes")
                }

                ToolButton
                {
                    text: i18n("Brightness")
                }

                ToolButton
                {
                    text: i18n("White Balance")
                }


                ToolButton
                {
                    text: i18n("Contrast")
                }

                ToolButton
                {
                    text: i18n("Saturation")
                }

                ToolButton
                {
                    text: i18n("Filters")
                }
            }
        ]

        CameraPage
        {
            id: _cameraPage
            anchors.fill: parent
        }
    }

    Timer
    {
        id: _timerShot
        interval: _timer.secs * 1000
        repeat: false
        onTriggered:
        {
            _cameraPage.capture()
        }
    }


    Component.onCompleted:
    {
        setAndroidStatusBarColor()
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor( Maui.Theme.backgroundColor, false)
            Maui.Android.navBarColor( Maui.Theme.backgroundColor, false)
        }
    }


}
