// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQml 2.14
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtMultimedia 5.14

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "widgets"

Maui.ApplicationWindow
{
    id: root
    title:  currentTab ? currentTab.title : ""
    color: "black"
    floatingHeader: true
    floatingFooter: true
    autoHideHeader: true
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    headBar.middleContent: [
        ToolButton
    {
        icon.name: "camera-photo"
        text: i18n("Photo")
    },

    ToolButton
    {
        icon.name: "camera-video"
        text: i18n("Video")
    }

    ]

    footBar.middleContent: Rectangle
    {
        height: Maui.Style.iconSizes.big
        width: height
        radius: height
        border.color: "white"
        border.width: 2
        color: "transparent"

        Rectangle
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.space.tiny
            color: Kirigami.Theme.negativeTextColor
radius: parent.radius
        }

    }

    Maui.Page
    {
        anchors.fill: parent
    id: cameraPage

    background: Rectangle
    {
        color: "#000"
    }

    state: "PhotoCapture"

    states: [
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    camera.captureMode = Camera.CaptureStillImage
                    camera.start()
                }
            }
        },
        State {
            name: "PhotoPreview"
        },
        State {
            name: "VideoCapture"
            StateChangeScript {
                script: {
                    camera.captureMode = Camera.CaptureVideo
                    camera.start()
                }
            }
        },
        State {
            name: "VideoPreview"
            StateChangeScript {
                script: {
                    camera.stop()
                }
            }
        }
    ]

    Camera {
        id: camera
        captureMode: Camera.CaptureStillImage

        imageCapture {
            onImageCaptured: {
                photoPreview.source = preview
                stillControls.previewAvailable = true
                cameraPage.state = "PhotoPreview"
            }
        }

        videoRecorder {
             resolution: "640x480"
             frameRate: 30
        }
    }

    PhotoPreview {
        id : photoPreview
        anchors.fill : parent
        onClosed: cameraPage.state = "PhotoCapture"
        visible: cameraPage.state == "PhotoPreview"
        focus: visible
    }

    VideoPreview {
        id : videoPreview
        anchors.fill : parent
        onClosed: cameraPage.state = "VideoCapture"
        visible: cameraPage.state == "VideoPreview"
        focus: visible

        //don't load recorded video if preview is invisible
        source: visible ? camera.videoRecorder.actualLocation : ""
    }

    VideoOutput {
        id: viewfinder
        visible: cameraPage.state == "PhotoCapture" || cameraPage.state == "VideoCapture"

        x: 0
        y: 0
        width: parent.width - stillControls.buttonsPanelWidth
        height: parent.height

        source: camera
        autoOrientation: true
    }

    PhotoCaptureControls {
        id: stillControls
        anchors.fill: parent
        camera: camera
        visible: cameraPage.state == "PhotoCapture"
        onPreviewSelected: cameraPage.state = "PhotoPreview"
        onVideoModeSelected: cameraPage.state = "VideoCapture"
    }

    VideoCaptureControls {
        id: videoControls
        anchors.fill: parent
        camera: camera
        visible: cameraPage.state == "VideoCapture"
        onPreviewSelected: cameraPage.state = "VideoPreview"
        onPhotoModeSelected: cameraPage.state = "PhotoCapture"
    }
    }
}
