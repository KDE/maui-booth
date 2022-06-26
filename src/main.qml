// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQml 2.14
import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtMultimedia 5.14

import org.mauikit.controls 1.2 as Maui

import "widgets"
import "views/roll"

Maui.ApplicationWindow
{
    id: root
    title:  currentTab ? currentTab.title : ""

    Maui.AppViews
    {
        anchors.fill: parent
        showCSDControls: true

        Maui.Page
        {
            id: cameraPage
            floatingFooter: true

            Maui.AppView.title: i18n("Camera")
            Maui.AppView.iconName: "camera-photo"
            headBar.visible: false
            footBar.leftContent: Maui.ToolActions
            {
                expanded : isWide
                autoExclusive: true
                currentIndex: 0
                display: ToolButton.TextBesideIcon
                cyclic: true

                Action
                {
                    icon.name: "camera-photo"
                    text: i18n("Photo")
                    onTriggered: cameraPage.state = "PhotoCapture"
                }

                Action
                {
                    icon.name: "camera-video"
                    text: i18n("Video")
                    onTriggered: cameraPage.state = "VideoCapture"
                }

            }

            footBar.middleContent: Rectangle
            {
                Layout.alignment: Qt.AlignCenter
                implicitHeight: Maui.Style.iconSizes.big
                implicitWidth: height
                radius: height
                border.color: Maui.Theme.textColor
                border.width: 2
                color: "transparent"

                Rectangle
                {
                    anchors.fill: parent
                    anchors.margins: Maui.Style.space.tiny
                    color: cameraPage.state === "PhotoCapture" ? Maui.Theme.textColor : Maui.Theme.negativeTextColor
                    radius: parent.radius
                }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        if(cameraPage.state === "PhotoCapture" && camera.imageCapture.ready)
                        {
                            camera.imageCapture.captureToLocation("/home/camilo/Pictures/DCMI/booth")
                        }

                        if(cameraPage.state === "VideoCapture" && camera.videoRecorder.recorderStatus == CameraRecorder.LoadedStatus)
                        {

                            camera.videoRecorder.record()
                        }
                    }
                }
            }

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
            }

            VideoCaptureControls {
                id: videoControls
                anchors.fill: parent
                camera: camera
                visible: cameraPage.state == "VideoCapture"
                onPreviewSelected: cameraPage.state = "VideoPreview"
            }
        }

        RollView
        {

            Maui.AppView.title: i18n("Roll")
            Maui.AppView.iconName: "photo"
        }

    }

}
